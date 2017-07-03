//
//  LoginViewController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/2/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit
import OAuthSwift

class LoginViewController: UIViewController {
    
    let oauth = OAuth1Swift(consumerKey: "W5hTqI7W67YlUbvVOXccRw", consumerSecret: "kJw7xZpiPPyRijwE5BMB5la9XZUunAAZ73k0THWJo", requestTokenUrl: "https://www.goodreads.com/oauth/request_token", authorizeUrl: "https://goodreads.com/oauth/authorize?mobile=1", accessTokenUrl: "https://www.goodreads.com/oauth/access_token")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        oauth.authorizeURLHandler = SafariURLHandler(viewController: self, oauthSwift: self.oauth)
        oauth.allowMissingOAuthVerifier = true
        authorize()
    }
    
    @IBAction func login(_ sender: Any) {
        authorize()
        
    }
    
    func authorize() {
        let _ = oauth.authorize(
            withCallbackURL: URL(string: "alexandria://oauth-callback/goodreads")!,
            success: { credential, response, parameters in
                print("Token: \(credential.oauthToken)")
                print("Secret: \(credential.oauthTokenSecret)")
                print("Refresh Token: \(credential.oauthRefreshToken)")
                print("Token expiration date: \(credential.oauthTokenExpiresAt)")
                
                let goodreads = GoodreadsAccount(secret: credential.oauthTokenSecret, token: credential.oauthToken)
                try! goodreads.save()
                // Do your request
        },
            failure: { error in
                switch error {
                case .configurationError(let message):
                    print("Configuration problem with oauth provider. Message: \(message)")
                case .tokenExpired(let error):
                    print("The provided token is expired, retrieve new token by using the refresh token")
                    if let error = error {
                        print("Error: \(error)")
                    }
                case .missingState: print("State missing from request (you can set allowMissingStateCheck = true to ignore)")
                case .stateNotEqual(let state, let responseState): print("Returned state value is wrong. State: \(state.description). Response State: \(responseState)")
                case .serverError(let message): print("Error from server. Message: \(message)")
                case .encodingError(let urlString): print("Failed to create URL \(urlString) not convertible to URL, please encode")
                case .authorizationPending: print("Authorization pending")
                case .requestCreation(let message): print("Failed to create request with URL String. Message: \(message)")
                case .missingToken: print("Authentification failed. No token")
                case .retain: print("Please retain OAuthSwift object or handle")
                case .requestError(let error, let request): print("Request error. Error: \(error) with request: \(request.description)")
                case .cancelled: print("Request cancelled")
                }
            }
        )
    }
}
