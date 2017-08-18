//
//  BookCoordinator.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 8/4/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import UIKit

final class BookCoordinator: Coordinator {
    // - MARK: Coordinator
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    // - MARK: Private
    let review: GoodreadsReview
    let bookController: BookController
    let transitionDelegate = CardTransitionDelegate()
    
    init(navigationController: UINavigationController, review: GoodreadsReview) {
        self.navigationController = navigationController
        self.review = review
        self.bookController = BookController(review: review)
    }
    
    func start() {
        bookController.transitioningDelegate = transitionDelegate
        bookController.modalPresentationStyle = .custom
        navigationController.present(bookController, animated: true, completion: nil)
    }
}
