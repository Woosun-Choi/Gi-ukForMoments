//
//  TransitionManager.swift
//  Gi-ukForMoments
//
//  Created by goya on 23/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit


class TransitionManager: UIPercentDrivenInteractiveTransition, UIViewControllerTransitioningDelegate {
    
    let dismissalAnimator = TransitionManager_DismissAnimator()
    
    func a() {
    }
}

class TransitionManager_DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var animateDuration: TimeInterval = 0.5
    
    var animationCurveStyle: UIView.AnimationOptions = .curveEaseInOut
    
    var initialActionForController_presenting : ((UIViewController) -> Void)?
    
    var finalActionForController_presenting : ((UIViewController) -> Void)?
    
    var initialActionForController_presented : ((UIViewController) -> Void)?
    
    var finalActionForController_presented : ((UIViewController) -> Void)?
    
    var completionActionForController_presented : ((UIViewController) -> Void)?
    
    typealias transitionViews = (toView: UIViewController, fromView: UIViewController)
    
    internal typealias toView = (UIViewController)
    internal typealias fromView = (UIViewController)
    
    var transitionActions : ((toView,fromView) -> Void)?
    
    var transitionAction : ((transitionViews) -> Void)?
    
    func setTrans(toViewAction: @escaping ((UIViewController) -> Void)) {
        transitionAction = { (views) in
            toViewAction(views.toView)
            views.toView
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animateDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            else { return }
        
        let containerView = transitionContext.containerView
        
        let animationDuration = self.transitionDuration(using: transitionContext)
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        
        transitionAction?((toViewController,fromViewController))
        
        initialActionForController_presenting?(fromViewController)
        initialActionForController_presented?(toViewController)
        toViewController.view.layoutIfNeeded()
        containerView.addSubview(toViewController.view)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: (animationCurveStyle), animations: {
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
