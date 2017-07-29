//
//  AmazonClient.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/14/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash

final class AmazonClient {
    let session = URLSession.shared
    let accessKeyId = "AKIAJRSPIX3EVKNKLDOA"
    let associateTag = "pasanpremarat-20"
    let secretKey = "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"
    
    func coverImages(for title: String, completion: @escaping (Result<AmazonBookCover, APIError>) -> Void) {
        let endpoint = AmazonProductAdvertising.search(accessKeyId: accessKeyId, associateTag: associateTag, operation: .itemSearch, searchIndex: .books, keyword: title, itemId: nil, responseGroup: [.images], version: nil, date: Date())
        let request = endpoint.signedRequest(withSecretKey: secretKey)
        
        let task = session.dataTask(with: request) { data, response, error in
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = APIError.notHttpResponse
                completion(.failure(error))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                guard let data = data else {
                    let sessionError = APIError.sessionError(error!)
                    completion(.failure(sessionError))
                    return
                }
                
                let xml = SWXMLHash.parse(data) 
                
                do {
                    let bookCovers: [AmazonBookCover] = try xml.byKey("ItemSearchResponse").byKey("Items").byKey("Item").value()
                    completion(.success(bookCovers.first!))
                } catch let error as IndexingError {
                    let error = APIError.xmlParsingFailure(message: error.description)
                    completion(.failure(error))
                } catch let error as XMLDeserializationError {
                    completion(.failure(.xmlParsingFailure(message: error.description)))
                } catch {
                    completion(.failure(.xmlParsingFailure(message: error.localizedDescription)))
                }
                
                
            case 403:
                let error = APIError.invalidSignature
                completion(.failure(error))
                print("Invalid signature error for \(title)")
            case 503:
                let error = APIError.clientThrottled
                completion(.failure(error))
            default:
                let error = APIError.clientError(statusCode: httpResponse.statusCode)
                completion(.failure(error))
            }
        }
        
        task.resume()
        
    }
    
}
