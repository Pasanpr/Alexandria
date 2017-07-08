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

enum GoodreadsSearchField: String {
    case title
    case author
    case all
}


enum Goodreads {
    case userId
    case shelves(Shelves)
    case search(Search)
    
    enum Shelves {
        case all(forUserId: String)
        case books(userId: String, shelfName: String, sortType: GoodreadsSortParameter?, order: GoodreadsSortOrder?, query: String?, page: Int?, resultsPerPage: Int?)
    }
    
    enum Search {
        case books(query: String, page: Int?, searchField: GoodreadsSearchField)
    }
}

extension Goodreads: Endpoint {
    
    private struct Keys {
        struct Shelves {
            static let UserId = "user_id"
            static let Version = "v"
            static let Name = "shelf"
            static let SortType = "sort"
            static let SortOrder = "order"
            static let ResultsPageNumber = "page"
            static let ResultsPerPage = "per_page"
            static let SearchQuery = "search[query]"
            
        }
        
        struct Search {
            static let Query = "q"
            static let SearchType = "search[field]"
            static let Page = "page"
            
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
        case .search(let search):
            switch search {
            case .books(_, _, _): return "/search/index.xml"
            }
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .userId: return []
        case .shelves(let shelves):
            switch shelves {
            case .all(let userId): return [(Keys.Shelves.UserId, userId)].queryItems()
            case .books(let userId, let shelfName, let sortType, let order, let query, let page, let resultsPerPage):
                var params: [(key: String, value: String?)] = [
                    (Keys.Shelves.Version, "2"),
                    (Keys.Shelves.UserId, userId),
                    (Keys.Shelves.Name, shelfName),
                    (Keys.Shelves.SortType, sortType?.rawValue),
                    (Keys.Shelves.SortOrder, order?.rawValue)
                ]
                
                if let query = query {
                    params.append((Keys.Shelves.SearchQuery, query))
                }
                
                if let page = page {
                    params.append((Keys.Shelves.ResultsPageNumber, page.description))
                }
                
                if let resultsPerPage = resultsPerPage {
                    params.append((Keys.Shelves.ResultsPerPage, resultsPerPage.description))
                }
                
                return params.queryItems()
            }
        case .search(let search):
            switch search {
            case .books(let query, let page, let searchField):
                var params: [(key: String, value: String?)] = [
                    (Keys.Search.Query, query),
                    (Keys.Search.SearchType, searchField.rawValue)
                ]
                
                if let page = page {
                    params.append((Keys.Search.Page, page.description))
                }
                
                return params.queryItems()
            }
        }
    }
}
