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

final class CachedCoverDownloadOperation: DelayAsyncOperation {
    let book: GoodreadsBook
    private let coverSize: BookCoverSize
    private let client: GoodreadsClient
    private lazy var amazonClient: AmazonClient = {
        return AmazonClient()
    }()
    
    init(coverSize: BookCoverSize, book: GoodreadsBook, credential: OAuthSwiftCredential) {
        self.book = book
        self.coverSize = coverSize
        self.client = GoodreadsClient(credential: credential)
        super.init(delay: 0.0, isDelayedAfter: false)
    }
    
    override func execute() {
        if isCancelled { return }
        
        if book.hasValidCoverImage(for: coverSize) {
            do {
                let url = URL(string: book.coverImageUrl(for: coverSize))!
                let data = try Data(contentsOf: url)
                if isCancelled { return }
                
                if data.isEmpty {
                    book.setDownloadState(.failed, forSize: coverSize)
                    book.setCoverImage(#imageLiteral(resourceName: "BookCover"), forSize: coverSize)
                    finish()
                } else {
                    let image = UIImage(data: data)!
                    book.setCoverImage(image, forSize: coverSize)
                    book.setDownloadState(.downloaded, forSize: coverSize)
                    finish()
                }
            } catch {
                book.setDownloadState(.failed, forSize: coverSize)
                book.setCoverImage(#imageLiteral(resourceName: "BookCover"), forSize: coverSize)
                finish()
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
                            self.book.setDownloadState(.failed, forSize: self.coverSize)
                            self.book.setCoverImage(#imageLiteral(resourceName: "BookCover"), forSize: self.coverSize)
                            self.finish()
                        } else {
                            let image = UIImage(data: data)!
                            self.book.setCoverImage(image, forSize: self.coverSize)
                            self.book.setDownloadState(.downloaded, forSize: self.coverSize)
                            self.finish()
                        }
                    } catch {
                        self.book.setDownloadState(.failed, forSize: self.coverSize)
                        self.book.setCoverImage(#imageLiteral(resourceName: "BookCover"), forSize: self.coverSize)
                        self.finish()
                    }
                case .failure(let error):
                    switch error {
                    case .clientThrottled:
                        self.book.imageDownloadState = .throttled
                        self.book.setDownloadState(.throttled, forSize: self.coverSize)
                    default:
                        self.book.setDownloadState(.failed, forSize: self.coverSize)
                    }
                    self.book.setCoverImage(#imageLiteral(resourceName: "BookCover"), forSize: self.coverSize)
                    self.finish()
                }
            }
        }
    }
}

