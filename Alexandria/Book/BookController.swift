//
//  BookController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 8/4/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class BookController: UIViewController {
    
    let review: GoodreadsReview
    
    lazy var bookTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    init(review: GoodreadsReview) {
        self.review = review
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Init coder not implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationCapturesStatusBarAppearance = true
        view.backgroundColor = .white
        bookTitleLabel.text = review.book.title
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.addSubview(bookTitleLabel)
        
        NSLayoutConstraint.activate([
            bookTitleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bookTitleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}
