//
//  Sequence+Utilities.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 8/4/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation

extension Sequence {
    func splitBefore(separator isSeparator: (Element) throws -> Bool) rethrows -> [AnySequence<Element>] {
        var result: [AnySequence<Element>] = []
        var subsequence: [Element] = []
        
        var iterator = self.makeIterator()
        while let element = iterator.next() {
            if try isSeparator(element) {
                if !subsequence.isEmpty {
                    result.append(AnySequence(subsequence))
                }
                
                subsequence = [element]
            } else {
                subsequence.append(element)
            }
        }
        
        result.append(AnySequence(subsequence))
        return result
    }
}
