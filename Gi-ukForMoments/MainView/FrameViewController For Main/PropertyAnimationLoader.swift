//
//  PropertyAnimationLoader.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class PropertyAnimationLoader {
    enum AnimationState {
        case normal
        case topContainerMode
        case rightContainerMode
        case settingMenuContainerMode
    }
    
    enum AnimationCondition {
        case extended
        case collapsed
    }
    
    var animationState: AnimationState = .normal
    
    var animationCondition: AnimationCondition {
        if animationState == .normal {
            return .collapsed
        } else {
            return .extended
        }
    }
    
    private var runningAnimations = [UIViewPropertyAnimator]()
    
    private var animationProgressWhenInterrupted: CGFloat = 0
    
    var settings_BeforeAnimationStarts: ((AnimationState) -> Void)?
    
    var settings_Animations: ((AnimationState) -> Void)?
    
    var settings_Completion: ((AnimationState) -> Void)?
    
    func startInteractiveTransition(state: PropertyAnimationLoader.AnimationState, duration: TimeInterval, completion: (()->Void)? = nil) {
        if runningAnimations.isEmpty {
            animationTranstionIfNeeded(state: state, duration: duration, completion: completion)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateTranstion(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func endTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    func animationTranstionIfNeeded(state: PropertyAnimationLoader.AnimationState, duration: TimeInterval, animationCurve: UIView.AnimationCurve = .easeOut, completion: (()->Void)? = nil) {
        if runningAnimations.isEmpty {
            
            //pepareAction()
            settings_BeforeAnimationStarts?(state)
            
            let frameAnimator = UIViewPropertyAnimator(duration: duration, curve: animationCurve) {
                self.settings_Animations?(state)
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            //when animation ended
            frameAnimator.addCompletion { [unowned self] (_) in
                self.runningAnimations.removeAll()
                self.settings_Completion?(state)
            }
            //
        }
    }
}
