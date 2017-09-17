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

final class CardPresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    
    // MARK: - Constants
    
    let padding: CGFloat = 8
    
    lazy var offset: CGFloat = {
       return self.presentingViewController.view.safeAreaInsets.top + self.padding
    }()
    
    // MARK: - Internal
    
    var transitioningDelegate: CardPresentationControllerDelegate?
    var pan: UIPanGestureRecognizer?
    
    // MARK: - Private
    
    private var backgroundView: UIView?
    
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
            pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            pan!.delegate = self
            pan!.maximumNumberOfTouches = 1
            presentedViewController.view.addGestureRecognizer(pan!)
        }
        
        presentCompletion?(completed)
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
//                self.updateSnapshotViewAspectRatio()
            }, completion: { _ in
//                self.updateSnapshotView()
        }
        )
    }
    
    @objc private func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        guard gestureRecognizer.isEqual(pan) else {
            return
        }
        
        switch gestureRecognizer.state {
            
        case .began:
            gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: containerView)
            
        case .changed:
            if let view = presentedView {
                /// The dismiss gesture needs to be enabled for the pan gesture
                /// to do anything.
                if transitioningDelegate?.isDismissGestureEnabled() ?? false {
                    let translation = gestureRecognizer.translation(in: view)
                    updatePresentedViewForTranslation(inVerticalDirection: translation.y)
                } else {
                    gestureRecognizer.setTranslation(.zero, in: view)
                }
            }
            
        case .ended:
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self.presentedView?.transform = .identity
            }
            )
            
        default: break
        }
    }
        
    private func updatePresentedViewForTranslation(inVerticalDirection translation: CGFloat) {
        let elasticThreshold: CGFloat = 120.0
        let dismissThreshold: CGFloat = 240.0
        let translationFactor: CGFloat = 1/2
        
        if translation >= 0 {
            let translationForModal: CGFloat = {
                if translation >= elasticThreshold {
                    let frictionLength = translation - elasticThreshold
                    let frictionTranslation = 30 * atan(frictionLength/120) + frictionLength/10
                    return frictionTranslation + (elasticThreshold * translationFactor)
                } else {
                    return translation * translationFactor
                }
            }()
            
            presentedView?.transform = CGAffineTransform(translationX: 0, y: translationForModal)
            
            if translation >= dismissThreshold {
                presentedViewController.dismiss(animated: true, completion: nil)
            }
        }
    }
        
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer.isEqual(pan) else {
            return false
        }
        
        return true
    }
}
