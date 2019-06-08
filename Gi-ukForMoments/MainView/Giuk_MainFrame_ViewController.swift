//
//  Giuk_Main_Test_ViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 30/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class Giuk_MainFrame_ViewController: ContentUIViewController, AnimateButtonViewButtonDataSource {

    var transitionAnimator = FrameTransitioningDelegate()
    
    //MARK: Variables for container views
    private(set) weak var animationView_Top: AnimateButtonView!
    
    private(set) weak var animationView_Right: AnimateButtonView!
    
    private(set) weak var animationView_Setting: AnimateButtonView!
    
    private(set) weak var containerView_MainContent: UIView!
    
    //MARK: Variables for running animations
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
    
    var animationCondition: AnimationCondition = .collapsed
    
    var runningAnimations = [UIViewPropertyAnimator]()
    
    var animationProgressWhenInterrupted: CGFloat = 0
    
    //end

    //MARK: Variables For Buttons
    
    enum buttonLocation: String {
        case top
        case right
        case setting
    }
    
    private var buttons : Dictionary<buttonLocation,[UIButton_WithIdentifire]> =
        [
            buttonLocation.top : [],
            buttonLocation.right : [],
            buttonLocation.setting : []
    ]
    
    private var allButtons: [UIButton_WithIdentifire] {
        let allbuttons = buttons[.top]! + buttons[.right]! + buttons[.setting]!
        return allbuttons
    }
    
    //end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonDataSource()
        transitionAnimator.animationDuration = animationDuration
        view.backgroundColor = .goyaYellowWhite
        setContainers()
        setAnimationView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if animationCondition == .collapsed {
            layoutContainers()
            layoutAnimationView()
        }
    }
    
    //MARK: ContainerView button resources
    
    func containerViewButtonItem(_ containerView: AnimateButtonView) -> [UIButton_WithIdentifire] {
        if containerView == animationView_Top {
            return buttons[.top]!
        } else if containerView == animationView_Right {
            return buttons[.right]!
        } else {
            return buttons[.setting]!
        }
    }
    
    func containerViewButtonAreaRect(_ containerView: AnimateButtonView) -> CGRect {
        if containerView == animationView_Top {
            return containerView_Top_ButtonAreaFrame
        } else if containerView == animationView_Right {
            return containerView_Right_ButtonAreaFrame
        } else {
            return containerView_Setting_ButtonAreaFrame
        }
    }
    
    func buttonsForTopContainerView(target: Any = self ,selector: Selector = #selector(handleOntap(_:)), forEvent: UIControl.Event = .touchUpInside) -> [UIButton_WithIdentifire] {
        var controlButtons = [UIButton_WithIdentifire]()
        let addButton = UIButton_WithIdentifire()
        addButton.identifire = "add"
        addButton.setTitle("+", for: .normal)
        addButton.addTarget(target, action: selector, for: forEvent)
        addButton.backgroundColor = .red
        controlButtons.append(addButton)
        return controlButtons
    }
    
    func buttonsForRightContainerView(target: Any = self ,selector: Selector = #selector(handleOntap(_:)), forEvent: UIControl.Event = .touchUpInside) -> [UIButton_WithIdentifire] {
        var controlButtons = [UIButton_WithIdentifire]()
        let addButton = UIButton_WithIdentifire()
        addButton.identifire = "right"
        addButton.setTitle("#", for: .normal)
        addButton.addTarget(target, action: selector, for: forEvent)
        addButton.backgroundColor = .red
        controlButtons.append(addButton)
        return controlButtons
    }
    
    func buttonsForSettingContainerView(target: Any = self ,selector: Selector = #selector(handleOntap(_:)), forEvent: UIControl.Event = .touchUpInside) -> [UIButton_WithIdentifire] {
        var controlButtons = [UIButton_WithIdentifire]()
        let addButton = UIButton_WithIdentifire()
        addButton.identifire = "setting"
        addButton.setTitle("⚙︎", for: .normal)
        addButton.addTarget(target, action: selector, for: forEvent)
        addButton.backgroundColor = .red
        controlButtons.append(addButton)
        return controlButtons
    }
    
    private func setButtonDataSource() {
        buttons[.top] = buttonsForTopContainerView()
        buttons[.right] = buttonsForRightContainerView()
        buttons[.setting] = buttonsForSettingContainerView()
    }
    
    //end
    
    //MARK: set Sub views - animationViews
    
    private func setContainers() {
        let contentContainer = generateUIView(view: containerView_MainContent, origin: contentAreaOrigin_Start, size: contentAreaSize)
        containerView_MainContent = contentContainer
        containerView_MainContent.isOpaque = false
        containerView_MainContent.backgroundColor = UIColor.clear
        view.addSubview(containerView_MainContent)
    }
    
    private func layoutContainers() {
        containerView_MainContent?.setNewFrame(CGRect(origin: contentAreaOrigin_Start, size: contentAreaSize))
    }
    
    private func setAnimationView() {
        let topAnimationView = generateUIView(view: animationView_Top, origin: topAnimationViewStartFrame.origin, size: topAnimationViewStartFrame.size)
        animationView_Top = topAnimationView
        animationView_Top.backgroundColor = animationView_InitailBackgroundColor
        animationView_Top.dataSource = self
        animationView_Top.isOpaque = false
        view.addSubview(animationView_Top)
        
        let rightAnimationView = generateUIView(view: animationView_Right, origin: rightAnimationViewStartFrame.origin, size: rightAnimationViewStartFrame.size)
        animationView_Right = rightAnimationView
        animationView_Right.backgroundColor = animationView_InitailBackgroundColor
        animationView_Right.dataSource = self
        animationView_Right.isOpaque = false
        view.addSubview(animationView_Right)
        
        let settingAnimationView = generateUIView(view: animationView_Setting, origin: settingAnimationViewStartFrame.origin, size: settingAnimationViewStartFrame.size)
        animationView_Setting = settingAnimationView
        animationView_Setting.backgroundColor = .clear
        animationView_Setting.buttonGrid.alignmentStyle = .negativeAligned
        animationView_Setting.dataSource = self
        animationView_Setting.isOpaque = false
        view.addSubview(animationView_Setting)
    }
    
    private func layoutAnimationView() {
        animationView_Top?.setNewFrame(topAnimationViewStartFrame)
        animationView_Top?.layoutSubviews()
        animationView_Right?.setNewFrame(rightAnimationViewStartFrame)
        animationView_Right?.layoutSubviews()
        animationView_Setting?.setNewFrame(settingAnimationViewStartFrame)
        animationView_Setting?.layoutSubviews()
    }
    
    //end
    
    //MARK: Presenting ViewController for Button Identifire
    
    func viewControllerForButtonIdentifire(_ identifire: String) -> Giuk_OpenFromFrame_ViewController? {
        switch identifire {
        case "add":
            return TestViewController()
        case "right":
            return Giuk_OpenFromFrame_ViewController()
        case "setting":
            return Giuk_OpenFromFrame_ViewController()
        default:
            return nil
        }
    }
    
    private func openingFrameForButtonIdentifire(_ identifire: String) -> CGRect {
        switch identifire {
        case "add":
            return topOpeningFrame
        case "right":
            return rightOpeningFrame
        case "setting":
            return settingOpeningFrame
        default:
            return rightOpeningFrame
        }
    }
    
    private func openViewControllerFromRect(_ rect: CGRect, viewController: UIViewController) {
        transitionAnimator.setOpeningFrameWithRect(rect)
        viewController.transitioningDelegate = transitionAnimator
        present(viewController, animated: true)
    }
    
    func closingActionWhenPresentedViewControllerDismissed() {
        animationState = .normal
        animationCondition = .collapsed
        startInteractiveTransition(state: animationState, duration: animationDuration)
        endTransition()
    }
    
    private func requestedViewControllerWithButtonIdentifire(_ identifire: String) -> Giuk_OpenFromFrame_ViewController? {
        var newVC : Giuk_OpenFromFrame_ViewController?
        func setFrameViewControllerClosingFunction(_ controller: Giuk_OpenFromFrame_ViewController?) {
            controller?.closingFunction = {
                [unowned self] in
                self.closingActionWhenPresentedViewControllerDismissed()
            }
        }
        newVC = viewControllerForButtonIdentifire(identifire)
        setFrameViewControllerClosingFunction(newVC)
        return newVC
    }
    //end
    
    //MARK: Container trigger button action
    @objc private func handleOntap(_ sender: UIButton_WithIdentifire) {
        let identifire = sender.identifire
        setAnimateStateForButtonIdentifire(identifire)
        if let newVC = requestedViewControllerWithButtonIdentifire(identifire) {
            openViewControllerFromRect(openingFrameForButtonIdentifire(identifire), viewController: newVC)
        }
        startInteractiveTransition(state: self.animationState, duration: animationDuration)
        endTransition()
    }
    
    private func backToNormalStateAction() {
        animationState = .normal
        animationCondition = .collapsed
        startInteractiveTransition(state: self.animationState, duration: animationDuration)
        endTransition()
    }
    
    func setAnimateStateForButtonIdentifire(_ identifire: String) {
        switch identifire {
        case "add":
            if animationState == .normal {
                animationState = .topContainerMode
                animationCondition = .extended
            } else {
                return
            }
        case "right":
            if animationState == .normal {
                animationState = .rightContainerMode
                animationCondition = .extended
            } else {
                return
            }
        case "setting":
            if animationState == .normal {
                animationState = .settingMenuContainerMode
                animationCondition = .extended
            } else {
                return
            }
        default:
            break
        }
    }
    //end
    
    //MARK: testing codes
}

extension Giuk_MainFrame_ViewController {
    //MARK: Running animation part
    func startInteractiveTransition(state: AnimationState, duration: TimeInterval, completion: (()->Void)? = nil) {
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
    
    func endTransition(completion: (()->Void)? = nil) {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
        completion?()
    }
    
    func animationTranstionIfNeeded(state: AnimationState, duration: TimeInterval, completion: (()->Void)? = nil) {
        if runningAnimations.isEmpty {
            
            self.containerView_MainContent.isUserInteractionEnabled = false
            
//            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1)
//            let frameAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut)
            let frameAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) {
                [unowned self] in
                switch state {
                case .normal :
                    self.animationView_Top.frame = self.topAnimationViewStartFrame
                    self.animationView_Right.frame = self.rightAnimationViewStartFrame
                    self.animationView_Setting.frame = self.settingAnimationViewStartFrame
                    
                    self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Start
                    
                case .topContainerMode :
                    self.animationView_Top.frame = self.animationViewAnimatedFrame_Extended
                    self.animationView_Right.frame = self.rightAnimationViewAnimatedFrame_Collapsed
                    self.animationView_Setting.frame = self.settingAnimationViewAnimatedFrame_Collapsed_TopAnimationViewExtendedCase
                    
                    self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Collapsed_TopContainerExtended
                    
                case .rightContainerMode :
                    self.animationView_Top.frame = self.topAnimationViewAnimatedFrame_Collapsed
                    self.animationView_Right.frame = self.animationViewAnimatedFrame_Extended
                    self.animationView_Setting.frame = self.settingAnimationViewAnimatedFrame_Collapsed_RightAnimationViewExtendedCase
                    
                    self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Collapsed_RightContainerExtended
                    
                case .settingMenuContainerMode:
                    self.animationView_Top.frame = self.animationViewAnimatedFrame_Extended
                    self.animationView_Right.frame = self.animationViewAnimatedFrame_Extended
                    self.animationView_Setting.frame = self.animationViewAnimatedFrame_Extended
                    
                    self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Collapsed_SettingContainerExtended
                }
            }
            
            let buttonFadeAnimator = UIViewPropertyAnimator(duration: duration/2, curve: .easeInOut) {
                [unowned self] in
                if state != .normal {
                    self.allButtons.forEach{ $0.alpha = 0 }
                } else {
                    self.allButtons.forEach{ $0.alpha = 1 }
                }
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            buttonFadeAnimator.startAnimation()
            runningAnimations.append(buttonFadeAnimator)
            
            //when animation ended
            frameAnimator.addCompletion { [unowned self] (_) in
                self.runningAnimations.removeAll()
                completion?()
            }
            //
        }
    }
    //end
}

extension Giuk_MainFrame_ViewController {
    
    var animationDuration: TimeInterval {
        return 0.5
    }
    
    var animationView_InitailBackgroundColor: UIColor {
        return UIColor.goyaBlack.withAlphaComponent(0.7)
    }
    
    var animationView_ExtendedBackgroundColor: UIColor {
        return UIColor.goyaBlack
    }
    
    var animationFrame_TopNavigatorPressed: CGRect {
        let originX : CGFloat = 0
        let originY = -fullFrameSize.height
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: fullFrameSize)
    }
    
    var animationFrame_RightNavigatorPressed: CGRect {
        let originX = -fullFrameSize.width
        let originY : CGFloat = 0
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: fullFrameSize)
    }
    
    var animationFrame_SettingNavigatorPressed: CGRect {
        let originX = -fullFrameSize.width
        let originY = -fullFrameSize.height
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: fullFrameSize)
    }
    
    //MARK: Computed Frame resource part
    
    //anchor factors
    var fullFrameSize: CGSize {
        return view.frame.size
    }
    
    var safeAreaRelatedTopMargin: CGFloat {
        return safeAreaRelatedAreaFrame.origin.y.absValue
    }
    
    var safeAreaRelatedBottomMargin: CGFloat {
        return view.frame.height - safeAreaRelatedAreaFrame.maxY
    }
    
    var topAnimationViewAreaHeight: CGFloat {
        return max(fullFrameSize.height * 0.0818, 50)
    }
    
    var rightAnimationViewAreaWidth: CGFloat {
        return topAnimationViewAreaHeight * 0.618
    }
    
    var estimateButtonMarign: CGFloat {
        return 3
    }
    
    var estimateTopContainerHeight: CGFloat {
        return safeAreaRelatedTopMargin + topAnimationViewAreaHeight
    }
    
    // anchor end
    
    //source frames
    // - Animation View Frames
    var topAnimationViewStartFrame: CGRect {
        let size: CGSize = CGSize(width: fullFrameSize.width, height: topAnimationViewAreaHeight + safeAreaRelatedTopMargin)
        let origin = CGPoint(x: 0, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var rightAnimationViewStartFrame: CGRect {
        let size: CGSize = CGSize(width: rightAnimationViewAreaWidth, height: fullFrameSize.height)
        let origin = CGPoint(x: fullFrameSize.width - size.width, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var settingAnimationViewStartFrame: CGRect {
        let width = rightAnimationViewAreaWidth
        let height = estimateTopContainerHeight
        let size = CGSize(width: width, height: height)
        
        let originX = fullFrameSize.width - width
        let originY:CGFloat = 0
        let origin = CGPoint(x: originX, y: originY)
        
        return CGRect(origin: origin, size: size)
    }
    
    var animationViewAnimatedFrame_Extended: CGRect {
        let size = fullFrameSize
        let origin = CGPoint.zero
        return CGRect(origin: origin, size: size)
    }
    
    var topAnimationViewAnimatedFrame_Collapsed: CGRect {
        let size = CGSize(width: topAnimationViewStartFrame.size.width, height: 0)
        let origin = CGPoint.zero
        return CGRect(origin: origin, size: size)
    }
    
    var rightAnimationViewAnimatedFrame_Collapsed: CGRect {
        let size = CGSize(width: 0, height: rightAnimationViewStartFrame.size.height)
        let origin = CGPoint(x: fullFrameSize.width, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var settingAnimationViewAnimatedFrame_Collapsed_TopAnimationViewExtendedCase : CGRect {
        let origin = CGPoint(x: fullFrameSize.width, y: 0)
        return CGRect(origin: origin, size: settingAnimationViewStartFrame.size)
    }
    
    var settingAnimationViewAnimatedFrame_Collapsed_RightAnimationViewExtendedCase : CGRect {
        let origin = CGPoint(x: settingAnimationViewStartFrame.origin.x, y: -settingAnimationViewStartFrame.size.height)
        return CGRect(origin: origin, size: settingAnimationViewStartFrame.size)
    }
    
    
    // preseting view frames
    var topOpeningFrame: CGRect {
        return CGRect(x: 0, y: (-fullFrameSize.height), width: fullFrameSize.width, height: fullFrameSize.height)
    }
    
    var rightOpeningFrame: CGRect {
        return CGRect(x: fullFrameSize.width, y: 0, width: fullFrameSize.width, height: fullFrameSize.height)
    }
    
    var settingOpeningFrame: CGRect {
        return CGRect(x: fullFrameSize.width, y: -fullFrameSize.height, width: fullFrameSize.width, height: fullFrameSize.height)
    }
    
    //Common
    var containerContentSize: CGSize {
        return fullFrameSize
    }
    
    var contentAreaSize: CGSize {
        let width: CGFloat = view.frame.width - rightAnimationViewAreaWidth
        let height: CGFloat = view.frame.height - topAnimationViewAreaHeight - safeAreaRelatedTopMargin
        return CGSize(width: width, height: height)
    }
    
    var contentAreaOrigin_Start: CGPoint {
        let originY: CGFloat = view.frame.height - contentAreaSize.height
        return CGPoint(x: 0, y: originY)
    }
    
    var contentAreaOrigin_Collapsed_TopContainerExtended: CGPoint {
        return CGPoint(x: contentAreaOrigin_Start.x, y: fullFrameSize.height)
    }
    
    var contentAreaOrigin_Collapsed_RightContainerExtended: CGPoint {
        return CGPoint(x: -contentAreaSize.width, y: contentAreaOrigin_Start.y)
    }
    
    var contentAreaOrigin_Collapsed_SettingContainerExtended: CGPoint {
        let originX = -contentAreaSize.width
        let originY = (fullFrameSize.height + containerView_MainContent.frame.height)
        return CGPoint(x: originX, y: originY)
    }
    
    //Button area frames
    var containerView_Top_ButtonAreaFrame: CGRect {
        let topTriggerSizeHeight = topAnimationViewAreaHeight - (estimateButtonMarign*2)
        let topTriggerSizeWidth = fullFrameSize.width - rightAnimationViewAreaWidth - (estimateButtonMarign*2)
        let topTriggerOriginX = estimateButtonMarign
        let topTriggrtOriginY = animationView_Top.bounds.height - estimateButtonMarign - topTriggerSizeHeight
        return CGRect(origin: CGPoint(x: topTriggerOriginX, y: topTriggrtOriginY), size: CGSize(width: topTriggerSizeWidth, height: topTriggerSizeHeight))
    }
    
    var containerView_Right_ButtonAreaFrame: CGRect {
        let expectedSize = CGSize(width: rightAnimationViewAreaWidth, height: fullFrameSize.height - (topAnimationViewAreaHeight + safeAreaRelatedTopMargin))
        let expectedOrigin = CGPoint(x: 0, y: fullFrameSize.height - expectedSize.height)
        let expectedRect = CGRect(origin: expectedOrigin, size: expectedSize)
        let height = expectedRect.height - (estimateButtonMarign*2)
        let width = expectedRect.width - (estimateButtonMarign*2)
        let origin = expectedRect.origin.offSetBy(dX: estimateButtonMarign, dY: estimateButtonMarign)
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
    
    var containerView_Setting_ButtonAreaFrame: CGRect {
        let width = rightAnimationViewAreaWidth - (estimateButtonMarign*2)
        let height = animationView_Setting.frame.height - (estimateButtonMarign*2)
        let size = CGSize(width: width, height: height)
        let originX = estimateButtonMarign
        let originY = estimateButtonMarign
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)
    }
    
//    var containerView_Setting_ButtonAreaFrame: CGRect {
//        let buttonSizeAnchor = rightAnimationViewAreaWidth - (estimateButtonMarign * 2)
//        let size = CGSize(width: buttonSizeAnchor, height: buttonSizeAnchor)
//        let origin = CGPoint(x: estimateButtonMarign, y: settingContainerViewFrameSize.height - size.height - estimateButtonMarign)
//        return CGRect(origin: origin, size: size)
//    }
    //end
}
