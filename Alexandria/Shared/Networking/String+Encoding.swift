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
    
    var rfc3986UnreservedEncodedSet: CharacterSet  {
        let unreservedChars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~"
        return CharacterSet(charactersIn: unreservedChars)
    }
    
    func encodedQueryString() -> String {
        return addingPercentEncoding(withAllowedCharacters: rfc3986UnreservedEncodedSet)!
    }
    
    func replacedAllInstances(of characterToReplace: Character, with replacement: Character) -> String {
        var mutableString = self
        
        for character in mutableString.characters where character == characterToReplace {
            if let index = mutableString.index(of: character) {
                mutableString.remove(at: index)
                mutableString.insert(replacement, at: index)
            }
        }
        
        return mutableString
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
    
    var words: [String] {
        return components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
            .filter{!$0.isEmpty}
    }
    
    var replacedPunctuation: String {        
        return words.joined(separator: " ")
    }
    
    var splitAtUppercase: String {
        return self.characters.splitBefore(separator: { $0.isUppercase }).map({ String($0) }).joined(separator: " ")
    }
}
