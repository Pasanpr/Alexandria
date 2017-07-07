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
        let loadAllShelvesAndBooks = LoadAllShelvesAndBooksOperation(user: goodreadsUser, credential: credential, sortType: .dateUpdated, sortOrder: .descending, resultsPerPage: 10)
        loadAllShelvesAndBooks.completionBlock = {
            DispatchQueue.main.async {
                self.shelfController.updateDataSource(with: loadAllShelvesAndBooks.shelves)
            }
        }
        
        operationQueue.addOperation(loadAllShelvesAndBooks)
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
