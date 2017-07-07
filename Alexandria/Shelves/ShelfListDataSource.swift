//
//  ShelfDataSource.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/6/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import UIKit

class ShelfListDataSource: NSObject, UICollectionViewDataSource {
    var shelves: [Shelf]
    
    init(shelves: [Shelf]) {
        self.shelves = shelves
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
        print(book.title)
        
        return cell
    }
    
    func update(with shelves: [Shelf]) {
        self.shelves = shelves
    }
    
    func update(with shelf: Shelf) {
        print("Updating data source with shelf: \(shelf.shelf.name)")
        self.shelves.append(shelf)
    }
    
    func shelf(at indexPath: IndexPath) -> GoodreadsShelf {
        return shelves[indexPath.section].shelf
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
