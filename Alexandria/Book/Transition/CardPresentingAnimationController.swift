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
    
    private var presentingViewSnapshotView = UIView()
    private var cachedContainerWidth: CGFloat = 0
    private var aspectRatioConstraint: NSLayoutConstraint?
    
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
        
        updateSnapshotView(using: transitionContext)
        presentingViewSnapshotView.frame = containerView.frame
        containerView.addSubview(presentingViewSnapshotView)
        containerView.addSubview(presentedViewController.view)
        presentedViewController.view.frame = offscreenFrame
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0,
            options: .curveEaseOut,
            animations: { [weak self] in
                let scale: CGFloat = 1 - (40/presentingViewController.view.frame.height)
                self?.presentingViewSnapshotView.alpha = 0.8
                self?.presentingViewSnapshotView.transform = CGAffineTransform(scaleX: scale, y: scale)
                self?.presentingViewSnapshotView.round(corners: [.topLeft, .topRight], withRadius: 8)

                // FIXME: UINavigationController bug
                // https://openradar.appspot.com/33794596
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
    
    private func updateSnapshotView(using transitionContext: UIViewControllerContextTransitioning) {
        
        let presentingViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        
        updateSnapshotViewAspectRatio(with: transitionContext.containerView)
        
        if let snapshotView = presentingViewController.view.snapshotView(afterScreenUpdates: true) {
            presentingViewSnapshotView.subviews.forEach { $0.removeFromSuperview() }
            
            snapshotView.translatesAutoresizingMaskIntoConstraints = false
            presentingViewSnapshotView.round(corners: [.topLeft, .topRight], withRadius: 8)
            presentingViewSnapshotView.addSubview(snapshotView)
            
            NSLayoutConstraint.activate([
                snapshotView.topAnchor.constraint(equalTo: presentingViewSnapshotView.topAnchor),
                snapshotView.leftAnchor.constraint(equalTo: presentingViewSnapshotView.leftAnchor),
                snapshotView.rightAnchor.constraint(equalTo: presentingViewSnapshotView.rightAnchor),
                snapshotView.bottomAnchor.constraint(equalTo: presentingViewSnapshotView.bottomAnchor),
                ])
        }
    }
    
    private func updateSnapshotViewAspectRatio(with containerView: UIView) {
        guard cachedContainerWidth != containerView.bounds.width else { return }
        
        cachedContainerWidth = containerView.bounds.width
        aspectRatioConstraint?.isActive = false
        
        let aspectRatio = containerView.bounds.width / containerView.bounds.height
        aspectRatioConstraint = presentingViewSnapshotView.widthAnchor.constraint(equalTo: presentingViewSnapshotView.heightAnchor, multiplier: aspectRatio)
        aspectRatioConstraint?.isActive = true
    }
}
