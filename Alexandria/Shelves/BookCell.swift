//
//  BookCell.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/6/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

class BookCell: UICollectionViewCell {
    static let reuseIdentifier = "BookCell"
    
//    lazy var bookCoverView: UIImageView = {
//        let view = UIImageView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
    
    lazy var bookCoverView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.addSubview(bookCoverView)
        
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 80.0),
            contentView.heightAnchor.constraint(equalToConstant: 120.0),
            bookCoverView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bookCoverView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bookCoverView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            bookCoverView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
    }
}
