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
        
        NotificationCenter.default.addObserver(self, selector: #selector(CardPresentationController.updateForStatusBar), name: .UIApplicationDidChangeStatusBarFrame, object: nil)
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
        guard let containerView = containerView else { return }
        
        if completed {
            
//            presentedViewController.view.frame = frameOfPresentedViewInContainerView
//            presentedViewController.view.round(corners: [.topLeft, .topRight], withRadius: 8)
//            presentAnimation?()
//
//            presentingViewSnapshotView = UIView()
//            presentingViewSnapshotView?.translatesAutoresizingMaskIntoConstraints = false
//        containerView.insertSubview(presentingViewSnapshotView!, belowSubview: presentingViewController.view)
//
//        NSLayoutConstraint.activate([
//            presentingViewSnapshotView!.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//            presentingViewSnapshotView!.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//            presentingViewSnapshotView!.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: -40)
//            ])
//

//        presentingViewController.view.transform = .identity

//        updateForStatusBar()
        }
    }
    
//    override func presentationTransitionDidEnd(_ completed: Bool) {
//        guard let containerView = containerView else { return }
//
//        updateForStatusBar()
//
//        if completed {
//            presentedViewController.view.frame = frameOfPresentedViewInContainerView
//            presentedViewController.view.round(corners: [.topLeft, .topRight], withRadius: 8)
//            presentAnimation?()
//
//            presentingViewSnapshotView = UIView()
//            presentingViewSnapshotView?.translatesAutoresizingMaskIntoConstraints = false
//            containerView.insertSubview(presentingViewSnapshotView!, belowSubview: presentedViewController.view)
//
//            NSLayoutConstraint.activate([
//                presentingViewSnapshotView!.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
//                presentingViewSnapshotView!.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
//                presentingViewSnapshotView!.heightAnchor.constraint(equalTo: containerView.heightAnchor, constant: -40)
//            ])
//
//            backgroundView = UIView()
//            backgroundView!.backgroundColor = .black
//            backgroundView!.translatesAutoresizingMaskIntoConstraints = false
//            containerView.insertSubview(backgroundView!, belowSubview: presentingViewSnapshotView!)
//
//            NSLayoutConstraint.activate([
//                backgroundView!.topAnchor.constraint(equalTo: containerView.window!.topAnchor),
//                backgroundView!.leftAnchor.constraint(equalTo: containerView.window!.leftAnchor),
//                backgroundView!.rightAnchor.constraint(equalTo: containerView.window!.rightAnchor),
//                backgroundView!.bottomAnchor.constraint(equalTo: containerView.window!.bottomAnchor)
//            ])
//
//            presentingViewController.view.transform = .identity
//        }
//
//        presentCompletion?(completed)
//    }
    
    @objc func updateForStatusBar() {
        print("Update for status bar")
        
        guard let containerView = containerView else { return }
        
//        presentingViewController.view.alpha = 0.0
        
        let fullHeight = containerView.window!.frame.size.height
        let statusBarHeight: CGFloat = {
            let tempHeight = UIApplication.shared.statusBarFrame.height
            if tempHeight >= 20 {
                return tempHeight - 18
            } else {
                return tempHeight
            }
        }()
        
        let newHeight = fullHeight - statusBarHeight
        
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.presentingViewController.view.alpha = 0.8
                containerView.frame = CGRect(x: 0, y: statusBarHeight, width: containerView.frame.width, height: newHeight)
                self?.presentedViewController.view.mask = nil
                self?.presentedViewController.view.round(corners: [.topLeft, .topRight], withRadius: 8)
                
            },
            completion: { [weak self] _ in
//                self?.updateSnapshotView()
        })
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
