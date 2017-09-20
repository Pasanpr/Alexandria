//
//  BookCoverView.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 9/17/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class BookCoverView: UIView {
    
    let review: GoodreadsReview
    
    private lazy var bookCoverImageView: UIImageView = {
        let imageView = UIImageView(image: self.review.book.largeImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    init(review: GoodreadsReview) {
        self.review = review
        
        let screenBounds = UIScreen.main.bounds
        let imageWidth = screenBounds.width/2
        let imageHeight = imageWidth * 1.5
        let padding: CGFloat = 42.0
        
        let frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: imageHeight + padding)
        super.init(frame: frame)
        
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        addSubview(bookCoverImageView)
        let screenBounds = UIScreen.main.bounds
        
        NSLayoutConstraint.activate([
            bookCoverImageView.widthAnchor.constraint(equalToConstant: screenBounds.width/2),
            bookCoverImageView.heightAnchor.constraint(equalTo: bookCoverImageView.widthAnchor, multiplier: 1.5),
            bookCoverImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            bookCoverImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
