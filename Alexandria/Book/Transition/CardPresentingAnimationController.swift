//
//  CardPresentingAnimationController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 8/4/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

final class CardPresentingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
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
        let presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        
        let containerView = transitionContext.containerView
        
        
        let offscreenFrame = CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: containerView.bounds.height)
        
        containerView.addSubview(presentingViewController.view)
        containerView.addSubview(presentedViewController.view)
        presentedViewController.view.frame = offscreenFrame
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut,
            animations: { [weak self] in
                let scale: CGFloat = 1 - (40/presentingViewController.view.frame.height)
                presentingViewController.view.alpha = 0.8
                presentingViewController.view.transform = CGAffineTransform(scaleX: scale, y: scale)
                presentingViewController.view.round(corners: [.topLeft, .topRight], withRadius: 8)
                
                presentingViewController.additionalSafeAreaInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
                presentingViewController.view.layer.masksToBounds = true
                
                presentedViewController.view.frame = transitionContext.finalFrame(for: presentedViewController)
                presentedViewController.view.round(corners: [.topLeft, .topRight], withRadius: 8)
                self?.animation?()
        },
            completion: { [weak self] finished in
                transitionContext.completeTransition(finished)
                self?.completion?(finished)
                
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration ?? 0.3
    }
}
