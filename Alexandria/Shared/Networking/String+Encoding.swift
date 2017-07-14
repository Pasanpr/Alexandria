//
//  String+Encoding.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/14/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

extension String {
    func encodedQueryForSigning() -> String? {
        let customUrlQueryDisallowedCharacters = CharacterSet(charactersIn: ":,/")
        let customUrlQueryAllowedCharacters = customUrlQueryDisallowedCharacters.inverted
        
        let intermediate = addingPercentEncoding(withAllowedCharacters: customUrlQueryAllowedCharacters)!
        let allowedSet = CharacterSet.whitespaces.inverted
        return intermediate.addingPercentEncoding(withAllowedCharacters: allowedSet)
    }
    
    func encodedQueryString() -> String {
        return addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
    
    func removedAllInstances(of character: Character) -> String {
        var mutableString = self
        
        while mutableString.contains(character) {
            if let index = mutableString.index(of: character) {
                mutableString.remove(at: index)
            }
        }
        
        return mutableString
    }
}
