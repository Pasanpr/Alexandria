//
//  CardDismissingAnimationController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 8/4/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class CardDismissingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Private
    private let duration: TimeInterval?
    private let animation: TransitionAnimation?
    private let completion: TransitionCompletion?
    
    init(duration: TimeInterval?, animation: TransitionAnimation?, completion: TransitionCompletion?) {
        self.duration = duration
        self.animation = animation
        self.completion = completion
        super.init()
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration ?? 0.3
    }
}
