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
    
    var sortedParametersForSigning: [URLParameter] {
        
        let sortedValues: [URLParameter] = map { parameter in
            var value = parameter.value
            
            if let splitValues = value?.split(separator: ",") {
                let sorted = splitValues.map({ String($0) }).sorted()
                value = sorted.joined(separator: ",")
            }
            
            return (parameter.key, value)
        }
        
        return sortedValues.sorted { $0.key < $1.key }
    }
    
    var encodedSortedQueryParametersForSigning: [URLParameter] {
        return sortedParametersForSigning.map {
            ($0.key, $0.value?.encodedQueryForSigning())
        }
    }
    
    var encodedQueryStringForSigning: String {
        return encodedSortedQueryParametersForSigning.map({ "\($0.key)=\($0.value!)" }).joined(separator: "&")
    }
    
    var encodedQueryParameters: [URLParameter] {
        return map { ($0.key, $0.value?.encodedQueryString())}
    }
    
    var encodedQueryString: String {
        return map({ "\($0.key)=\($0.value!)" }).joined(separator: "&")
    }
}
