//
//  GoodreadsBook.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/3/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash

enum BookFormat: XMLElementDeserializable {
    case hardcover
    case paperback
    case unknown(type: String)
    
    static func deserialize(_ element: SWXMLHash.XMLElement) throws -> BookFormat {
        let value = element.text
        
        switch value {
        case "Hardcover": return .hardcover
        case "Paperback": return .paperback
        default: return .unknown(type: value)
        }
    }
}

struct GoodreadsBook: XMLIndexerDeserializable {
    let id: Int
    let isbn: Int
    let isbn13: Int
    let reviewsCount: Int
    let title: String
    let titleWithoutSeries: String
    let imageUrl: String
    let smallImageUrl: String
    let largeImageUrl: String
    let link: String
    let numberOfPages: String?
    let format: BookFormat
    let editionInformation: String?
    let publisher: String?
    let publicationDay: String?
    let publicationYear: String?
    let publicationMonth: String?
    let averageRating: Double
    let ratingsCount: Int
    let description: String
    let authors: [GoodreadsAuthor]
    let workId: Int
    
    static func deserialize(_ node: XMLIndexer) throws -> GoodreadsBook {
        return try GoodreadsBook(
            id: node["id"].value(),
            isbn: node["isbn"].value(),
            isbn13: node["isbn13"].value(),
            reviewsCount: node["text_reviews_count"].value(),
            title: node["title"].value(),
            titleWithoutSeries: node["title_without_series"].value(),
            imageUrl: node["image_url"].value(),
            smallImageUrl: node["small_image_url"].value(),
            largeImageUrl: node["large_image_url"].value(),
            link: node["link"].value(),
            numberOfPages: node["num_pages"].value(),
            format: node["format"].value(),
            editionInformation: node["edition_information"].value(),
            publisher: node["publisher"].value(),
            publicationDay: node["publication_day"].value(),
            publicationYear: node["publication_year"].value(),
            publicationMonth: node["publication_month"].value(),
            averageRating: node["average_rating"].value(),
            ratingsCount: node["ratings_count"].value(),
            description: node["description"].value(),
            authors: node["authors"]["author"].value(),
            workId: node["work"]["id"].value()
        )
    }
}
