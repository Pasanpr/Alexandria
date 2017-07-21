//
//  AmazonProductAdvertising.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/12/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import CryptoSwift

enum AmazonAssociatesOperation: String {
    case itemSearch = "ItemSearch"
    case itemLookup = "ItemLookup"
}

enum AmazonAssociatesSearchIndex: String {
    case books = "Books"
}

enum AmazonAssociatesResponseGroup: String {
    case images = "Images"
    case itemAttributes = "ItemAttributes"
    case offers = "Offers"
    case reviews = "Reviews"
}

enum AmazonProductAdvertising {
    case search(accessKeyId: String, associateTag: String, operation: AmazonAssociatesOperation, searchIndex: AmazonAssociatesSearchIndex?, keyword: String?, itemId: String?, responseGroup: [AmazonAssociatesResponseGroup], version: String?, date: Date)
}

extension AmazonProductAdvertising {
    var base: String {
        return "https://webservices.amazon.com"
    }
    
    var path: String {
        switch self {
        case .search: return "/onca/xml"
        }
    }
    
    var queryParameters: [URLParameter] {
        switch self {
        case .search(let accessKeyId, let associateTag, let operation, let searchIndex, let keyword, let itemId, let responseGroup, let version, let date):
            let formatter = ISO8601DateFormatter()
            formatter.timeZone = TimeZone.autoupdatingCurrent
            
            var baseParams: [URLParameter] = [
                ("Service", "AWSECommerceService"),
                ("AWSAccessKeyId", accessKeyId),
                ("AssociateTag", associateTag),
                ("Operation", operation.rawValue),
                ("Timestamp", formatter.string(from: date))
            ]
            
            if let searchIndex = searchIndex {
                baseParams.append(("SearchIndex", searchIndex.rawValue))
            }
            
            if let keyword = keyword {
                let sanitizedKeyword = keyword.removedAllInstances(of: "\'").removedAllInstances(of: "/").replacedPunctuation
                baseParams.append(("Keywords", sanitizedKeyword))
            }
            
            if let itemId = itemId {
                baseParams.append(("ItemId", itemId))
            }
            
            if !responseGroup.isEmpty {
                let responseGroupString = responseGroup.map({ $0.rawValue }).sorted(by: { $0 < $1 }).joined(separator: ",")
                baseParams.append(("ResponseGroup", responseGroupString))
            }
            
            if let version = version {
                baseParams.append(("Version", version))
            }
            
            return baseParams
        }
    }
    
    private var verb: String {
        switch self {
        case .search: return "GET"
        }
    }
    
    private var hostHeader: String {
        return "webservices.amazon.com"
    }
    
    func signature(withKey key: String) -> String? {
        let stringToSign = "\(verb)\n\(hostHeader)\n\(path)\n\(queryParameters.encodedQueryStringForSigning)"
        let byteArray = stringToSign.utf8.map({$0})
        
        let signature = try! HMAC(key: key, variant: .sha256).authenticate(byteArray)
        guard let signatureString = signature.toBase64() else { return nil }
        
        return signatureString
    }
    
    func encodedSignature(withKey key: String) -> String? {
        let disallowedSignatureCharacters = CharacterSet(charactersIn: "+=/")
        let allowedSignatureCharacters = disallowedSignatureCharacters.inverted
        
        if let signatureString = signature(withKey: key) {
            return signatureString.addingPercentEncoding(withAllowedCharacters: allowedSignatureCharacters)
        } else {
            return nil
        }
    }
    
    func signedQueryParameters(withSecretKey key: String) -> [URLParameter] {
        let signatureParam: URLParameter = ("Signature", encodedSignature(withKey: key))
        var baseParams = queryParameters.encodedQueryParameters
        baseParams.append(signatureParam)
        
        return baseParams
    }
    
    func signedRequest(withSecretKey key: String) -> URLRequest {
        let urlString = base + path + "?" + signedQueryParameters(withSecretKey: key).encodedQueryString
        let url = URL(string: urlString)!
        return URLRequest(url: url)
    }
}
