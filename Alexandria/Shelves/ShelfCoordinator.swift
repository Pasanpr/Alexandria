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
    
    private var credential: OAuthSwiftCredential! {
        didSet {
            if let credential = credential {
                shelfController.credential = credential
            }
        }
    }
    private var goodreadsUser: GoodreadsUser!
    private lazy var client: GoodreadsClient = {
        return GoodreadsClient(credential: self.credential)
    }()
    
    lazy var shelfController: ShelfController = {
        return ShelfController(delegate: self)
    }()
    
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
        shelfController.delegate = self
        
        let loadAllShelvesAndBooks = LoadAllShelvesAndBooksOperation(user: goodreadsUser, credential: credential, sortType: .dateAdded, sortOrder: .descending, resultsPerPage: Preferences.booksPerShelf)
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

extension ShelfCoordinator: ShelfControllerDelegate {
    func didSelectShelf(_ shelf: Shelf) {
        let listCoordinator = ListCoordinator(navigationController: self.navigationController, credential: self.credential, goodreadsUser: self.goodreadsUser, shelf: shelf)
        listCoordinator.delegate = self
        childCoordinators.append(listCoordinator)
        
        listCoordinator.start()
    }
}

extension ShelfCoordinator: ListCoordinatorDelegate {
    
}



























