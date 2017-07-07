//
//  ShelfReviewsOperation.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/7/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import OAuthSwift

final class ShelfReviewsOperation: AsynchronousOperation {
    private let user: GoodreadsUser
    private let client: GoodreadsClient
    var shelf: GoodreadsShelf?
    var reviews: [GoodreadsReview]
    
    // MARK: Request Parameters
    
    private let sortType: GoodreadsSortParameter
    private let sortOrder: GoodreadsSortOrder
    private let resultsPerPage: Int
    
    init(user: GoodreadsUser, credential: OAuthSwiftCredential, shelf: GoodreadsShelf?, sortType: GoodreadsSortParameter = .dateAdded, sortOrder: GoodreadsSortOrder = .descending, resultsPerPage: Int = 20) {
        self.user = user
        self.client = GoodreadsClient(credential: credential)
        self.shelf = shelf
        self.reviews = []
        
        self.sortType = sortType
        self.sortOrder = sortOrder
        self.resultsPerPage = resultsPerPage
        
        super.init()
    }
    
    convenience init(user: GoodreadsUser, credential: OAuthSwiftCredential) {
        self.init(user: user, credential: credential, shelf: nil)
    }
    
    convenience init(user: GoodreadsUser, credential: OAuthSwiftCredential, sortType: GoodreadsSortParameter, sortOrder: GoodreadsSortOrder, resultsPerPage: Int) {
        self.init(user: user, credential: credential, shelf: nil, sortType: sortType, sortOrder: sortOrder, resultsPerPage: resultsPerPage)
    }
    
    override func execute() {
        guard let shelf = shelf else {
            finish()
            return
        }
        
        client.books(forUserId: user.id, onShelf: shelf.name, sortType: sortType, sortOrder: sortOrder, resultsPerPage: resultsPerPage) { [unowned self] result in
            switch result {
            case .success(let reviews):
                self.reviews = reviews
                self.finish()
            case .failure(let error):
                print("Unable to fetch books for shelf: \(String(describing: self.shelf?.name)) with user id: \(self.user.id). Error: \(error.localizedDescription)")
                self.finish()
            }
        }
    }
}
