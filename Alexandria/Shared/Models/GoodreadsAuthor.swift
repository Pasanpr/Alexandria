//
//  GoodreadsAuthor.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/3/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash

struct GoodreadsAuthor: XMLIndexerDeserializable {
    let id: Int
    let name: String
    let imageUrl: String?
    let smallImageUrl: String?
    let link: String?
    let averageRating: Double?
    let ratingsCount: Int?
    let textReviewsCount: Int?
    
    static func deserialize(_ node: XMLIndexer) throws -> GoodreadsAuthor {
        return try GoodreadsAuthor(
            id: node["id"].value(),
            name: node["name"].value(),
            imageUrl: node["image_url"].value(),
            smallImageUrl: node["small_image_url"].value(),
            link: node["link"].value(),
            averageRating: node["average_rating"].value(),
            ratingsCount: node["ratings_count"].value(),
            textReviewsCount: node["text_reviews_count"].value()
        )
    }
}

extension GoodreadsAuthor {
    var nameComponents: PersonNameComponents? {
        let formatter = PersonNameComponentsFormatter()
        return formatter.personNameComponents(from: name)
    }
    
    var firstName: String? {
        return nameComponents?.givenName
    }
    
    var middleName: String? {
        return nameComponents?.middleName
    }
    
    var lastName: String? {
        return nameComponents?.familyName
    }
    
    var queryName: String {
        guard let first = firstName, let last = lastName else {
            return name
        }
        
        return first + " " + last
    }
}
