//
//  AppCoordinator.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import CoreData

final class AppCoordinator: Coordinator {
    
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    let managedObjectContext: NSManagedObjectContext
    
    init(managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        
        let currentlyReadingController = ViewController()
        self.navigationController = UINavigationController(rootViewController: currentlyReadingController)
    }
    
    func start() {
    }
}
