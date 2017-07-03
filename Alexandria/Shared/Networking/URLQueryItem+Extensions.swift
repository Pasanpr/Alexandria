//
//  URLQueryItem+Extensions.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == (key: String, value: String?) {
    func queryItems() -> [URLQueryItem] {
        return map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
