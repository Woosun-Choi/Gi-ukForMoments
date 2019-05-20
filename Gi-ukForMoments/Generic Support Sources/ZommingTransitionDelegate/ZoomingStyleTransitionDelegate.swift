//
//  TransitionDelegate.swift
//  linearCollectionViewTest
//
//  Created by goya on 02/01/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol ZoomingStyleTransitionDataSource {
    
    @objc optional func preparePresenting(_ viewController: UIViewController) -> Void
    
    @objc optional func finishPresenting(_ viewController: UIViewController) -> Void
    
    @objc optional func prepareDismissing(_ viewController: UIViewController) -> Void
    
    @objc optional func finishDismissing(_ viewController: UIViewController) -> Void
    
}

@objc protocol ZoomingStyleInteractionTransitionDataSource {
    
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

class ZoomingStyleTransitioningDelegate: UIPercentDrivenInteractiveTransition, UIViewControllerTransitioningDelegate {
    
    private var openingFrame: CGRect?
    
    var interactive = false
    
    var interationSourceViewController : UIViewController? {
        didSet {
            if let dataSource = interationSourceViewController as? ZoomingStyleInteractionTransitionDataSource,
                let targetView = interationSourceViewController {
                configureInteractions(viewController: targetView)
                interactionCompletion = {
                    dataSource.completionAction_ForInterationEnded?(view: targetView)
                }
            }
        }
    }
    
    private var interactionCompletion: (() -> Void)?
    
    private func configureInteractions(viewController: UIViewController) {
        guard let targetView = viewController as? ZoomingStyleInteractionTransitionDataSource else { return }
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handleOnstagePan(pan:)))
        (targetView.interactiveActionViewForAnimation(view: viewController) != nil) ? targetView.interactiveActionViewForAnimation(view: viewController)?.addGestureRecognizer(gesture) : viewController.view.addGestureRecognizer(gesture)
    }
    
    @objc private func handleOnstagePan(pan: UIPanGestureRecognizer){
        
        let translation = pan.translation(in: pan.view)
        
        let targetRect = pan.view!.bounds
        
        var percent : CGFloat = 0
        
        guard let targetView = interationSourceViewController else {
            return
        }
        
        guard let controlData = targetView as? ZoomingStyleInteractionTransitionDataSource else {
            print("control nil")
            return
        }
        
        switch controlData.scrollDirection {
        case .down:
            percent = (translation.y / targetRect.height)
        case .up:
            percent = -(translation.y / targetRect.height)
        case .left:
            percent = (translation.x / targetRect.width)
        case .right:
            percent = -(translation.x / targetRect.width)
        }
        
        switch (pan.state) {
            
        case .began:
            self.interactive = true
            if controlData.interactiveActionType == .dismiss {
                targetView.dismiss(animated: true, completion: { [weak self] in
                    self?.interactionCompletion?()
                })
            } else {
                guard let identifire = controlData.performSegueIdentifire(view: nil) else {return}
                interationSourceViewController?.performSegue(withIdentifier: identifire, sender: self)
            }
        case .changed:
            update(percent)
        case .ended:
            (percent > 0.4) ? finish() : cancel()
            self.interactive = false
        default:
            break
        }
    }
    
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
        guard let dismissTarget = openingFrame else { return nil }
        let dismissAnimator = ZommingTransitionDelegate_DismissAnimator(targetRect: dismissTarget)
        if let datasourceDelivered = dismissed as? ZoomingStyleTransitionDataSource {
            dismissAnimator.convenienceTargetViewOriginSetting = {
                (controller) in
                datasourceDelivered.prepareDismissing?(controller)
            }
            dismissAnimator.convenienceTargetViewFinalSetting = {
                (controller) in
                datasourceDelivered.finishDismissing?(controller)
            }
        }
        return dismissAnimator
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let presentingTarget = openingFrame else { return nil }
        let presentationAnimator = ZommingTransitionDelegate_PresentingAnimator(targetRect: presentingTarget)
        if let datasourceDelivered = presented as? ZoomingStyleTransitionDataSource {
            presentationAnimator.convenienceTargetViewOriginSetting = {
                (controller) in
                datasourceDelivered.preparePresenting?(controller)
            }
            presentationAnimator.convenienceTargetViewFinalSetting = {
                (controller) in
                datasourceDelivered.finishPresenting?(controller)
            }
        }
        return presentationAnimator
    }
}


