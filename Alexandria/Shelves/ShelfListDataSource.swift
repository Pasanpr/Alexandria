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
    
    let downloadQueue = OperationQueue()
}

class ShelfListDataSource: NSObject, UICollectionViewDataSource {
    var shelves: [Shelf]
    let credential: OAuthSwiftCredential
    let pendingOperations = PendingBookCoverOperations()
    
    init(shelves: [Shelf], credential: OAuthSwiftCredential) {
        self.shelves = shelves
        self.credential = credential
        super.init()
    }
    
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
        let book = reviews[indexPath.row].book
        
//        print("At list path: (\(listCollectionView.index),\(indexPath.row) - imageUrl: \(book.imageUrl) for book: \(book.title). Book contains valid imageURL: \(book.hasValidImage)")
        
        if let cover = book.image {
            cell.bookCoverView.image = cover
        } else {
            cell.bookCoverView.image = #imageLiteral(resourceName: "BookCover")
        }
        
        switch book.imageDownloadState {
        case .placeholder:
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
            
            print("Completed operation for \(book.title) (id: \(book.id)) (\(book.isbn)). Book state: \(book.imageDownloadState)")
        }
        
        pendingOperations.downloadsInProgress[listPath] = operation
        pendingOperations.downloadQueue.addOperation(operation)
    }
}

//extension ShelfListDataSource: UICollectionViewDataSourcePrefetching {
//    // FIXME: UICollectionViewDataSourcePrefetching
//}

extension ShelfListDataSource: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return shelves.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let listCell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath) as! ListCell
        
        listCell.collectionView.dataSource = self
        listCell.collectionView.index = indexPath.section
        
        return listCell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let shelf = shelves[section]
        return shelf.shelf.name
    }
}
