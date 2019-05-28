//
//  Gi-ukMainFrameViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class Giuk_MainFrameViewController: ContentUIViewController, ContainerViewButtonDataSource
{
    
    //MARK: Variables for container views
    private(set) var animationView_Top: UIView!
    
    private(set) var animationView_Right: UIView!
    
    private(set) var containerView_Top: Giuk_MainFrame_ContainerView!
    
    private(set) var containerView_Right: Giuk_MainFrame_ContainerView!
    
    private(set) var containerView_settings: Giuk_MainFrame_ContainerView!
    
    private(set) var containerView_MainContent: UIView!
    
    //MARK: Variables for running animations
    enum ContainerStateFormat {
        case normal
        case topContainerMode
        case rightContainerMode
        case settingMenuContainerMode
    }
    
    enum ContainerState {
        case extended
        case collapsed
    }
    
    var containerStateFormat: ContainerStateFormat = .normal {
        didSet {
            setContainersContentViewAtStateOfContainer()
        }
    }
    
    var containerState: ContainerState = .collapsed
    
    var isContainerCollapsed: Bool = true {
        didSet {
            if self.isContainerCollapsed {
                containerState = .collapsed
            } else {
                containerState = .extended
            }
        }
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    
    var animationProgressWhenInterrupted: CGFloat = 0
    //end
    
    //MARK: ContainerView button resources
    
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
    //end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttons[.top] = buttonsForTopContainerView()
        buttons[.right] = buttonsForRightContainerView()
        buttons[.setting] = buttonsForSettingContainerView()
        view.backgroundColor = .goyaYellowWhite
        setAnimationView()
        setContainers()
        print("did load - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("will appear - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("did appear - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
        layoutAnimationView()
        layoutContainers()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("will layout subviews - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        print("will did subviews - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    //MARK: ContainerView DataSource part
    func containerViewButtonItem(_ containerView: Giuk_MainFrame_ContainerView) -> [UIButton_WithIdentifire] {
        if containerView == containerView_Top {
            return buttons[.top]!
        } else if containerView == containerView_Right {
            return buttons[.right]!
        } else {
            return buttons[.setting]!
        }
    }
    
    func containerViewButtonAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGRect {
        if containerView == containerView_Top {
            return containerView_Top_ButtonAreaFrame
        } else if containerView == containerView_Right {
            return containerView_Right_ButtonAreaFrame
        } else {
            return containerView_Setting_ButtonAreaFrame
        }
    }
    
    func containerViewContentAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGSize {
        return fullFrameSize
    }
    //end
    
    var initailBackgroundColor: UIColor {
        return UIColor.goyaBlack.withAlphaComponent(0.7)
    }
    
    //MARK: set Sub views - containerViews & handle area
    private func setAnimationView() {
        animationView_Top = generateUIView(view: animationView_Top, origin: topAnimationViewStartFrame.origin, size: topAnimationViewStartFrame.size)
        animationView_Top.backgroundColor = initailBackgroundColor
        animationView_Top.isOpaque = false
        view.addSubview(animationView_Top)
        
        animationView_Right = generateUIView(view: animationView_Right, origin: rightAnimationViewStartFrame.origin, size: rightAnimationViewStartFrame.size)
        animationView_Right.backgroundColor = initailBackgroundColor
        animationView_Right.isOpaque = false
        view.addSubview(animationView_Right)
    }
    
    private func layoutAnimationView() {
        animationView_Top?.setNewFrame(topAnimationViewStartFrame)
        animationView_Right?.setNewFrame(rightAnimationViewStartFrame)
    }
    
    
    private func setContainers() {
        
        containerView_Top = generateUIView(view: containerView_Top, origin: topContainerViewOrigin_Start, size: topContainerViewFrameSize)
        containerView_Top.isOpaque = false
        containerView_Top.backgroundColor = UIColor.clear
        containerView_Top.dataSource = self
        containerView_Top.requestedActionForClose = { [unowned self] in
            self.backToNormalStateAction()
        }
        view.addSubview(containerView_Top)
        
        containerView_Right = generateUIView(view: containerView_Right, origin: rightContainerViewOrigin_Start, size: rightContainerVeiwFrameSize)
        containerView_Right.isOpaque = false
        containerView_Right.backgroundColor = UIColor.clear
        containerView_Right.dataSource = self
        containerView_Right.requestedActionForClose = { [unowned self] in
            self.backToNormalStateAction()
        }
        view.addSubview(containerView_Right)
        
        containerView_settings = generateUIView(view: containerView_settings, origin: settingContainerViewOrigin_Start, size: settingContainerViewFrameSize)
        containerView_settings.isOpaque = false
        containerView_settings.contentAreaBackgroundColor = .clear
        containerView_settings.backgroundColor = .clear
        containerView_settings.dataSource = self
        containerView_settings.requestedActionForClose = { [unowned self] in
            self.backToNormalStateAction()
        }
        view.addSubview(containerView_settings)
        
        containerView_MainContent = generateUIView(view: containerView_MainContent, origin: contentAreaOrigin_Start, size: contentAreaSize)
        containerView_MainContent.isOpaque = false
        containerView_MainContent.backgroundColor = UIColor.clear
        view.addSubview(containerView_MainContent)
    }
    
    private func layoutContainers() {
        containerView_Top?.setNewFrame(CGRect(origin: topContainerViewOrigin_Start, size: topContainerViewFrameSize))
        containerView_Top?.requieredTopMargin = safeAreaRelatedTopMargin
        containerView_Top?.requieredBottomMargin = safeAreaRelatedBottomMargin
        containerView_Top?.layoutSubviews()
        
        containerView_Right?.setNewFrame(CGRect(origin: rightContainerViewOrigin_Start, size: rightContainerVeiwFrameSize))
        containerView_Right?.requieredTopMargin = safeAreaRelatedTopMargin
        containerView_Right?.requieredBottomMargin = safeAreaRelatedBottomMargin
        containerView_Right?.layoutSubviews()
        
        containerView_settings?.setNewFrame(CGRect(origin: settingContainerViewOrigin_Start, size: settingContainerViewFrameSize))
        containerView_settings?.requieredTopMargin = safeAreaRelatedTopMargin
        containerView_settings?.requieredBottomMargin = safeAreaRelatedBottomMargin
        containerView_settings?.layoutSubviews()
        
        containerView_MainContent?.setNewFrame(CGRect(origin: contentAreaOrigin_Start, size: contentAreaSize))
    }
    
    //MARK: Container trigger button action
    @objc func handleOntap(_ sender: UIButton_WithIdentifire) {
        switch sender.identifire {
        case "add":
            if containerStateFormat == .normal {
                containerStateFormat = .topContainerMode
                containerState = .extended
            } else {
                return
            }
        case "right":
            if containerStateFormat == .normal {
                containerStateFormat = .rightContainerMode
                containerState = .extended
            } else {
                return
            }
        case "setting":
            if containerStateFormat == .normal {
                containerStateFormat = .settingMenuContainerMode
                containerState = .extended
            } else {
                return
            }
        default:
            break
        }
        startInteractiveTransition(state: self.containerStateFormat, duration: animationDuration)
        endTransition()
    }
    
    private func backToNormalStateAction() {
        containerStateFormat = .normal
        containerState = .collapsed
        startInteractiveTransition(state: self.containerStateFormat, duration: animationDuration)
        endTransition()
    }
    //end
    
    //MARK: testing codes
    
    var nowPresentingContainersContentView: UIView! {
        didSet {
            if nowPresentingContainersContentView != nil {
                addRedViewTest(nowPresentingContainersContentView!)
            }
        }
    }
    
    func setContainersContentViewAtStateOfContainer() {
        switch containerStateFormat {
        case .normal:
            UIView.animate(withDuration: 0.25
                , animations: {
                    [unowned self] in
                    self.nowPresentingContainersContentView.alpha = 0
            }) { (finished) in
                self.nowPresentingContainersContentView?.subviews.forEach { $0.removeFromSuperview() }
                self.nowPresentingContainersContentView = nil
            }
        case .rightContainerMode:
            nowPresentingContainersContentView = containerView_Right.contentView
            nowPresentingContainersContentView?.alpha = 1
        case .topContainerMode:
            nowPresentingContainersContentView = containerView_Top.contentView
            nowPresentingContainersContentView?.alpha = 1
        case .settingMenuContainerMode:
            nowPresentingContainersContentView = containerView_settings.contentView
            nowPresentingContainersContentView?.alpha = 1
        }
    }
    
    func addRedViewTest(_ view: UIView?) {
        if view != nil {
            var redView = UIView()
            if containerStateFormat == .topContainerMode {
                redView = Giuk_ContentView_WriteSection()
            } else {
                redView = Giuk_ContentView()
            }
            let midX = (view?.frame.width ?? 0)/2
            let midY = (view?.frame.height ?? 0)/2
            redView.backgroundColor = .red
            redView.frame.size = CGSize(width: view?.frame.width ?? 100, height: view?.frame.height ?? 100)
            redView.center = CGPoint(x: midX, y: midY)
            view?.addSubview(redView)
        } else {
            return
        }
    }
}

extension Giuk_MainFrameViewController {
    //MARK: Running animation part
    func startInteractiveTransition(state: ContainerStateFormat, duration: TimeInterval, completion: (()->Void)? = nil) {
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
    
    func animationTranstionIfNeeded(state: ContainerStateFormat, duration: TimeInterval, completion: (()->Void)? = nil) {
        if runningAnimations.isEmpty {
            
            self.containerView_MainContent.isUserInteractionEnabled = false
            self.containerView_Top.isUserInteractionEnabled = false
            self.containerView_Right.isUserInteractionEnabled = false
            
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                [unowned self] in
                switch state {
                case .normal :
                    self.animationView_Top.frame = self.topAnimationViewStartFrame
                    self.animationView_Right.frame = self.rightAnimationViewStartFrame
                    
                    self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Start
                    self.containerView_Top?.frame.origin = self.topContainerViewOrigin_Start
                    self.containerView_Right?.frame.origin = self.rightContainerViewOrigin_Start
                    self.containerView_settings?.frame.origin = self.settingContainerViewOrigin_Start
                    
                case .topContainerMode :
                    self.animationView_Top.frame = self.animationViewAnimatedFrame_extended
                    self.animationView_Right.frame = self.rightAnimationViewAnimatedFrame_collapsed
                    
                    self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Collapsed_TopContainerExtended
                    self.containerView_Top?.frame.origin = self.topContainerViewOrigin_Extended
                    self.containerView_Right?.frame.origin = self.rightContainerViewOrigin_Collapsed
                    self.containerView_settings?.frame.origin = self.settingContainerViewOrgin_Collapsed_topContainerExtended
                    
                case .rightContainerMode :
                    self.animationView_Top.frame = self.topAnimationViewAnimatedFrame_collapsed
                    self.animationView_Right.frame = self.animationViewAnimatedFrame_extended
                    
                    self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Collapsed_RightContainerExtended
                    self.containerView_Top?.frame.origin = self.topContainerViewOrigin_Collapsed
                    self.containerView_Right?.frame.origin = self.rightContainerViewOrigin_Extended
                    self.containerView_settings?.frame.origin = self.settingContainerViewOrgin_Collapsed_rightContainerExtended
                    
                case .settingMenuContainerMode:
                    self.animationView_Top.frame = self.animationViewAnimatedFrame_extended
                    self.animationView_Right.frame = self.animationViewAnimatedFrame_extended
                    
                    self.containerView_Top.frame.origin = self.topContainerViewOrigin_Collapsed
                    self.containerView_Right.frame.origin = self.rightContainerViewOrigin_Collapsed
                    self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Collapsed_SettingContainerExtended
                    self.containerView_settings?.frame.origin = self.settingContainerViewOrigin_Extended
                }
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            var buttonFadeAnimatorDuration: TimeInterval {
                switch state {
                case .normal:
                    return duration * 3.5
                default:
                    return duration/2
                }
            }
            
            let buttonFadeAnimator = UIViewPropertyAnimator(duration: buttonFadeAnimatorDuration, dampingRatio: 1) {
                [unowned self] in
                switch state {
                case .normal :
                    break
                default :
                    self.containerView_Top?.buttonArea.alpha = 0
                    self.containerView_Right?.buttonArea.alpha = 0
                    self.containerView_settings?.buttonArea.alpha = 0
                }
            }
            
            buttonFadeAnimator.startAnimation()
            runningAnimations.append(buttonFadeAnimator)
            
            //when animation ended
            frameAnimator.addCompletion { [unowned self] (_) in
                self.runningAnimations.removeAll()
                self.containerView_MainContent.isUserInteractionEnabled = true
                self.containerView_Top.isUserInteractionEnabled = true
                self.containerView_Right.isUserInteractionEnabled = true
                if state == .normal {
                    UIView.animate(withDuration: 0.25, animations: {
                        [unowned self] in
                        self.containerView_Top?.buttonArea.alpha = 1
                        self.containerView_Right?.buttonArea.alpha = 1
                        self.containerView_settings?.buttonArea.alpha = 1
                    })
                }
                completion?()
            }
            //
        }
    }
    //end
}

extension Giuk_MainFrameViewController {
    
    var animationDuration: TimeInterval {
        return 0.75
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
    
    var topContainerViewAreaHeight: CGFloat {
        return max(fullFrameSize.height * 0.0818, 50)
    }
    
    var rightContainerViewAreaWidth: CGFloat {
        return topContainerViewAreaHeight * 0.618
    }
    
    var estimateButtonMarign: CGFloat {
        return 3
    }
    // anchor end
    
    //source frames
    // - Animation View Frames
    var topAnimationViewStartFrame: CGRect {
        let size: CGSize = CGSize(width: fullFrameSize.width, height: topContainerViewAreaHeight + safeAreaRelatedTopMargin)
        let origin = CGPoint(x: 0, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var rightAnimationViewStartFrame: CGRect {
        let size: CGSize = CGSize(width: rightContainerViewAreaWidth, height: fullFrameSize.height)
        let origin = CGPoint(x: fullFrameSize.width - size.width, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var animationViewAnimatedFrame_extended: CGRect {
        let size = fullFrameSize
        let origin = CGPoint.zero
        return CGRect(origin: origin, size: size)
    }
    
    var topAnimationViewAnimatedFrame_collapsed: CGRect {
        let size = CGSize(width: topAnimationViewStartFrame.size.width, height: 0)
        let origin = CGPoint.zero
        return CGRect(origin: origin, size: size)
    }
    
    var rightAnimationViewAnimatedFrame_collapsed: CGRect {
        let size = CGSize(width: 0, height: rightAnimationViewStartFrame.size.height)
        let origin = CGPoint(x: fullFrameSize.width, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    
    // container view frames
    
    //Common
    var containerContentSize: CGSize {
        return fullFrameSize
    }
    
    //top
    var topContainerViewFrameSize: CGSize {
        let width = fullFrameSize.width
        let height = fullFrameSize.height + topContainerViewAreaHeight + safeAreaRelatedTopMargin
        return CGSize(width: width, height: height)
    }
    
    var topContainerViewOrigin_Start: CGPoint {
        let originY: CGFloat = -fullFrameSize.height
        return CGPoint(x: 0, y: originY)
    }
    
    var topContainerViewOrigin_Collapsed: CGPoint {
        return CGPoint(x: 0, y: -(fullFrameSize.height + topContainerViewAreaHeight + safeAreaRelatedTopMargin))
    }
    
    var topContainerViewOrigin_Extended: CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    //right
    var rightContainerVeiwFrameSize: CGSize {
        let width = fullFrameSize.width + rightContainerViewAreaWidth
        let height = fullFrameSize.height
        return CGSize(width: width, height: height)
    }
    
    var rightContainerViewOrigin_Start: CGPoint {
        let originX: CGFloat = fullFrameSize.width - rightContainerViewAreaWidth
        return CGPoint(x: originX, y: 0)
    }
    
    var rightContainerViewOrigin_Extended: CGPoint {
        return CGPoint(x: -rightContainerViewAreaWidth, y: 0)
    }
    
    var rightContainerViewOrigin_Collapsed: CGPoint {
        return CGPoint(x: fullFrameSize.width, y: 0)
    }
    
    //setting
    var settingContainerViewFrameSize: CGSize {
        let width = fullFrameSize.width + rightContainerViewAreaWidth
        let height = fullFrameSize.height + topContainerViewAreaHeight + safeAreaRelatedTopMargin
        return CGSize(width: width, height: height)
    }
    
    var settingContainerViewOrigin_Start: CGPoint {
        let originX = fullFrameSize.width - rightContainerViewAreaWidth
        let originY = -fullFrameSize.height
        return CGPoint(x: originX, y: originY)
    }
    
    var settingContainerViewOrigin_Extended: CGPoint {
        let originX = -rightContainerViewAreaWidth
        let originY: CGFloat = 0
        return CGPoint(x: originX, y: originY)
    }
    
    var settingContainerViewOrgin_Collapsed_topContainerExtended: CGPoint {
        return CGPoint(x: fullFrameSize.width, y: settingContainerViewOrigin_Start.y)
    }
    
    var settingContainerViewOrgin_Collapsed_rightContainerExtended: CGPoint {
        return CGPoint(x: settingContainerViewOrigin_Start.x, y: -(fullFrameSize.height + topContainerViewAreaHeight + safeAreaRelatedTopMargin))
    }
    
    var contentAreaSize: CGSize {
        let width: CGFloat = view.frame.width - rightContainerViewAreaWidth
        let height: CGFloat = view.frame.height - topContainerViewAreaHeight - safeAreaRelatedTopMargin
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
        let topTriggerSizeHeight = topContainerViewAreaHeight - (estimateButtonMarign*2)
        let topTriggerSizeWidth = containerView_Top.frame.width - rightContainerViewAreaWidth - (estimateButtonMarign*2)
        let topTriggerOriginX = estimateButtonMarign
        let topTriggrtOriginY = topContainerViewFrameSize.height - estimateButtonMarign - topTriggerSizeHeight
        return CGRect(origin: CGPoint(x: topTriggerOriginX, y: topTriggrtOriginY), size: CGSize(width: topTriggerSizeWidth, height: topTriggerSizeHeight))
    }
    
    var containerView_Right_ButtonAreaFrame: CGRect {
        let expectedSize = CGSize(width: rightContainerViewAreaWidth, height: fullFrameSize.height - (topContainerViewAreaHeight + safeAreaRelatedTopMargin))
        let expectedOrigin = CGPoint(x: 0, y: fullFrameSize.height - expectedSize.height)
        let expectedRect = CGRect(origin: expectedOrigin, size: expectedSize)
        let height = expectedRect.height - (estimateButtonMarign*2)
        let width = expectedRect.width - (estimateButtonMarign*2)
        let origin = expectedRect.origin.offSetBy(dX: estimateButtonMarign, dY: estimateButtonMarign)
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
    
    var containerView_Setting_ButtonAreaFrame: CGRect {
        let buttonSizeAnchor = rightContainerViewAreaWidth - (estimateButtonMarign * 2)
        let size = CGSize(width: buttonSizeAnchor, height: buttonSizeAnchor)
        let origin = CGPoint(x: estimateButtonMarign, y: settingContainerViewFrameSize.height - size.height - estimateButtonMarign)
        return CGRect(origin: origin, size: size)
    }
    //end
}

/*
 var animationChecker: (topanimation: Bool, rightanimation: Bool, settinganimation: Bool) = (true,true,true) {
 didSet {
 if animationChecker.topanimation == true && animationChecker.rightanimation == true && animationChecker.settinganimation == true {
 print("clear to go")
 }
 }
 }
 
 func movingDistance(firstpoint: CGPoint, secondPoint: CGPoint) -> CGFloat {
 let distanceX = firstpoint.x - secondPoint.x
 let distanceY = firstpoint.y - secondPoint.y
 var expectedDistance: Double = 0
 if distanceX == 0 || distanceY == 0 {
 let positiveValue = max(distanceX.absValue, distanceY.absValue)
 expectedDistance = Double(positiveValue)
 } else {
 expectedDistance = sqrt(Double(((distanceX*distanceX) + (distanceY*distanceY)).absValue))
 }
 return CGFloat(expectedDistance).absValue
 }
 
 func startInteractiveTransition_speed(state: ContainerStateFormat, speed: CGFloat, completion: (()->Void)? = nil) {
 if runningAnimations.isEmpty {
 animationTranstionIfNeeded_Speed(state: state, speed: speed)
 }
 for animator in runningAnimations {
 animator.pauseAnimation()
 animationProgressWhenInterrupted = animator.fractionComplete
 }
 }
 
 func animationTranstionIfNeeded_Speed(state: ContainerStateFormat, speed: CGFloat, completion: (()->Void)? = nil) {
 
 animationChecker = (false,false,false)
 
 let animationDurationForTopContainer: CGFloat = movingDistance(firstpoint: containerView_Top.frame.origin, secondPoint: topContainerViewOrigin_Extanded)/speed
 let animationDurationForRightContainer: CGFloat = movingDistance(firstpoint: containerView_Right.frame.origin, secondPoint: rightContainerViewOrigin_Collapsed)/speed
 let animationDutrationForSettingContainer: CGFloat = movingDistance(firstpoint: containerView_settings.frame.origin, secondPoint: settingContainerViewOrgin_Collapsed_topContainerExtanded)/speed
 let animationDurationForContentContainer: CGFloat = movingDistance(firstpoint: contentContainerView.frame.origin, secondPoint: contentAreaOrigin_Collapsed_TopContainerExtanded)/speed
 
 let topframeAnimator = UIViewPropertyAnimator(duration: Double(animationDurationForTopContainer), dampingRatio: 1) {
 self.containerView_Top.frame.origin = self.topContainerViewOrigin_Extanded
 }
 
 topframeAnimator.startAnimation()
 topframeAnimator.addCompletion { (finished) in
 self.animationChecker.topanimation = true
 }
 runningAnimations.append(topframeAnimator)
 
 let rightframeAnimator = UIViewPropertyAnimator(duration: Double(animationDurationForRightContainer), dampingRatio: 1) {
 self.containerView_Right.frame.origin = self.rightContainerViewOrigin_Collapsed
 }
 
 rightframeAnimator.startAnimation()
 rightframeAnimator.addCompletion { (finished) in
 self.animationChecker.rightanimation = true
 }
 runningAnimations.append(rightframeAnimator)
 
 let settingframeAnimator = UIViewPropertyAnimator(duration: Double(animationDutrationForSettingContainer), dampingRatio: 1) {
 self.containerView_settings.frame.origin = self.settingContainerViewOrgin_Collapsed_topContainerExtanded
 }
 
 settingframeAnimator.startAnimation()
 settingframeAnimator.addCompletion { (finished) in
 self.animationChecker.settinganimation = true
 }
 runningAnimations.append(settingframeAnimator)
 
 let contentframeAnimator = UIViewPropertyAnimator(duration: Double(animationDurationForContentContainer), dampingRatio: 1) {
 self.contentContainerView.frame.origin = self.contentAreaOrigin_Collapsed_TopContainerExtanded
 }
 contentframeAnimator.startAnimation()
 runningAnimations.append(contentframeAnimator)
 }
 */
