//
//  Goodreads.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

enum Goodreads {
    case userId
}

extension Goodreads: Endpoint {
    var base: String {
        return "https://www.goodreads.com"
    }
    
    var path: String {
        switch self {
        case .userId: return "/api/auth_user"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .userId: return []
        }
    }
}
