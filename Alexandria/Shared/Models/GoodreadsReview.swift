//
//  GoodreadsReview.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/3/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash

struct GoodreadsReviewShelf: XMLIndexerDeserializable {
    let name: String
    let exclusive: Bool
    let id: String?
    
    static func deserialize(_ node: XMLIndexer) throws -> GoodreadsReviewShelf {
        return GoodreadsReviewShelf(
            name: node.element!.attribute(by: "name")!.text,
            exclusive: node.element!.attribute(by: "exclusive")!.text == "true" ? true : false,
            id: node.element?.attribute(by: "review_shelf_id")?.text
        )
    }
}

struct GoodreadsReview: XMLIndexerDeserializable {
    let id: Int
    let book: GoodreadsBook
    let rating: Int
    let votes: Int
    let spoilerFlag: Bool
    let spoilersState: String
    let shelves: [GoodreadsReviewShelf]
    let startedAtString: String?
    let readAtString: String?
    let dateAddedString: String
    let dateUpdatedString: String
    let readCount: String?
    
    static func deserialize(_ node: XMLIndexer) throws -> GoodreadsReview {
        return try GoodreadsReview(
            id: node["id"].value(),
            book: node["book"].value(),
            rating: node["rating"].value(),
            votes: node["votes"].value(),
            spoilerFlag: node["spoiler_flag"].value(),
            spoilersState: node["spoilers_state"].value(),
            shelves: node["shelves"]["shelf"].value(),
            startedAtString: node["started_at"].value(),
            readAtString: node["read_at"].value(),
            dateAddedString: node["date_added"].value(),
            dateUpdatedString: node["date_updated"].value(),
            readCount: node["read_count"].value()
        )
    }
}

extension GoodreadsReview: Hashable {
    var hashValue: Int {
        return id
    }
    
    static func ==(lhs: GoodreadsReview, rhs: GoodreadsReview) -> Bool {
        return lhs.id == rhs.id && lhs.book.title == rhs.book.title
    }
}
