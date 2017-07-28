//
//  GoodreadsBook.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/3/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash
import UIKit

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

enum ImageDownloadState {
    case placeholder
    case downloaded
    case throttled
    case failed
}

final class GoodreadsBook: XMLIndexerDeserializable {
    let id: Int
    let isbn: String
    let isbn13: String
    let reviewsCount: Int
    let title: String
    let titleWithoutSeries: String
    var imageUrl: String
    var smallImageUrl: String
    var largeImageUrl: String
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
    
    var image: UIImage? = nil
    var imageDownloadState = ImageDownloadState.placeholder
    var smallImage: UIImage? = nil
    var smallImageDownloadState = ImageDownloadState.placeholder
    var largeImage: UIImage? = nil
    var largeImageDownloadState = ImageDownloadState.placeholder
    
    init(id: Int, isbn: String, isbn13: String, reviewsCount: Int, title: String, titleWithoutSeries: String, imageUrl: String, smallImageUrl: String, largeImageUrl: String, link: String, numberOfPages: String?, format: BookFormat, editionInformation: String?, publisher: String?, publicationDay: String?, publicationYear: String?, publicationMonth: String?, averageRating: Double, ratingsCount: Int, description: String, authors: [GoodreadsAuthor], workId: Int) {
        self.id = id
        self.isbn = isbn
        self.isbn13 = isbn13
        self.reviewsCount = reviewsCount
        self.title = title
        self.titleWithoutSeries = titleWithoutSeries
        self.imageUrl = imageUrl
        self.smallImageUrl = smallImageUrl
        self.largeImageUrl = largeImageUrl
        self.link = link
        self.numberOfPages = numberOfPages
        self.format = format
        self.editionInformation = editionInformation
        self.publisher = publisher
        self.publicationDay = publicationDay
        self.publicationYear = publicationYear
        self.publicationMonth = publicationMonth
        self.averageRating = averageRating
        self.ratingsCount = ratingsCount
        self.description = description
        self.authors = authors
        self.workId = workId
    }
    
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

extension GoodreadsBook {
    var hasValidImage: Bool {
        let components = imageUrl.split(separator: "/")
        return !components.contains("nophoto")
    }
    
    var hasValidLargeImage: Bool {
        if largeImageUrl.isEmpty { return false }
        let components = largeImageUrl.split(separator: "/")
        return !components.contains("nophoto")
    }
}
