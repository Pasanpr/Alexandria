//
//  CoreDataStack.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import CoreData

func createAlexandriaContainer(completion: @escaping (NSPersistentContainer) -> Void) {
    let container = NSPersistentContainer(name: "Alexandria")
    
    container.loadPersistentStores() { _, error in
        guard error == nil else { fatalError("Failed to load store: \(error!)") }
        
        DispatchQueue.main.async {
            completion(container)
        }
    }
}
