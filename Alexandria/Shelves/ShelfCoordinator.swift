//
//  CurrentlyReadingCoordinator.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/3/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift

protocol ShelfCoordinatorDelegate: class {
    
}

final class ShelfCoordinator: Coordinator {
    let navigationController: UINavigationController 
    var childCoordinators: [Coordinator] = []
    weak var delegate: ShelfCoordinatorDelegate?
    
    private var credential: OAuthSwiftCredential!
    private var goodreadsUser: GoodreadsUser!
    private lazy var client: GoodreadsClient = {
        return GoodreadsClient(credential: self.credential)
    }()
    
    private let shelfController = ShelfController()
    private let operationQueue = OperationQueue()
    
    var onLoad: (() -> Void)? {
        didSet {
            shelfController.onViewDidLoad = onLoad
        }
    }
    
    init(navigationController: UINavigationController, delegate: ShelfCoordinatorDelegate?) {
        self.navigationController = navigationController
        self.delegate = delegate
    }
    
    func start() {
        shelfController.view.backgroundColor = .green
        
        var shelves = [Shelf]()
        
        let allOperation = AllShelvesOperation(user: goodreadsUser, credential: credential)
        
        let completionOperation = BlockOperation { [unowned self] in
            DispatchQueue.main.async { 
                self.shelfController.updateDataSource(with: shelves)
            }
        }
        
        let adapterOperation = BlockOperation {
            let reviewOperations = allOperation.shelves.map { [unowned self] in
                return ShelfReviewsOperation(user: self.goodreadsUser, credential: self.credential, shelf: $0, sortType: .dateUpdated, sortOrder: .descending, resultsPerPage: 10)
            }
            
            reviewOperations.forEach({ reviewOperation in
                
                completionOperation.addDependency(reviewOperation)
                
                reviewOperation.completionBlock = {
                    let shelf = Shelf(shelf: reviewOperation.shelf!, reviews: reviewOperation.reviews)
                    shelves.append(shelf)
                }
            })
            
            let _ = reviewOperations.flatMap { self.operationQueue.addOperation($0) }
        }
        
        adapterOperation.addDependency(allOperation)
        
        operationQueue.addOperation(allOperation)
        operationQueue.addOperation(adapterOperation)
        operationQueue.addOperation(completionOperation)
    }
    
    func setAsRoot() {
        navigationController.setViewControllers([shelfController], animated: false)
    }
    
    func setCredential(_ credential: OAuthSwiftCredential) {
        self.credential = credential
    }
    
    func setGoodreadsUser(_ user: GoodreadsUser) {
        self.goodreadsUser = user
    }
}
