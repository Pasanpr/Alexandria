//
//  AuthenticationCoordinator.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 7/3/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import Foundation
import UIKit
import OAuthSwift

extension OAuthSwiftError {
    var debugDescription: String {
        switch self {
        case .accessDenied(let error, let request):
            return "Access denied."
        case .configurationError(let message): return "Error code: \(self.errorCode). Configuration problem with oauth provider. Message: \(message)"
        case .tokenExpired(let error): return "Error code: \(self.errorCode). The provided token is expired, retrieve new token by using the refresh token. Error: \(error!)"
        case .missingState: return "Error code: \(self.errorCode). State missing from request (you can set allowMissingStateCheck = true to ignore)"
        case .stateNotEqual(let state, let responseState): return "Error code: \(self.errorCode). Returned state value is wrong. State: \(state.description). Response State: \(responseState)"
        case .serverError(let message): return "Error code: \(self.errorCode). Error from server. Message: \(message)"
        case .encodingError(let urlString): return "Error code: \(self.errorCode). Failed to create URL \(urlString) not convertible to URL, please encode"
        case .authorizationPending: return "Error code: \(self.errorCode). Authorization pending"
        case .requestCreation(let message): return "Error code: \(self.errorCode). Failed to create request with URL String. Message: \(message)"
        case .missingToken: return "Error code: \(self.errorCode). Authentification failed. No token"
        case .retain: return "Error code: \(self.errorCode). Please retain OAuthSwift object or handle"
        case .requestError(let error, let request): return "Error code: \(self.errorCode). Request error. Error: \(error) with request: \(request.description)"
        case .cancelled: return "Error code: \(self.errorCode). Request cancelled"
        case .slowDown(let error, let request):
            return "Slow Down"
        }
    }
}

enum AuthenticationError: Error {
    case oauthError(message: String)
    case keychainError(message: String)
}

protocol AuthenticationCoordinatorDelegate: class {
    func authenticationSucceededWithCredential(_ credential: OAuthSwiftCredential, for coordinator: AuthenticationCoordinator)
    func authenticationFailedWithError(_ error: AuthenticationError, for coordinator: AuthenticationCoordinator)
}

final class AuthenticationCoordinator: Coordinator {
    let navigationController: UINavigationController
    var childCoordinators: [Coordinator] = []
    weak var delegate: AuthenticationCoordinatorDelegate?
    
    let loginVC = LoginViewController()
    
    let oauth = OAuth1Swift(consumerKey: "W5hTqI7W67YlUbvVOXccRw", consumerSecret: "kJw7xZpiPPyRijwE5BMB5la9XZUunAAZ73k0THWJo", requestTokenUrl: "https://www.goodreads.com/oauth/request_token", authorizeUrl: "https://goodreads.com/oauth/authorize?mobile=1", accessTokenUrl: "https://www.goodreads.com/oauth/access_token")
    
    init(navigationController: UINavigationController, delegate: AuthenticationCoordinatorDelegate?) {
        self.navigationController = navigationController
        self.delegate = delegate
        
        oauth.authorizeURLHandler = SafariURLHandler(viewController: loginVC, oauthSwift: self.oauth)
        oauth.allowMissingOAuthVerifier = true
    }
    
    func start() {
        loginVC.button.addTarget(self, action: #selector(AuthenticationCoordinator.authorize), for: .touchUpInside)
        navigationController.present(loginVC, animated: true, completion: nil)
    }
    
    func dismiss() {
        loginVC.dismiss(animated: true, completion: nil)
    }
    
    @objc func authorize() {
        let _ = oauth.authorize(
            withCallbackURL: URL(string: "alexandria://oauth-callback/goodreads")!,
            success: { [unowned self] credential, response, parameters in
                let account = GoodreadsAccount(credential: credential)
                do {
                    try account.save()
                } catch let keychainError {
                    let error = AuthenticationError.keychainError(message: keychainError.localizedDescription)
                    self.delegate?.authenticationFailedWithError(error, for: self)
                }
                
                self.delegate?.authenticationSucceededWithCredential(credential, for: self)
        },
            failure: { [unowned self] error in
                let authError = AuthenticationError.oauthError(message: error.debugDescription)
                self.delegate?.authenticationFailedWithError(authError, for: self)
        }
        )
    }
}
