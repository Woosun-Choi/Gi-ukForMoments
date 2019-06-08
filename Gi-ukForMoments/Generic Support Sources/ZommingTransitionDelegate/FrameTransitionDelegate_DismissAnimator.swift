//
//  DissmisAnimator.swift
//  linearCollectionViewTest
//
//  Created by goya on 02/01/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class FrameTransitionDelegate_DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    init(targetRect: CGRect) {
        openingFrame = targetRect
    }
    
    convenience init(targetRect: CGRect, setBeforeAnimate: ((UIViewController) -> Void)?, setAfterAnimate: ((UIViewController) -> Void)?) {
        self.init(targetRect: targetRect)
        convenienceTargetViewOriginSetting = setBeforeAnimate
        convenienceTargetViewFinalSetting = setAfterAnimate
    }
    
    private var openingFrame: CGRect?
    
    var fading: Bool = false
    
    var animateDuration: TimeInterval = 0.5
    
    var convenienceTargetViewOriginSetting : ((UIViewController) -> Void)?
    
    var convenienceTargetViewFinalSetting : ((UIViewController) -> Void)?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animateDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let originFrame = openingFrame,
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            , let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        
        let containerView = transitionContext.containerView
        
        let animationDuration = transitionDuration(using: transitionContext)
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        convenienceTargetViewOriginSetting?(fromViewController)
        toViewController.view.frame = finalFrame
        containerView.addSubview(toViewController.view)
        containerView.addSubview(fromViewController.view)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: {
//            toViewController.view.subviews.forEach{ $0.alpha = 1 }
            if self.fading {
                fromViewController.view.alpha = 0
            }
            fromViewController.view.frame = originFrame
            self.convenienceTargetViewFinalSetting?(fromViewController)
            fromViewController.view.layoutIfNeeded()
        }) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

//MARK : snapshot version transition
//        if let myView = fromViewController as? ImageDetailView {
//            targetFrom = myView.imageView.bounds
//        }
//        let snapshotView = fromViewController.view.resizableSnapshotView(from: targetFrom, afterScreenUpdates: true, withCapInsets: UIEdgeInsets.zero)
//        containerView.addSubview(snapshotView ?? UIView())
//
//        //toViewController.view.alpha = 0
//
//        UIView.animate(withDuration: animationDuration * 2, animations: {
//            fromViewController.view.alpha = 0.0
//            snapshotView?.frame = self.openingFrame!
//        }) { (finished) in
//            UIView.animate(withDuration: animationDuration * 2, animations: {
//                //snapshotView?.frame = self.openingFrame!
//                snapshotView?.alpha = 0.0
//                toViewController.view.alpha = 1
//            }) { (finished) in
//                //snapshotView?.alpha = 0.0
//                snapshotView?.removeFromSuperview()
//                fromViewController.view.removeFromSuperview()
//                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
//            }
//        }
