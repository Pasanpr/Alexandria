//
//  ListCoordinator.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/28/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import OAuthSwift

protocol ListCoordinatorDelegate: class {
    
}

final class ListCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    private let credential: OAuthSwiftCredential
    private let goodreadsUser: GoodreadsUser
    private let shelf: Shelf
    
    lazy var client: GoodreadsClient = {
        return GoodreadsClient(credential: self.credential)
    }()
    
    weak var delegate: ListCoordinatorDelegate?
    
    let listController: ListController
    let listDataSource: ListDataSource

    init(navigationController: UINavigationController, credential: OAuthSwiftCredential, goodreadsUser: GoodreadsUser, shelf: Shelf) {
        self.navigationController = navigationController
        self.credential = credential
        self.goodreadsUser = goodreadsUser
        self.shelf = shelf
        
        self.listController = ListController()
        self.listDataSource = ListDataSource(collectionView: listController.collectionView, shelf: shelf, credential: credential, goodreadsUser: goodreadsUser)
        listController.dataSource = self.listDataSource
    }
    
    func start() {
        listController.title = shelf.shelf.prettyName
        navigationController.pushViewController(listController, animated: true)
    }
    
    
}
