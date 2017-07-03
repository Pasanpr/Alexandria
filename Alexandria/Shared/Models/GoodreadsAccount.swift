//
//  GoodreadsAccount.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import Locksmith
import OAuthSwift

struct GoodreadsAccount {
    let consumerKey = "W5hTqI7W67YlUbvVOXccRw"
    let consumerSecret = "kJw7xZpiPPyRijwE5BMB5la9XZUunAAZ73k0THWJo"
    let secret: String
    let token: String
    
    static let service = "Goodreads"
    
    func save() throws {
        try Locksmith.saveData(data: [GoodreadsKeychain.oauthTokenSecret: secret, GoodreadsKeychain.oauthToken: token], forUserAccount: GoodreadsAccount.service)
    }
    
    static func load() -> GoodreadsAccount? {
        guard let data = Locksmith.loadDataForUserAccount(userAccount: GoodreadsAccount.service), let token = data[GoodreadsKeychain.oauthToken] as? String, let secret = data[GoodreadsKeychain.oauthTokenSecret] as? String else { return nil }
        return GoodreadsAccount(secret: secret, token: token)
    }
}

extension GoodreadsAccount {
    
    init(credential: OAuthSwiftCredential) {
        self.init(secret: credential.oauthTokenSecret, token: credential.oauthToken)
    }
    
    static var oauthSwiftCredential: OAuthSwiftCredential? {
        if let account = GoodreadsAccount.load() {
            let credential = OAuthSwiftCredential(consumerKey: account.consumerKey, consumerSecret: account.consumerSecret)
            credential.oauthToken = account.token
            credential.oauthTokenSecret = account.secret
            
            return credential
        } else {
            return nil
        }
    }
}
