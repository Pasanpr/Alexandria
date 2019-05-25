//
//  LoadAllShelvesOperation.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/7/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import OAuthSwift

final class LoadAllShelvesAndBooksOperation: AsynchronousOperation {
    private let user: GoodreadsUser
    private let credential: OAuthSwiftCredential
    
    // MARK: Request Parameters
    
    private let sortType: GoodreadsSortParameter
    private let sortOrder: GoodreadsSortOrder
    private let resultsPerPage: Int
    
    var shelves = [Shelf]()
    private let operationQueue = OperationQueue()
    
    init(user: GoodreadsUser, credential: OAuthSwiftCredential, sortType: GoodreadsSortParameter, sortOrder: GoodreadsSortOrder, resultsPerPage: Int) {
        self.user = user
        self.credential = credential
        
        self.sortType = sortType
        self.sortOrder = sortOrder
        self.resultsPerPage = resultsPerPage
        
        super.init()
    }
    
    convenience init(user: GoodreadsUser, credential: OAuthSwiftCredential) {
        self.init(user: user, credential: credential, sortType: .dateAdded, sortOrder: .descending, resultsPerPage: 12)
    }
    
    override func execute() {
        let allOperation = AllShelvesOperation(user: user, credential: credential)
        
        let completionOperation = BlockOperation {
            let stubbedOrder: [Int] = [40805573, 40805572, 203336617, 165412051, 122731963, 140197370, 201391608, 123078965, 40805574]
            self.sortedShelves(matching: stubbedOrder)
            self.finish()
        }
        
        let adapterOperation = BlockOperation {
            let reviewOperations = allOperation.shelves.map {
                return ShelfReviewsOperation(user: self.user, credential: self.credential, shelf: $0, sortType: self.sortType, sortOrder: self.sortOrder, resultsPerPage: self.resultsPerPage)
            }
            
            for reviewOperation in reviewOperations {
                completionOperation.addDependency(reviewOperation)
                
                reviewOperation.completionBlock = {
                    let shelf = Shelf(shelf: reviewOperation.shelf!, reviews: reviewOperation.reviews)
                    self.shelves.append(shelf)
                }
            }
            
            let _ = reviewOperations.compactMap { self.operationQueue.addOperation($0) }
            self.operationQueue.addOperation(completionOperation)
        }
        
        adapterOperation.addDependency(allOperation)
        
        operationQueue.addOperation(allOperation)
        operationQueue.addOperation(adapterOperation)
    }
    
    private func sortedShelves(matching userSortOrder: [Int]) {
        shelves.sort { a, b -> Bool in
            (userSortOrder.index(of: a.shelf.id) ?? userSortOrder.count) < (userSortOrder.index(of: b.shelf.id) ?? userSortOrder.count)
        }
    }
}
