//
//  GoodreadsWork.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/7/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash

final class GoodreadsBestBook: XMLIndexerDeserializable {
    let id: Int
    let title: String
//    let author: GoodreadsAuthor
    let review: GoodreadsReview?
    let imageUrl: String
    let smallImageUrl: String
    
    init(id: Int, title: String, review: GoodreadsReview?, imageUrl: String, smallImageUrl: String) {
        self.id = id
        self.title = title
//        self.author = author
        self.review = review
        self.imageUrl = imageUrl
        self.smallImageUrl = smallImageUrl
    }
    
    static func deserialize(_ node: XMLIndexer) throws -> GoodreadsBestBook {
        return try GoodreadsBestBook(
            id: node["id"].value(),
            title: node["title"].value(),
//            author: node["author"].value(),
            review: node["my_review"].value(),
            imageUrl: node["image_url"].value(),
            smallImageUrl: node["small_image_url"].value()
        )
    }
}

final class GoodreadsWork: XMLIndexerDeserializable {
    let id: Int
    let booksCount: Int
    let ratingsCount: Int
    let textReviewsCount: Int
    let originalPublicationYear: String
    let originalPublicationMonth: String?
    let originalPublicationDay: String?
    let averageRating: Double
    let bestBook: GoodreadsBestBook
    
    init(id: Int, booksCount: Int, ratingsCount: Int, textReviewsCount: Int, originalPublicationYear: String, originalPublicationMonth: String?, originalPublicationDay: String?, averageRating: Double, bestBook: GoodreadsBestBook) {
        self.id = id
        self.booksCount = booksCount
        self.ratingsCount = ratingsCount
        self.textReviewsCount = textReviewsCount
        self.originalPublicationYear = originalPublicationYear
        self.originalPublicationMonth = originalPublicationMonth
        self.originalPublicationDay = originalPublicationDay
        self.averageRating = averageRating
        self.bestBook = bestBook
    }
    
    static func deserialize(_ node: XMLIndexer) throws -> GoodreadsWork {
        return try GoodreadsWork(
            id: node["id"].value(),
            booksCount: node["books_count"].value(),
            ratingsCount: node["ratings_count"].value(),
            textReviewsCount: node["text_reviews_count"].value(),
            originalPublicationYear: node["original_publication_year"].value(),
            originalPublicationMonth: node["original_publication_month"].value(),
            originalPublicationDay: node["original_publication_day"].value(),
            averageRating: node["average_rating"].value(),
            bestBook: node["best_book"].value()
        )
    }
}

extension GoodreadsWork {
    var hasReview: Bool {
        return bestBook.review != nil
    }
    
    var hasValidImage: Bool {
        let imageUrl = bestBook.imageUrl
        let components = imageUrl.split(separator: "/")
        return !components.contains("nophoto")
    }
}
