//
//  AppCoordinator.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import CoreData
import OAuthSwift

final class AppCoordinator: Coordinator {
    let navigationController: UINavigationController = UINavigationController()
    var childCoordinators: [Coordinator] = []
    let managedObjectContext: NSManagedObjectContext
    
    let shelfCoordinator: ShelfCoordinator
    var client: GoodreadsClient!
    
    let bookCoverCache = NSCache<NSString, UIImage>()
    
    lazy var authCoordinator: AuthenticationCoordinator = {
        return AuthenticationCoordinator(navigationController: self.navigationController, delegate: self)
    }()
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.shelfCoordinator = ShelfCoordinator(navigationController: navigationController, delegate: nil, bookCoverCache: self.bookCoverCache)
        shelfCoordinator.delegate = self
    }
    
    func start() {
        // Set initial coordinator
        childCoordinators.append(shelfCoordinator)
        shelfCoordinator.setAsRoot()
        
        // Check if credentials are available. If not launch auth flow.
        guard let credential = GoodreadsAccount.oauthSwiftCredential else {
            launchAuthenticationFlow()
            return
        }
        
        self.client = goodreadsClient(with: credential)
        shelfCoordinator.setCredential(credential)
        
        if let user = GoodreadsUser.load() {
            shelfCoordinator.setGoodreadsUser(user)
            shelfCoordinator.start()
        } else {
            getGoodreadsUser() { user in
                if let user = user {
                    self.shelfCoordinator.setGoodreadsUser(user)
                    self.shelfCoordinator.start()
                }
            }
        }
    }
    
    private func goodreadsClient(with credential: OAuthSwiftCredential) -> GoodreadsClient {
        return GoodreadsClient(credential: credential)
    }
    
    private func launchAuthenticationFlow() {
        childCoordinators.append(authCoordinator)
        shelfCoordinator.onLoad = {
            print("Shelf coordinator on load")
            self.authCoordinator.start()
        }
    }
    
    private func getGoodreadsUser(completion: @escaping (GoodreadsUser?) -> Void) {
        client.userId() { result in
            switch result {
            case .success(let user):
                completion(user)
            case .failure(let error):
                fatalError("Unable to obtain goodreads user. Error: \(error.localizedDescription)")
            }
        }
    }
}

extension AppCoordinator: ShelfCoordinatorDelegate {
    
}

extension AppCoordinator: AuthenticationCoordinatorDelegate {
    func authenticationSucceededWithCredential(_ credential: OAuthSwiftCredential, for coordinator: AuthenticationCoordinator) {
        coordinator.dismiss()
        childCoordinators.removeCoordinator(coordinator)
        
        self.client = goodreadsClient(with: credential)
        shelfCoordinator.setCredential(credential)
        
        getGoodreadsUser() { user in
            if let user = user {
                self.shelfCoordinator.setGoodreadsUser(user)
                self.shelfCoordinator.start()
            }
        }
    }
    
    func authenticationFailedWithError(_ error: AuthenticationError, for coordinator: AuthenticationCoordinator) {
        print("Failed to obtain credentials. Error: \(error)")
        coordinator.dismiss()
        childCoordinators.removeCoordinator(coordinator)
    }
}
