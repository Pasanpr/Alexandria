//
//  ShelfDataSource.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/6/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift

class PendingBookCoverOperations {
    lazy var downloadsInProgress = [IndexPath: Operation]()
    
    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        return queue
    }()
}

class ShelfListDataSource: NSObject, UICollectionViewDataSource {
    private var shelves: [Shelf]
    var credential: OAuthSwiftCredential!
    private let pendingOperations = PendingBookCoverOperations()
    private let cache: NSCache<NSString, UIImage>
    
    init(shelves: [Shelf], bookCoverCache: NSCache<NSString, UIImage>) {
        self.shelves = shelves
        self.cache = bookCoverCache
        super.init()
    }
    
    // MARK: - Data Accessors
    
    func shelf(inSection section: Int) -> Shelf {
        return shelves[section]
    }
    
    func suspendAllOperations() {
        pendingOperations.downloadQueue.isSuspended = true
    }
    
    func resumeAllOperations() {
        pendingOperations.downloadQueue.isSuspended = false
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let listCollectionView = collectionView as! ListCollectionView
        let shelf = shelves[listCollectionView.index]
        return shelf.reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.reuseIdentifier, for: indexPath) as! BookCell
        
        let listCollectionView = collectionView as! ListCollectionView
        let reviews = shelves[listCollectionView.index].reviews
        
        let book = reviews[indexPath.item].book
        
        if let cover = book.coverImage(forSize: .large) {
            cell.bookCoverView.image = cover
        } else {
            cell.bookCoverView.image = #imageLiteral(resourceName: "BookCover")
        }
        
        switch book.coverImageDownloadState(forSize: .large) {
        case .placeholder, .throttled:
            let indexPath = IndexPath(item: indexPath.row, section: listCollectionView.index)
            startOperation(for: book, at: indexPath, in: listCollectionView)
        default: break
        }
        
        return cell
    }
    
    func update(with shelves: [Shelf]) {
        self.shelves = shelves
    }
    
    func update(with shelf: Shelf) {
        self.shelves.append(shelf)
    }
    
    func shelf(at indexPath: IndexPath) -> GoodreadsShelf {
        return shelves[indexPath.section].shelf
    }
    
    func startOperation(for book: GoodreadsBook, at indexPath: IndexPath, in collectionView: ListCollectionView) {
        if let _ = pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        
        let operation = CachedCoverDownloadOperation(coverSize: .large, book: book, credential: credential, cache: cache)
        
        operation.completionBlock = {
            if operation.isCancelled { return }
            self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
            let indexPath = IndexPath(item: indexPath.item, section: 0)
            
            DispatchQueue.main.async {
                collectionView.reloadItems(at: [indexPath])
            }
        }
        
        pendingOperations.downloadsInProgress[indexPath] = operation
        pendingOperations.downloadQueue.addOperation(operation)
    }
}

extension ShelfListDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return shelves.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let currentlyReadingCell = tableView.dequeueReusableCell(withIdentifier: CurrentlyReadingCell.reuseIdentifier) as! CurrentlyReadingCell
            
            currentlyReadingCell.backgroundColor = UIColor(red: 32/255.0, green: 36/255.0, blue: 44/255.0, alpha: 1.0)
            
            currentlyReadingCell.collectionView.dataSource = self
            currentlyReadingCell.collectionView.index = indexPath.section
            currentlyReadingCell.collectionView.reloadData()
            
            return currentlyReadingCell
        default:
            let listCell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath) as! ListCell
            
            listCell.collectionView.dataSource = self
            listCell.collectionView.index = indexPath.section
            listCell.collectionView.reloadData()
            
            return listCell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return nil
        default:
            let shelf = shelves[section]
            return shelf.shelf.name
        }
    }
}
