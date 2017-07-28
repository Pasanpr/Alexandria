//
//  CurrentlyReadingCell.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/14/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class CurrentlyReadingCell: UITableViewCell {
    
    static let reuseIdentifier = "CurrentlyReadingCell"
    
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
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Currently Reading"
        label.textColor = .white
        label.font = UIFont(name: "Palatino-Roman", size: 22.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20.0),
            collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20.0),
            collectionView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20.0)
        ])
    }
}
