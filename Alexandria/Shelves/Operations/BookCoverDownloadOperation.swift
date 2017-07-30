//
//  MediumBookCoverDownloadOperation.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/29/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
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
        
        if book.hasValidImage {
            do {
                let url = URL(string: book.imageUrl)!
                let data = try Data(contentsOf: url)
                if isCancelled { return }
                
                if data.isEmpty {
                    book.imageDownloadState = .failed
                    book.image = #imageLiteral(resourceName: "BookCover")
                    finish()
                } else {
                    let image = UIImage(data: data)!
                    book.image = image
                    book.imageDownloadState = .downloaded
                    finish()
                }
            } catch {
                book.imageDownloadState = .failed
                book.image = #imageLiteral(resourceName: "BookCover")
                finish()
            }
        } else {
            
            let authorsLastName = book.authors.first!.name.words.last!
            let query = book.title.words.count <= 2 ? "\(book.titleWithoutSeries) \(authorsLastName)" : book.titleWithoutSeries
            
            amazonClient.coverImages(for: query) { result in
                switch result {
                case .success(let amazonBookCover):
                    
                    self.book.largeImageUrl = amazonBookCover.largeImageUrl!
                    self.book.imageUrl = amazonBookCover.mediumImageUrl!
                    self.book.smallImageUrl = amazonBookCover.smallImageUrl!
                    
                    do {
                        let url = URL(string: self.book.imageUrl)!
                        let data = try Data(contentsOf: url)
                        if self.isCancelled { return }
                        
                        if data.isEmpty {
                            self.book.imageDownloadState = .failed
                            self.book.image = #imageLiteral(resourceName: "BookCover")
                            self.finish()
                        } else {
                            let image = UIImage(data: data)!
                            self.book.image = image
                            self.book.imageDownloadState = .downloaded
                            self.finish()
                        }
                    } catch {
                        self.book.imageDownloadState = .failed
                        self.book.image = #imageLiteral(resourceName: "BookCover")
                        self.finish()
                    }
                case .failure(let error):
                    switch error {
                    case .clientThrottled:
                        self.book.imageDownloadState = .throttled
                    default:
                        self.book.imageDownloadState = .failed
                    }
                    
                    self.book.image = #imageLiteral(resourceName: "BookCover")
                    self.finish()
                }
            }
        }
    }
}

