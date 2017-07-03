//
//  GoodreadsClient.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import OAuthSwift
import SWXMLHash

final class GoodreadsClient {
    private let client: OAuthSwiftClient
    
    init(credential: OAuthSwiftCredential) {
        self.client = OAuthSwiftClient(credential: credential)
    }
    
    func userId(completion: @escaping (Result<GoodreadsUser, APIError>) -> Void) {
        get(Goodreads.userId) { result in
            switch result {
            case .success(let xml):
                do {
                    let user: GoodreadsUser = try xml.byKey("GoodreadsResponse").byKey("user").value()
                    completion(.success(user))
                } catch let error as IndexingError {
                    let error = APIError.xmlParsingFailure(message: error.description)
                    completion(.failure(error))
                } catch {
                    let error = APIError.xmlParsingFailure(message: "Generic parsing error")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func shelves(forUserId id: String, completion: @escaping (Result<[GoodreadsShelf], APIError>) -> Void) {
        let endpoint = Goodreads.shelves(.all(forUserId: id))
        
        get(endpoint) { result in
            switch result {
            case .success(let xml):
                do {
                    let shelves: [GoodreadsShelf] = try xml.byKey("GoodreadsResponse").byKey("shelves").byKey("user_shelf").value()
                    completion(.success(shelves))
                } catch let error as IndexingError {
                    let error = APIError.xmlParsingFailure(message: error.description)
                    completion(.failure(error))
                } catch {
                    let error = APIError.xmlParsingFailure(message: "Generic parsing error")
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func books(
        forUserId id: String,
        onShelf shelfName: String,
        sortType: GoodreadsSortParameter? = .dateAdded,
        sortOrder order: GoodreadsSortOrder? = .descending,
        query: String? = nil,
        page: Int? = nil,
        resultsPerPage: Int? = nil,
        completion: @escaping (Result<[GoodreadsReview], APIError>) -> Void) {
        
        let books = Goodreads.Shelves.books(userId: id, shelfName: shelfName, sortType: sortType, order: order, query: query, page: page, resultsPerPage: resultsPerPage)
        
        
        get(Goodreads.shelves(books)) { result in
            switch result {
            case .success(let xml):
                do {
                    let reviews: [GoodreadsReview] = try xml.byKey("GoodreadsResponse").byKey("reviews").byKey("review").value()
                    completion(.success(reviews))
                } catch let error as IndexingError {
                    let error = APIError.xmlParsingFailure(message: error.description)
                    completion(.failure(error))
                } catch let error as XMLDeserializationError {
                    completion(.failure(.xmlParsingFailure(message: error.description)))
                } catch {
                    completion(.failure(.xmlParsingFailure(message: error.localizedDescription)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        
    }
    
    private func get(_ endpoint: Goodreads, completion: @escaping (Result<XMLIndexer, APIError>) -> Void) {
        let _ = client.get(endpoint.urlString, success: { response in
            let xml = SWXMLHash.parse(response.data)
            completion(.success(xml))
        }) { error in
            let sessionError = APIError.sessionError(error)
            completion(.failure(sessionError))
        }
    }
}
