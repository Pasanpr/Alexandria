//
//  AmazonBookCover.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/14/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash

final class AmazonBookCover: XMLIndexerDeserializable {
    let smallImageUrl: String
    let mediumImageUrl: String
    let largeImageUrl: String
    
    init(smallUrl: String, mediumUrl: String, largeUrl: String) {
        self.smallImageUrl = smallUrl
        self.mediumImageUrl = mediumUrl
        self.largeImageUrl = largeUrl
    }
    
    static func deserialize(_ node: XMLIndexer) throws -> AmazonBookCover {
        return try AmazonBookCover(
            smallUrl: node["SmallImage"]["URL"].value(),
            mediumUrl: node["MediumImage"]["URL"].value(),
            largeUrl: node["LargeImage"]["URL"].value()
        )
    }
}
