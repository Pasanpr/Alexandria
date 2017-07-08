//
//  SmallBookCoverDownloadOperation.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/7/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class SmallBookCoverDownloadOperation: Operation {
    
    let book: GoodreadsBook
    
    init(book: GoodreadsBook) {
        self.book = book
    }
    
    override func main() {
        if isCancelled { return }
        
        do {
            let url = URL(string: book.smallImageUrl)!
            let data = try Data(contentsOf: url)
            if isCancelled { return }
            
            if data.isEmpty {
                book.smallImageDownloadState = .failed
                book.smallImage = #imageLiteral(resourceName: "BookCover")
                cancel()
                return
            } else {
                let image = UIImage(data: data)!
                book.smallImage = image
                book.smallImageDownloadState = .downloaded
            }
        } catch {
            book.smallImageDownloadState = .failed
            book.smallImage = #imageLiteral(resourceName: "BookCover")
            cancel()
            return
        }
    }
}
