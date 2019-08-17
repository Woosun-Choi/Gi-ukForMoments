//
//  PresentationAnimator.swift
//  linearCollectionViewTest
//
//  Created by goya on 02/01/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class FrameTransitionDelegate_PresentingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    init(targetRect: CGRect) {
        openingFrame = targetRect
    }
    
    convenience init(targetRect: CGRect, setBeforeAnimate: ((UIViewController) -> Void)?, setAfterAnimate: ((UIViewController) -> Void)?) {
        self.init(targetRect: targetRect)
    }
    
    var animateDuration: TimeInterval = 0.5
    
    var animationCurveStyle: UIView.AnimationOptions?
    
    private var openingFrame: CGRect?
    
    var initialActionForController_presenting : ((UIViewController) -> Void)?
    
    var finalActionForController_presenting : ((UIViewController) -> Void)?
    
    var initialActionForController_presented : ((UIViewController) -> Void)?
    
    var finalActionForController_presented : ((UIViewController) -> Void)?
    
    var completionActionForController_presented : ((UIViewController) -> Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animateDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let originFrame = openingFrame,
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        
        let containerView = transitionContext.containerView
        
        let animationDuration = self.transitionDuration(using: transitionContext)
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        initialActionForController_presenting?(fromViewController)
        initialActionForController_presented?(toViewController)
        toViewController.view.frame = originFrame
        toViewController.view.layoutIfNeeded()
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: (animationCurveStyle ?? .curveEaseOut), animations: {
            toViewController.view.frame = finalFrame
            self.finalActionForController_presenting?(fromViewController)
            self.finalActionForController_presented?(toViewController)
            toViewController.view.layoutIfNeeded()
        }) { (finished) in
            self.completionActionForController_presented?(toViewController)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

//MARK: snapshot version transition

//        if let myView = toViewController as? ImageDetailView {
//            targetFrom = myView.imageView.bounds
//        }

//        let snapshotView = toViewController.view.resizableSnapshotView(from: targetFrom, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
//        snapshotView?.frame = openingFrame!
//        containerView.addSubview(snapshotView!)
//
//        toViewController.view.alpha = 0.0
//        containerView.addSubview(toViewController.view)
//
//        UIView.animate(withDuration: animationDuration, delay: 0.0, options: .curveEaseInOut, animations: {
//            snapshotView!.frame = fromViewController.view.frame
//            let originalWidth = (snapshotView?.frame.width)!
//            let originalHeight = (snapshotView?.frame.height)!
//            let ratio = toViewController.view.frame.width / originalWidth
//            let newSize = CGSize(width: toViewController.view.frame.width, height: originalHeight * ratio)
//            snapshotView?.frame = CGRect(origin: fromViewController.view.frame.origin, size: newSize)
//            fromViewController.view.alpha = 0
//        }) { (finished) in
//            toViewController.view.alpha = 1.0
//            UIView.animate(withDuration: 0.25, animations: {
//                targetView.view.backgroundColor = UIColor.white
//            }) { (finished) in
//                snapshotView?.removeFromSuperview()
//                transitionContext.completeTransition(finished)
//            }
//        }
