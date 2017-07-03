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
        
        client.books(forUserId: goodreadsUser.id, onShelf: "2017") { result in
            switch result {
            case .success(let reviews):
                for review in reviews {
                    print("\(review.book.title) by \(review.book.authors.first!.name)")
                    
                }
            case .failure(let error):
                print("Failed to obtain books for shelf. Error: \(error.localizedDescription)")
            }
        }
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
