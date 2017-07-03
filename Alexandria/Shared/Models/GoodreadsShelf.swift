//
//  GoodreadsShelf.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/3/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash

struct GoodreadsShelf: XMLIndexerDeserializable {
    let id: Int
    let name: String
    let bookCount: Int
    let exclusive: Bool
    let description: String?
    let sort: String?
    let order: String?
    let perPage: String?
    let featured: Bool
    let recommendFor: Bool
    let sticky: String?
    
    static func deserialize(_ node: XMLIndexer) throws -> GoodreadsShelf {
        return try GoodreadsShelf(
            id: node["id"].value(),
            name: node["name"].value(),
            bookCount: node["book_count"].value(),
            exclusive: node["exclusive_flag"].value(),
            description: node["description"].value(),
            sort: node["sort"].value(),
            order: node["order"].value(),
            perPage: node["per_page"].value(),
            featured: node["featured"].value(),
            recommendFor: node["recommend_for"].value(),
            sticky: node["sticky"].value()
        )
    }
}

