//
//  ListCell.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/7/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class ListCell: UITableViewCell {
    
    static let reuseIdentifier = "ListCell"
    
    private lazy var layout: UICollectionViewLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80.0, height: 120.0)
        layout.minimumInteritemSpacing = 18
        layout.sectionInset = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
        return layout
    }()
    
    lazy var collectionView: ListCollectionView = {
        let view = ListCollectionView(frame: self.contentView.frame, collectionViewLayout: self.layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(BookCell.self, forCellWithReuseIdentifier: BookCell.reuseIdentifier)
        view.backgroundColor = .white
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(collectionView)
    }
}
