//
//  Goodreads.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

enum GoodreadsSortParameter: String {
    case title
    case author
    case cover
    case rating
    case yearPublished = "year_pub"
    case datePublished = "date_pub"
    case datePublishedEdition = "date_pub_edition"
    case dateStarted = "date_started"
    case dateRead = "date_read"
    case dateUpdated = "date_updated"
    case dateAdded = "date_added"
    case recommender
    case averageRating = "avg_rating"
    case numberOfRatings = "num_ratings"
    case review
    case readCount = "read_count"
    case votes
    case random
    case comments
    case notes
    case isbn
    case isbn13
    case asin
    case numberOfPages = "num_pages"
    case format
    case position
    case shelves
    case owned
    case datePurchase = "date_purchased"
    case purchaseLocation = "purchase_location"
    case condition
}

enum GoodreadsSortOrder: String {
    case ascending = "a"
    case descending = "d"
}

enum Goodreads {
    case userId
    case shelves(Shelves)
    
    enum Shelves {
        case all(forUserId: String)
        case books(userId: String, shelfName: String, sortType: GoodreadsSortParameter?, order: GoodreadsSortOrder?, query: String?, page: Int?, resultsPerPage: Int?)
    }
}

extension Goodreads: Endpoint {
    
    private struct Keys {
        struct Shelves {
            static let userId = "user_id"
            static let version = "v"
            static let shelfName = "shelf"
            static let shelfSortType = "sort"
            static let shelfSortOrder = "order"
            static let shelfResultsPageNumber = "page"
            static let shelfResultsPerPage = "per_page"
            static let shelfSearchQuery = "search[query]"
            
        }
    }
    
    var base: String {
        return "https://www.goodreads.com"
    }
    
    var path: String {
        switch self {
        case .userId: return "/api/auth_user"
        case .shelves(let shelves):
            switch shelves {
            case .all: return "/shelf/list.xml"
            case .books(_, _, _, _, _, _, _): return "/review/list.xml"
            }
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .userId: return []
        case .shelves(let shelves):
            switch shelves {
            case .all(let userId): return [(Keys.Shelves.userId, userId)].queryItems()
            case .books(let userId, let shelfName, let sortType, let order, let query, let page, let resultsPerPage):
                var params: [(key: String, value: String?)] = [
                    (Keys.Shelves.version, "2"),
                    (Keys.Shelves.userId, userId),
                    (Keys.Shelves.shelfName, shelfName),
                    (Keys.Shelves.shelfSortType, sortType?.rawValue),
                    (Keys.Shelves.shelfSortOrder, order?.rawValue)
                ]
                
                if let query = query {
                    params.append((Keys.Shelves.shelfSearchQuery, query))
                }
                
                if let page = page {
                    params.append((Keys.Shelves.shelfResultsPageNumber, page.description))
                }
                
                if let resultsPerPage = resultsPerPage {
                    params.append((Keys.Shelves.shelfResultsPerPage, resultsPerPage.description))
                }
                
                return params.queryItems()
            }
        }
    }
}
