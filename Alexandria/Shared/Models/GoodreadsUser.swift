//
//  GoodreadsUser.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/3/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import SWXMLHash
import Locksmith

struct GoodreadsUser: XMLIndexerDeserializable {
    let id: String
    let name: String
    let link: String
    
    static let service = "Goodreads"
    
    static func deserialize(_ node: XMLIndexer) throws -> GoodreadsUser {
        return try GoodreadsUser(
            id: node.value(ofAttribute: "id"),
            name: node["name"].value(),
            link: node["link"].value()
        )
    }
}

extension GoodreadsUser {
    func save() throws {
        try Locksmith.saveData(data: [GoodreadsKeychain.goodreadsUserId: id, GoodreadsKeychain.goodreadsUserName: name, GoodreadsKeychain.goodreadsUserLink: link], forUserAccount: GoodreadsAccount.service)
    }
    
    static func load() -> GoodreadsUser? {
        guard let data = Locksmith.loadDataForUserAccount(userAccount: GoodreadsAccount.service), let id = data[GoodreadsKeychain.goodreadsUserId] as? String, let name = data[GoodreadsKeychain.goodreadsUserName] as? String, let link = data[GoodreadsKeychain.goodreadsUserLink] as? String else { return nil }
        return GoodreadsUser(id: id, name: name, link: link)
    }
}


