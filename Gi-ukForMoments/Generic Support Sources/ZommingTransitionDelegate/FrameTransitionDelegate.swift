//
//  TransitionDelegate.swift
//  linearCollectionViewTest
//
//  Created by goya on 02/01/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol FrameTransitionDataSource {
    
    @objc optional func initialAction_FromViewController(_ viewController: UIViewController) -> Void
    
    @objc optional func initialAction_ToViewController(_ viewController: UIViewController) -> Void
    
    @objc optional func finalAction_FromViewController(_ viewController: UIViewController) -> Void
    
    @objc optional func finalAction_ToViewController(_ viewController: UIViewController) -> Void
    
    @objc optional func completionAction_ToViewController(_ viewController: UIViewController) -> Void
    
}

@objc protocol FrameTransitionInteractionDataSource {
    
    func interactiveActionViewForAnimation(view: UIViewController?) -> UIView?
    
    func performSegueIdentifire(view: UIViewController?) -> String?
    
    var interactiveActionType : ZoomingStyleInteractionTransitionActionType { get }
    
    var scrollDirection : ZoomingStyleInteractionTransitionScrollType { get }
    
    @objc optional func completionAction_ForInterationEnded(view: UIViewController?)
}

@objc enum ZoomingStyleInteractionTransitionActionType: Int {
    case dismiss
    case present
}

@objc enum ZoomingStyleInteractionTransitionScrollType: Int {
    case up
    case down
    case left
    case right
}

class FrameTransitioningDelegate: UIPercentDrivenInteractiveTransition, UIViewControllerTransitioningDelegate {
    
    private var openingFrame: CGRect?
    
    var interactive = false
    
    var presentAnimationCurveStyle : UIView.AnimationOptions?
    
    var dismissAnimationCurveStyle: UIView.AnimationOptions?
    
    var animationDuration: TimeInterval = 0.5
    
    func setOpeningFrameWithRect(_ target: CGRect) {
        openingFrame = target
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactive ? self : nil
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("dismiss animator setted")
        guard let dismissTarget = openingFrame else { return nil }
        let dismissAnimator = FrameTransitionDelegate_DismissAnimator(targetRect: dismissTarget)
        if let datasourceDelivered = dismissed as? FrameTransitionDataSource {
            
            dismissAnimator.initialActionForController_Dismissed = {
                (controller) in
                datasourceDelivered.initialAction_FromViewController?(controller)
            }
            dismissAnimator.finalActionForController_Dismissed = {
                (controller) in
                datasourceDelivered.finalAction_FromViewController?(controller)
            }
            dismissAnimator.initialActionForController_Represented = {
                (controller) in
                datasourceDelivered.initialAction_ToViewController?(controller)
            }
            dismissAnimator.finalActionForController_Represented = {
                (controller) in
                datasourceDelivered.finalAction_ToViewController?(controller)
            }
            dismissAnimator.completionActionForController_Represented = {
                (controller) in
                datasourceDelivered.completionAction_ToViewController?(controller)
            }
        }
        dismissAnimator.animateDuration = animationDuration
        dismissAnimator.animationCurveStyle = dismissAnimationCurveStyle
        return dismissAnimator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let presentingTarget = openingFrame else { return nil }
        let presentationAnimator = FrameTransitionDelegate_PresentingAnimator(targetRect: presentingTarget)
        if let datasourceDelivered = presenting as? FrameTransitionDataSource {
            
            presentationAnimator.initialActionForController_presenting = {
                (controller) in
                datasourceDelivered.initialAction_FromViewController?(controller)
            }
            presentationAnimator.initialActionForController_presented = {
                (controller) in
                datasourceDelivered.initialAction_ToViewController?(controller)
            }
            presentationAnimator.finalActionForController_presenting = {
                (controller) in
                datasourceDelivered.finalAction_FromViewController?(controller)
            }
            presentationAnimator.finalActionForController_presented = {
                (controller) in
                datasourceDelivered.finalAction_ToViewController?(controller)
            }
            presentationAnimator.completionActionForController_presented = {
                (controller) in
                datasourceDelivered.completionAction_ToViewController?(controller)
            }
        }
        presentationAnimator.animateDuration = animationDuration
        presentationAnimator.animationCurveStyle = presentAnimationCurveStyle
        return presentationAnimator
    }
}


//weak var tarnsitionDataSource: FrameTransitionDataSource?
//
//var interationSourceViewController : UIViewController? {
//    didSet {
//        if let dataSource = interationSourceViewController as? FrameTransitionInteractionDataSource,
//            let targetView = interationSourceViewController {
//            configureInteractions(viewController: targetView)
//            interactionCompletion = {
//                dataSource.completionAction_ForInterationEnded?(view: targetView)
//            }
//        }
//    }
//}
//
//private var interactionCompletion: (() -> Void)?
//
//private func configureInteractions(viewController: UIViewController) {
//    guard let targetView = viewController as? FrameTransitionInteractionDataSource else { return }
//    let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleOnstagePan(pan:)))
//    (targetView.interactiveActionViewForAnimation(view: viewController) != nil) ? targetView.interactiveActionViewForAnimation(view: viewController)?.addGestureRecognizer(gesture) : viewController.view.addGestureRecognizer(gesture)
//}
//
//@objc private func handleOnstagePan(pan: UIPanGestureRecognizer){
//
//    let translation = pan.translation(in: pan.view)
//
//    let targetRect = pan.view!.bounds
//
//    var percent : CGFloat = 0
//
//    guard let targetView = interationSourceViewController else {
//        return
//    }
//
//    guard let controlData = targetView as? FrameTransitionInteractionDataSource else {
//        print("control nil")
//        return
//    }
//
//    switch controlData.scrollDirection {
//    case .down:
//        percent = (translation.y / targetRect.height)
//    case .up:
//        percent = -(translation.y / targetRect.height)
//    case .left:
//        percent = (translation.x / targetRect.width)
//    case .right:
//        percent = -(translation.x / targetRect.width)
//    }
//
//    switch (pan.state) {
//
//    case .began:
//        self.interactive = true
//        if controlData.interactiveActionType == .dismiss {
//            targetView.dismiss(animated: true, completion: { [weak self] in
//                self?.interactionCompletion?()
//            })
//        } else {
//            guard let identifire = controlData.performSegueIdentifire(view: nil) else {return}
//            interationSourceViewController?.performSegue(withIdentifier: identifire, sender: self)
//        }
//    case .changed:
//        update(percent)
//    case .ended:
//        (percent > 0.4) ? finish() : cancel()
//        self.interactive = false
//    default:
//        break
//    }
//}

