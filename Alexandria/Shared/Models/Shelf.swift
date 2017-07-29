//
//  Shelf.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/6/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

final class Shelf: NSObject {
    let shelf: GoodreadsShelf
    let reviews: [GoodreadsReview]
    
    init(shelf: GoodreadsShelf, reviews: [GoodreadsReview]) {
        self.shelf = shelf
        self.reviews = reviews
        super.init()
    }
}
