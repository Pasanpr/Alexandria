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
        return shelves.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let shelf = shelves[section]
        return shelf.reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.reuseIdentifier, for: indexPath)
        cell.backgroundColor = .blue
        return cell
    }
    
    func update(with shelves: [Shelf]) {
        self.shelves = shelves
    }
}

//extension ShelfListDataSource: UICollectionViewDataSourcePrefetching {
//    // FIXME: UICollectionViewDataSourcePrefetching
//}

