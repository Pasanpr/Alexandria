//
//  ListDataSource.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/28/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import OAuthSwift

final class ListDataSource: NSObject {
    private let shelf: GoodreadsShelf
    private var reviews: [GoodreadsReview]
    private let credential: OAuthSwiftCredential
    private let goodreadsUser: GoodreadsUser
    private let collectionView: UICollectionView
    private let pendingOperations = PendingBookCoverOperations()
    private let cache: NSCache<NSString, UIImage>
    
    var booksOnShelf: Int {
        return shelf.bookCount
    }
    
    var allBooksFetched: Bool {
        let maxCurrentFetch = currentFetchRange.max()!
        return maxCurrentFetch == booksOnShelf
    }
    
    var currentPage = 1
    
    lazy var goodreadsClient: GoodreadsClient = {
        return GoodreadsClient(credential: self.credential)
    }()
    
    var currentFetchRange = 0..<Preferences.booksPerShelf
    
    init(collectionView: UICollectionView, shelf: Shelf, credential: OAuthSwiftCredential, goodreadsUser: GoodreadsUser, bookCoverCache: NSCache<NSString, UIImage>) {
        self.collectionView = collectionView
        self.shelf = shelf.shelf
        self.reviews = shelf.reviews
        self.credential = credential
        self.goodreadsUser = goodreadsUser
        self.cache = bookCoverCache
        super.init()
        
        collectionView.delegate = self
    }
    
    func review(at indexPath: IndexPath) -> GoodreadsReview {
        return reviews[indexPath.row]
    }
    
    func append(_ reviews: [GoodreadsReview]) {
        self.reviews.append(contentsOf: reviews)
    }
}

extension ListDataSource: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.reuseIdentifier, for: indexPath) as! BookCell
        
        let book = reviews[indexPath.item].book
        
        if let cover = book.coverImage(forSize: .large) {
            cell.bookCoverView.image = cover
        } else if let cover = cache.object(forKey: book.cacheKey(forSize: .large)) {
            book.setDownloadState(.downloaded, forSize: .large)
            cell.bookCoverView.image = cover
        } else {
            cell.bookCoverView.image = #imageLiteral(resourceName: "BookCover")
        }
        
        if !collectionView.isDragging && !collectionView.isDecelerating {
            switch book.coverImageDownloadState(forSize: .large) {
            case .placeholder, .throttled:
                startOperation(for: book, at: indexPath)
            default: break
            }
        }
        
        return cell
    }
    
    func startOperation(for book: GoodreadsBook, at indexPath: IndexPath) {
        if let _ = pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        
        let operation = CachedCoverDownloadOperation(coverSize: .large, book: book, credential: credential, cache: cache)
        
        operation.completionBlock = {
            if operation.isCancelled { return }
            self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
            let indexPath = IndexPath(item: indexPath.item, section: 0)
            
            DispatchQueue.main.async {
                self.collectionView.reloadItems(at: [indexPath])
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = operation
        pendingOperations.downloadQueue.addOperation(operation)
    }
}

extension ListDataSource {
    func scrollViewDidReachEnd(_ scrollView: UIScrollView) -> Bool {
        let bottomEdge = scrollView.contentOffset.y + scrollView.frame.height
        return bottomEdge >= scrollView.contentSize.height
    }
    
    func updateDataSource() {
        let maxCurrentFetch = currentFetchRange.max()!
        currentFetchRange = maxCurrentFetch..<(maxCurrentFetch + Preferences.booksPerShelf)
        
        goodreadsClient.books(forUserId: goodreadsUser.id, onShelf: shelf.name, sortType: .dateAdded, sortOrder: .descending, query: nil, page: currentPage + 1, resultsPerPage: Preferences.booksPerShelf) { result in
            switch result {
            case .success(let reviews):
                self.append(reviews)
                self.collectionView.reloadData()
                self.currentPage += 1
            case .failure(let error):
                print("Error prefetching: \(error.localizedDescription)")
            }
        }
    }
}

extension ListDataSource: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let maxCurrentFetch = currentFetchRange.max()!
        let maxPrefetch = indexPaths.last!.item
        let shouldFetchRange = (maxCurrentFetch - 2)...maxCurrentFetch
        
        if maxCurrentFetch <= booksOnShelf && shouldFetchRange.contains(maxPrefetch) {
            updateDataSource()
        }
    }
}

extension ListDataSource: UICollectionViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadCoversForVisibleItems()
            resumeOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollViewDidReachEnd(scrollView) && !allBooksFetched {
            updateDataSource()
        }
        
        loadCoversForVisibleItems()
        resumeOperations()
    }
    
    func suspendOperations() {
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeOperations() {
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    func loadCoversForVisibleItems() {
        let visiblePaths = Set(collectionView.indexPathsForVisibleItems)
        let allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
        
        let operationsToCancel = allPendingOperations.subtracting(visiblePaths)
        let operationsToStart = visiblePaths.subtracting(allPendingOperations)
        
        for indexPath in operationsToCancel {
            if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                pendingDownload.cancel()
            }
            pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
        }
        
        for indexPath in operationsToStart {
            let book = reviews[indexPath.item].book
            switch book.coverImageDownloadState(forSize: .large) {
            case .placeholder, .throttled:
                startOperation(for: book, at: indexPath)
            default: break
            }
        }
    }
}
