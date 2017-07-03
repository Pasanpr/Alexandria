//
//  APIClient.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/3/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash

enum APIError: Error {
    case notHttpResponse
    case redirectionError
    case clientError(statusCode: Int)
    case serverError(statusCode: Int)
    case sessionError(Error)
    case xmlParsingFailure(message: String)
}

extension APIError {
    var localizedDescription: String {
        switch self {
        case .notHttpResponse: return "Response type not HTTP"
        case .redirectionError: return "Redirection error"
        case .clientError(let code): return "Client side error. Status code: \(code)"
        case .serverError(let code): return "Server side error. Status code: \(code)"
        case .sessionError(let error): return "Session Error: \(error.localizedDescription)"
        case .xmlParsingFailure(let message): return "XML parsing failure. Description: \(message)"
        }
    }
}
