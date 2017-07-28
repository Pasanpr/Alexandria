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

struct ListPath {
    let list: Int
    let book: Int
}

extension ListPath: Hashable {
    
    var hashValue: Int {
        return list ^ book
    }
    
    static func ==(lhs: ListPath, rhs: ListPath) -> Bool {
        return lhs.list == rhs.list && lhs.book == rhs.book
    }
}

class PendingBookCoverOperations {
    lazy var downloadsInProgress = [ListPath: Operation]()
    
    lazy var downloadQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}

class ShelfListDataSource: NSObject, UICollectionViewDataSource {
    private var shelves: [Shelf]
    private let credential: OAuthSwiftCredential!
    private let pendingOperations = PendingBookCoverOperations()
    
    init(shelves: [Shelf], credential: OAuthSwiftCredential!) {
        self.shelves = shelves
        self.credential = credential
        super.init()
    }
    
    // MARK: - Data Accessors
    
    func shelf(inSection section: Int) -> Shelf {
        return shelves[section]
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
        
        if let cover = book.largeImage {
            cell.bookCoverView.image = cover
        } else {
            cell.bookCoverView.image = #imageLiteral(resourceName: "BookCover")
        }
        
        switch book.largeImageDownloadState {
        case .placeholder, .throttled:
            let listPath = ListPath(list: listCollectionView.index, book: indexPath.row)
            startOperation(for: book, at: listPath, in: listCollectionView)
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
    
    func startOperation(for book: GoodreadsBook, at listPath: ListPath, in collectionView: ListCollectionView) {
        if let _ = pendingOperations.downloadsInProgress[listPath] {
            return
        }
        
        let operation = BookCoverDownloadOperation(book: book, credential: credential)
        
        operation.completionBlock = {
            if operation.isCancelled { return }
            self.pendingOperations.downloadsInProgress.removeValue(forKey: listPath)
            let indexPath = IndexPath(item: listPath.book, section: 0)
            
            DispatchQueue.main.async {
                collectionView.reloadItems(at: [indexPath])
            }
        }
        
        pendingOperations.downloadsInProgress[listPath] = operation
        pendingOperations.downloadQueue.addOperation(operation)
    }
}

extension ShelfListDataSource: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let listCollectionView = collectionView as! ListCollectionView
        let reviews = shelves[listCollectionView.index].reviews
        
        for indexPath in indexPaths {
            let book = reviews[indexPath.item].book
            
            switch book.largeImageDownloadState {
            case .placeholder, .throttled:
                let listPath = ListPath(list: listCollectionView.index, book: indexPath.row)
                startOperation(for: book, at: listPath, in: listCollectionView)
            default: break
            }
        }
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
            currentlyReadingCell.collectionView.prefetchDataSource = self
            currentlyReadingCell.collectionView.index = indexPath.section
            currentlyReadingCell.collectionView.reloadData()
            
            return currentlyReadingCell
        default:
            let listCell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath) as! ListCell
            
            listCell.collectionView.dataSource = self
            listCell.collectionView.prefetchDataSource = self
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
