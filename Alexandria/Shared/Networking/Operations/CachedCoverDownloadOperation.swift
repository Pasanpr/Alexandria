//
//  CachedCoverDownloadOperation.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/30/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift

private extension GoodreadsBook {
    func cacheKey(forSize size: BookCoverSize) -> NSString {
        return coverImageUrl(for: size) as NSString
    }
}

final class CachedCoverDownloadOperation: DelayAsyncOperation {
    let book: GoodreadsBook
    private let coverSize: BookCoverSize
    private let client: GoodreadsClient
    private lazy var amazonClient: AmazonClient = { return AmazonClient() }()
    private let cache = NSCache<NSString, UIImage>()
    
    init(coverSize: BookCoverSize, book: GoodreadsBook, credential: OAuthSwiftCredential) {
        self.book = book
        self.coverSize = coverSize
        self.client = GoodreadsClient(credential: credential)
        super.init(delay: 0.0, isDelayedAfter: false)
    }
    
    override func execute() {
        if isCancelled { return }
        
        if book.hasValidCoverImageUrl(for: coverSize) {
            if let cachedImage = cache.object(forKey: book.cacheKey(forSize: self.coverSize)) {
                book.setCoverImage(cachedImage, forSize: coverSize)
            } else {
                do {
                    let url = URL(string: book.coverImageUrl(for: coverSize))!
                    let data = try Data(contentsOf: url)
                    if isCancelled { return }
                    
                    if data.isEmpty {
                        self.setOperationResult(.failed)
                        finish()
                    } else {
                        let image = UIImage(data: data)!
                        cache.setObject(image, forKey: book.cacheKey(forSize: self.coverSize))
                        self.setOperationResult(.downloaded, image: image)
                        finish()
                    }
                } catch {
                    self.setOperationResult(.failed)
                    finish()
                }
            }
        } else {
            
            let authorsLastName = book.authors.first!.name.words.last!
            let query = book.title.words.count <= 2 ? "\(book.titleWithoutSeries) \(authorsLastName)" : book.titleWithoutSeries
            
            amazonClient.coverImages(for: query) { result in
                switch result {
                case .success(let amazonBookCover):
                    self.book.setCoverImageUrl(amazonBookCover.smallImageUrl!, for: .small)
                    self.book.setCoverImageUrl(amazonBookCover.mediumImageUrl!, for: .regular)
                    self.book.setCoverImageUrl(amazonBookCover.largeImageUrl!, for: .large)
                    
                    do {
                        let url = URL(string: self.book.coverImageUrl(for: self.coverSize))!
                        let data = try Data(contentsOf: url)
                        if self.isCancelled { return }
                        
                        if data.isEmpty {
                            self.setOperationResult(.failed)
                            self.finish()
                        } else {
                            let image = UIImage(data: data)!
                            self.cache.setObject(image, forKey: self.book.cacheKey(forSize: self.coverSize))
                            self.setOperationResult(.downloaded, image: image)
                            self.finish()
                        }
                    } catch {
                        self.setOperationResult(.failed)
                        self.finish()
                    }
                case .failure(let error):
                    switch error {
                    case .clientThrottled:
                        self.setOperationResult(.throttled)
                    default:
                        self.setOperationResult(.failed)
                    }
                    
                    self.finish()
                }
            }
        }
    }
    
    private func setOperationResult(_ state: ImageDownloadState, image: UIImage = #imageLiteral(resourceName: "BookCover")) {
        book.setDownloadState(state, forSize: coverSize)
        book.setCoverImage(image, forSize: coverSize)
    }
}

