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
        layout.itemSize = CGSize(width: 120.0, height: 180.0)
        layout.minimumInteritemSpacing = 18
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
        
        NSLayoutConstraint.activate([
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
