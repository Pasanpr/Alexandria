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
    
    lazy var bookCoverView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFit
        
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 1)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 1.0
        view.clipsToBounds = false
        
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.addSubview(bookCoverView)
        
        NSLayoutConstraint.activate([
            bookCoverView.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            bookCoverView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bookCoverView.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            bookCoverView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        bookCoverView.image = nil
    }
}
