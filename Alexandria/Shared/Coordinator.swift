//
//  Coordinator.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

protocol Coordinator: class {
    /// The navigation controller that manages the view stack for the current flow.
    var navigationController: UINavigationController { get }
    
    /// Coordinators keep track of the path through the app by spawning further
    /// coordinators for each distinct subtask. A strong reference is maintained
    /// to each child and deallocated when the subtask is completed.
    var childCoordinators: [Coordinator] { get set }
    
    /// When a child coordinator is spawned, the start method is the only method
    /// exposed. A start method contains all of the logic to launch the subtask(s)
    /// controller by the coordinator.
    func start()
}
