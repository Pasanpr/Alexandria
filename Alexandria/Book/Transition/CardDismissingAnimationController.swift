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
        let presentingViewController = transitionContext.viewController(forKey: .to)!
        let presentedViewController = transitionContext.viewController(forKey: .from)!
        
        let containerView = transitionContext.containerView
        
        let offscreenFrame = CGRect(x: 0, y: containerView.bounds.height, width: containerView.bounds.width, height: containerView.bounds.height)
        
        let indexOfPresentedView = containerView.subviews.index(of: presentedViewController.view)!
        let indexOfSnapshotView = containerView.subviews.index(before: indexOfPresentedView)
        let snapshotView = containerView.subviews[indexOfSnapshotView]
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut,
            animations: {
                
                // FIXME: UINavigationController bug
                // https://openradar.appspot.com/33794596
                presentingViewController.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

                snapshotView.alpha = 1
                snapshotView.round(corners: [.topLeft, .topRight], withRadius: 0)
                snapshotView.transform = .identity
                snapshotView.frame = transitionContext.finalFrame(for: presentingViewController)
                presentingViewController.view.frame = transitionContext.finalFrame(for: presentingViewController)

                presentedViewController.view.frame = offscreenFrame
                self.animation?()
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
