//
//  CardPresentationController.swift
//  Alexandria
//
//  Created by Pasan Premaratne on 8/4/17.
//  Copyright © 2017 Pasan Premaratne. All rights reserved.
//

import UIKit

protocol CardPresentationControllerDelegate {
    func isDismissGestureEnabled() -> Bool
}

final class CardPresentationController: UIPresentationController {
    
    // MARK: - Constants
    
    let offset: CGFloat = 28
    
    // MARK: - Internal
    
    var transitioningDelegate: CardPresentationControllerDelegate?
    var pan: UIPanGestureRecognizer?
    
    // MARK: - Private
    
    private var backgroundView: UIView?
    private var presentingViewSnapshotView: UIView?
    private var cachedContainerWidth: CGFloat = 0
    private var aspectRatioConstraint: NSLayoutConstraint?
    
    private var presentAnimation: TransitionAnimation? = nil
    private var presentCompletion: TransitionCompletion? = nil
    private var dismissAnimation: TransitionAnimation? = nil
    private var dismissCompletion: TransitionCompletion? = nil
    
    // MARK: - Initializers
    
    convenience init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, presentAnimation: TransitionAnimation? = nil, presentCompletion: TransitionCompletion? = nil, dismissAnimation: TransitionAnimation? = nil, dismissCompletion: TransitionCompletion? = nil) {
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        self.presentAnimation = presentAnimation
        self.presentCompletion = presentCompletion
        self.dismissAnimation = dismissAnimation
        self.dismissCompletion = dismissCompletion
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        if let view = containerView {
            return CGRect(x: 0, y: offset, width: view.bounds.width, height: view.bounds.height-offset)
        } else {
            return .zero
        }
    }
    
    // MARK: - Presentation
    
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView else { return }
        
        backgroundView = UIView()
        backgroundView!.backgroundColor = .black
        backgroundView!.translatesAutoresizingMaskIntoConstraints = false
        containerView.insertSubview(backgroundView!, at: containerView.subviews.startIndex)
        
        NSLayoutConstraint.activate([
            backgroundView!.topAnchor.constraint(equalTo: containerView.window!.topAnchor),
            backgroundView!.leftAnchor.constraint(equalTo: containerView.window!.leftAnchor),
            backgroundView!.rightAnchor.constraint(equalTo: containerView.window!.rightAnchor),
            backgroundView!.bottomAnchor.constraint(equalTo: containerView.window!.bottomAnchor)
        ])
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if completed {
            presentCompletion?(completed)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(
            alongsideTransition: { [weak self] context in
                guard let `self` = self else {
                    return
                }
                
                let frame = CGRect(x: 0, y: self.offset, width: size.width, height: size.height - self.offset)
                self.presentedViewController.view.frame = frame
                self.presentedViewController.view.mask = nil
                self.presentedViewController.view.round(corners: [.topLeft, .topRight], withRadius: 8)
                self.updateSnapshotViewAspectRatio()
            }, completion: { _ in
                self.updateSnapshotView()
        }
        )
    }
    
    private func updateSnapshotView() {
        guard let presentingViewSnapshotView = presentingViewSnapshotView else { return }
        
        updateSnapshotViewAspectRatio()
        
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
    
    private func updateSnapshotViewAspectRatio() {
        guard let containerView = containerView, let presentingViewSnapshotView = presentingViewSnapshotView, cachedContainerWidth != containerView.bounds.width else { return }
        
        cachedContainerWidth = containerView.bounds.width
        aspectRatioConstraint?.isActive = false
        
        let aspectRatio = containerView.bounds.width / containerView.bounds.height
        aspectRatioConstraint = presentingViewSnapshotView.widthAnchor.constraint(equalTo: presentingViewSnapshotView.heightAnchor, multiplier: aspectRatio)
        aspectRatioConstraint?.isActive = true
    }
}
