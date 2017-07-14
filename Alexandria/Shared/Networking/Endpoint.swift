//
//  Endpoint.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

public typealias URLParameter = (key: String, value: String?)

protocol Endpoint {
    var base: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }
}

extension Endpoint {
    var components: URLComponents {
        guard var components = URLComponents(string: base) else { fatalError("Valid URL could not be constructed from base") }
        components.path = path
        
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        return components
    }
    
    var url: URL {
        return components.url!
    }
    
    var urlString: String {
        return url.absoluteString
    }
    
    var request: URLRequest {
       return URLRequest(url: url)
    }
}
