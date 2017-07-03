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

extension Endpoint {
    func oauthRequest(using client: OAuthSwiftClient) -> URLRequest {
        return client.makeRequest(self.request).config.urlRequest
    }
}

final class GoodreadsClient {
    private let client: OAuthSwiftClient
    
    init(credential: OAuthSwiftCredential) {
        self.client = OAuthSwiftClient(credential: credential)
    }
    
    func userId(completion: @escaping (Result<GoodreadsUser, APIError>) -> Void) {
                
        let _ = client.get(Goodreads.userId.urlString, success: { response in
            
            let xml = SWXMLHash.parse(response.data)
            
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
            
        }) { error in
            let sessionError = APIError.sessionError(error)
            completion(.failure(sessionError))
        }
    }
}
