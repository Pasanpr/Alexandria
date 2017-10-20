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
    
    lazy var bottomFixedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var gradientView: LumaGradientView = {
        let view =  LumaGradientView(image: self.review.book.largeImage!, blurEffectStyle: .regular)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var bookCoverImageView: UIImageView = {
        let imageView = UIImageView(image: self.review.book.largeImage)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        imageView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 1)
        imageView.layer.shadowOpacity = 1
        imageView.layer.shadowRadius = 1.0
        imageView.clipsToBounds = false
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
        let expandableLabel = ExpandableLabel()
        expandableLabel.translatesAutoresizingMaskIntoConstraints = false
        return expandableLabel
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        bookDescriptionLabel.text = self.review.book.description.removedEscapedHtml
        print(self.review.book.description.removedEscapedHtml)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        view.addSubview(bottomFixedView)
        view.addSubview(scrollView)
        
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomFixedView.topAnchor),
            bottomFixedView.heightAnchor.constraint(equalToConstant: 64.0),
            bottomFixedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomFixedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomFixedView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16.0),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])
        
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        let screenBounds = UIScreen.main.bounds
        
        let bookCoverView = UIView()
        bookCoverView.addSubview(gradientView)
        bookCoverView.addSubview(bookCoverImageView)
        
        NSLayoutConstraint.activate([
            gradientView.leadingAnchor.constraint(equalTo: bookCoverView.leadingAnchor),
            gradientView.topAnchor.constraint(equalTo: bookCoverView.topAnchor),
            gradientView.trailingAnchor.constraint(equalTo: bookCoverView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: bookCoverView.bottomAnchor),
            bookCoverImageView.widthAnchor.constraint(equalToConstant: screenBounds.width/2),
            bookCoverImageView.heightAnchor.constraint(equalTo: bookCoverImageView.widthAnchor, multiplier: 1.5),
            bookCoverImageView.centerXAnchor.constraint(equalTo: gradientView.centerXAnchor),
            bookCoverImageView.centerYAnchor.constraint(equalTo: gradientView.centerYAnchor),
            gradientView.heightAnchor.constraint(equalTo: bookCoverImageView.heightAnchor, multiplier: 1.0, constant: 32)
        ])
        
        stackView.addArrangedSubview(bookCoverView)
        stackView.addArrangedSubview(bookTitleLabel)
        stackView.addArrangedSubview(authorLabel)
        stackView.addArrangedSubview(starRatingview)
        stackView.addArrangedSubview(ratingsDetailLabel)
        stackView.addArrangedSubview(bookDescriptionLabel)
        
        stackView.setCustomSpacing(32.0, after: bookCoverView)
        stackView.setCustomSpacing(16.0, after: authorLabel)
        stackView.setCustomSpacing(32.0, after: ratingsDetailLabel)
        
        NSLayoutConstraint.activate([
            bookCoverView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            bookCoverView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            bookTitleLabel.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 16.0),
            bookTitleLabel.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -16.0),
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
