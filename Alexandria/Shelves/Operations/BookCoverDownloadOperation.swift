//
//  BookCoverDownloadOperation.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/7/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import OAuthSwift

final class BookCoverDownloadOperation: DelayAsyncOperation {
    let book: GoodreadsBook
    let client: GoodreadsClient
    
    lazy var amazonClient: AmazonClient = {
        return AmazonClient()
    }()
    
    init(book: GoodreadsBook, credential: OAuthSwiftCredential) {
        self.book = book
        self.client = GoodreadsClient(credential: credential)
        super.init(delay: 0.0, isDelayedAfter: false)
    }
    
    override func execute() {
        if isCancelled { return }
        
        if book.hasValidLargeImage {
            do {
                let url = URL(string: book.largeImageUrl)!
                let data = try Data(contentsOf: url)
                if isCancelled { return }
                
                if data.isEmpty {
                    book.largeImageDownloadState = .failed
                    book.largeImage = #imageLiteral(resourceName: "BookCover")
                    finish()
                } else {
                    let image = UIImage(data: data)!
                    book.largeImage = image
                    book.largeImageDownloadState = .downloaded
                    finish()
                }
            } catch {
                book.largeImageDownloadState = .failed
                book.largeImage = #imageLiteral(resourceName: "BookCover")
                finish()
            }
        } else {
            amazonClient.coverImages(for: book.titleWithoutSeries) { result in
                switch result {
                case .success(let amazonBookCover):
                    
                    self.book.largeImageUrl = amazonBookCover.largeImageUrl!
                    self.book.imageUrl = amazonBookCover.mediumImageUrl!
                    self.book.smallImageUrl = amazonBookCover.smallImageUrl!
                    
                    do {
                        let url = URL(string: self.book.largeImageUrl)!
                        let data = try Data(contentsOf: url)
                        if self.isCancelled { return }
                        
                        if data.isEmpty {
                            self.book.largeImageDownloadState = .failed
                            self.book.largeImage = #imageLiteral(resourceName: "BookCover")
                            self.finish()
                        } else {
                            let image = UIImage(data: data)!
                            self.book.largeImage = image
                            self.book.largeImageDownloadState = .downloaded
                            self.finish()
                        }
                    } catch {
                        self.book.largeImageDownloadState = .failed
                        self.book.largeImage = #imageLiteral(resourceName: "BookCover")
                        self.finish()
                    }
                case .failure(let error):
                    switch error {
                    case .clientThrottled:
                        self.book.largeImageDownloadState = .throttled
                    default:
                        self.book.largeImageDownloadState = .failed
                    }
                    
                    self.book.largeImage = #imageLiteral(resourceName: "BookCover")
                    self.finish()
                }
            }
        }
    }
}

