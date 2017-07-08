//
//  BookCoverDownloadOperation.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/7/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import OAuthSwift

final class BookCoverDownloadOperation: AsynchronousOperation {
    let book: GoodreadsBook
    let client: GoodreadsClient
    
    init(book: GoodreadsBook, credential: OAuthSwiftCredential) {
        self.book = book
        self.client = GoodreadsClient(credential: credential)
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
            client.searchBooks(query: book.title, searchField: .title) { result in
                switch result {
                case .success(let works):
                    let worksWithImages = works.filter({ $0.hasValidImage })
                    
                    if worksWithImages.isEmpty {
                        self.book.imageDownloadState = .failed
                        self.finish()
                    }
                    
                    guard let bestCaseWork = worksWithImages.filter({ $0.hasReview }).first else {
                        self.book.imageDownloadState = .failed
                        self.finish()
                        return
                    }
                    
                    do {
                        let url = URL(string: bestCaseWork.bestBook.imageUrl)!
                        let data = try Data(contentsOf: url)
                        if self.isCancelled { self.finish() }
                        
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
                    self.book.image = #imageLiteral(resourceName: "BookCover")
                    self.book.imageDownloadState = .failed
                    self.finish()
                }
            }
        }
    }
}

