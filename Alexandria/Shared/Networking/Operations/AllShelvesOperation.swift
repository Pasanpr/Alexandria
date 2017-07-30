//
//  AllShelvesOperation.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/7/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import OAuthSwift

final class AllShelvesOperation: AsynchronousOperation {
    private let user: GoodreadsUser
    private let client: GoodreadsClient
    var shelves: [GoodreadsShelf]
    
    init(user: GoodreadsUser, credential: OAuthSwiftCredential) {
        self.user = user
        self.client = GoodreadsClient(credential: credential)
        self.shelves = []
        super.init()
    }
    
    override func execute() {
        client.shelves(forUserId: user.id) { [unowned self] result in
            switch result {
            case .success(let goodreadsShelves):
                self.shelves = goodreadsShelves
                self.finish()
            case .failure(let error):
                print("Unable to fetch shelves for user: \(self.user.id). Error: \(error.localizedDescription)")
                self.finish()
            }
        }
    }
}
