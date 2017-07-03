//
//  ViewController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 6/30/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import OAuthSwift
import SWXMLHash

class ViewController: UIViewController {
    
    var goodreadsClient: GoodreadsClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let credential = GoodreadsAccount.oauthSwiftCredential else {
            let lc = LoginViewController()
            present(lc, animated: true, completion: nil)
            return
        }
        
        self.goodreadsClient = GoodreadsClient(credential: credential)
        
        goodreadsClient.userId() { result in
            switch result {
            case .success(let user): print("User id: \(user.id)\nname: \(user.name)\nlink: \(user.link)")
            case .failure(let error): print(error.localizedDescription)
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

