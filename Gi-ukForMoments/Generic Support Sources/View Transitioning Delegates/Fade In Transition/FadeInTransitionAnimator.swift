//
//  FadeInTransitionAnimator.swift
//  Gi-ukForMoments
//
//  Created by goya on 17/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class FadeInTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
//    var interactive = false
    
//    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return self.interactive ? self : nil
//    }
//
//    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        return self.interactive ? self : nil
//    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInTransitioningAnimator(isPresenting: false)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return FadeInTransitioningAnimator(isPresenting: true)
    }
}

class FadeInTransitioningAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPresenting: Bool = true
    
    var animationCurveStyle: UIView.AnimationOptions?
    
    var animateDuration: TimeInterval = 0.35
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animateDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            , let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        let contentContainer = transitionContext.containerView
        let animationDuration = transitionDuration(using: transitionContext)
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let preferredFrame = preferredOpeningFrame(finalFrame)
        
        if isPresenting {
            toViewController.view.frame = preferredFrame
            toViewController.view.alpha = 0
            toViewController.view.layoutIfNeeded()
        }
        
        if isPresenting {
            contentContainer.addSubview(toViewController.view)
        } else {
//            contentContainer.addSubview(toViewController.view)
//            contentContainer.addSubview(fromViewController.view)
        }
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: (animationCurveStyle ?? .curveEaseInOut), animations: {
            if self.isPresenting {
                toViewController.view.frame = finalFrame
                toViewController.view.alpha = 1
                toViewController.view.layoutIfNeeded()
            } else {
                fromViewController.view.frame = preferredFrame
                fromViewController.view.alpha = 0
                fromViewController.view.layoutIfNeeded()
            }
        }) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    private func preferredOpeningFrame(_ fromView: CGRect) -> CGRect {
        let factorFrame = fromView
        let viewRatio = factorFrame.width/factorFrame.height
        let preferredWidth = factorFrame.width * 1.1
        let preferredHeight = preferredWidth/viewRatio
        let preferredOriginX = (factorFrame.width - preferredWidth)/2
        let preferredOriginY = (factorFrame.height - preferredHeight)/2
        return CGRect(x: preferredOriginX, y: preferredOriginY, width: preferredWidth, height: preferredHeight)
    }
    
    convenience init(isPresenting: Bool) {
        self.init()
        self.isPresenting = isPresenting
    }
}
