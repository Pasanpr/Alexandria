//
//  CurrentlyReadingController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class ShelfController: UIViewController {
    
    var onViewDidLoad: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .yellow
        
        if let onViewDidLoad = onViewDidLoad {
            print("Executing onViewDidLoad")
            onViewDidLoad()
        }
    }
}
