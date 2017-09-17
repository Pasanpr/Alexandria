//
//  BookCoverCell.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 9/16/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class BookCoverCell: UITableViewCell {
    
    let review: GoodreadsReview
    
    init(review: GoodreadsReview, blurredBackground: Bool) {
        self.review = review
        super.init(style: .default, reuseIdentifier: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var bookCoverImageView: UIImageView = {
        let imageView = UIImageView(image: self.review.book.largeImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        
        contentView.addSubview(bookCoverImageView)
        
        let screenBounds = UIScreen.main.bounds
        
        NSLayoutConstraint.activate([
            bookCoverImageView.widthAnchor.constraint(equalToConstant: screenBounds.width/2),
            bookCoverImageView.heightAnchor.constraint(equalTo: bookCoverImageView.widthAnchor, multiplier: 1.5),
            bookCoverImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            bookCoverImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
