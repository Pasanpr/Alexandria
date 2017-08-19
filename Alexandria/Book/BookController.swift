//
//  BookController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 8/4/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import Cosmos

final class BookController: UIViewController {
    
    let review: GoodreadsReview
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    lazy var bookCoverImageView: UIImageView = {
        let imageView = UIImageView(image: self.review.book.largeImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var bookTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.review.book.titleWithoutSeries
        label.font = UIFont(name: "Palatino-Roman", size: 28.0)!
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.review.book.authors.first!.name
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var starRatingview: CosmosView = {
        let view = CosmosView()
        view.settings.updateOnTouch = false
        view.settings.fillMode = .precise
        view.rating = self.review.book.averageRating
        return view
    }()
    
    lazy var ratingsDetailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "\(self.review.book.ratingsCount) Ratings . \(self.review.book.reviewsCount) Reviews"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var bookDescriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
//        let attributeOptionsDict: [NSAttributedString.DocumentReadingOptionKey : Any] = [
//            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html,
//            NSAttributedString.DocumentReadingOptionKey.characterEncoding: NSNumber(value: String.Encoding.utf8.rawValue)
//            ]
//        let attributedDescription = try! NSAttributedString(data: self.review.book.description.data(using: .utf8)!, options: attributeOptionsDict, documentAttributes: nil)
        
        
        
        label.text = self.review.book.description.removedEscapedHtml
        
        label.textAlignment = .left
        label.numberOfLines = 0
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 36.0),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16.0),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        let screenBounds = UIScreen.main.bounds
        
        NSLayoutConstraint.activate([
            bookCoverImageView.widthAnchor.constraint(equalToConstant: screenBounds.width/2),
            bookCoverImageView.heightAnchor.constraint(equalTo: bookCoverImageView.widthAnchor, multiplier: 1.5)
        ])
        
        stackView.addArrangedSubview(bookCoverImageView)
        stackView.addArrangedSubview(bookTitleLabel)
        stackView.addArrangedSubview(authorLabel)
        stackView.addArrangedSubview(starRatingview)
        stackView.addArrangedSubview(ratingsDetailLabel)
        stackView.addArrangedSubview(bookDescriptionLabel)
        
        stackView.setCustomSpacing(32.0, after: bookCoverImageView)
        stackView.setCustomSpacing(16.0, after: authorLabel)
        stackView.setCustomSpacing(32.0, after: ratingsDetailLabel)
        
        NSLayoutConstraint.activate([
            bookDescriptionLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16.0),
            bookDescriptionLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16.0)
        ])
    }
    
    private func stackView(withSubviews subviews: [UIView]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: subviews)
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }
}

extension BookController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let delegate = transitioningDelegate as? CardTransitionDelegate {
            if scrollView.contentOffset.y > 0 {
                // Normal behaviour if the `scrollView` isn't scrolled to the top
                scrollView.bounces = true
                delegate.isDismissEnabled = false
            } else {
                if scrollView.isDecelerating {
                    // If the `scrollView` is scrolled to the top but is decelerating
                    // that means a swipe has been performed. The view and
                    // scrollviewʼs subviews are both translated in response to this.
                    view.transform = CGAffineTransform(translationX: 0, y: -scrollView.contentOffset.y)
                    scrollView.subviews.forEach {
                        $0.transform = CGAffineTransform(translationX: 0, y: scrollView.contentOffset.y)
                    }
                } else {
                    // If the user has panned to the top, the scrollview doesnʼt bounce and
                    // the dismiss gesture is enabled.
                    scrollView.bounces = false
                    delegate.isDismissEnabled = true
                }
            }
        }
    }
}
