//
//  CardTransitionDelegate.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 8/4/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

typealias TransitionAnimation = () -> ()
typealias TransitionCompletion = (Bool) -> ()

final class CardTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    var isDismissEnabled = true
    
    // MARK: - Private
    
    private let presentDuration: TimeInterval?
    private let presentAnimation: TransitionAnimation?
    private let presentCompletion: TransitionCompletion?
    private let dismissDuration: TimeInterval?
    private let dismissAnimation: TransitionAnimation?
    private let dismissCompletion: TransitionCompletion?
    
    init(presentDuration: TimeInterval? = nil, presentAnimation: TransitionAnimation? = nil, presentCompletion: TransitionCompletion? = nil, dismissDuration: TimeInterval? = nil, dismissAnimation: TransitionAnimation? = nil, dismissCompletion: TransitionCompletion? = nil) {
        
        self.presentDuration = presentDuration
        self.presentAnimation = presentAnimation
        self.presentCompletion = presentCompletion
        self.dismissDuration = dismissDuration
        self.dismissAnimation = dismissAnimation
        self.dismissCompletion = dismissCompletion
        
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardPresentingAnimationController(duration: presentDuration, animation: presentAnimation, completion: presentCompletion)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CardDismissingAnimationController(duration: dismissDuration, animation: dismissAnimation, completion: dismissCompletion)
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return CardPresentationController(presentedViewController: presented, presenting: presenting, presentAnimation: presentAnimation, presentCompletion: presentCompletion, dismissAnimation: dismissAnimation, dismissCompletion: dismissCompletion)
    }
}
