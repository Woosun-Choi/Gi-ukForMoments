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
    
    private(set) var topAnimationView: UIView!
    
    private(set) var rightAnimationView: UIView!
    
    private(set) var topContainerView: Giuk_MainFrame_ContainerView!
    
    private(set) var rightContainerView: Giuk_MainFrame_ContainerView!
    
    private(set) var containerView_settings: Giuk_MainFrame_ContainerView!
    
    private var topHandleArea: UIView!
    
    private var rightHandleArea: UIView!
    
    private(set) var contentContainerView: UIView!
    
    //MARK: Variables for running animations
    enum ContatinerStateFormat {
        case normal
        case topContainerMode
        case rightContainerMode
        case settingMenuContainerMode
    }
    
    enum ContainerState {
        case extanded
        case collapsed
    }
    
    var containerStateFormat: ContatinerStateFormat = .normal
    
    var containerState: ContainerState = .collapsed
    
    var isContainerCollapsed: Bool = true {
        didSet {
            if self.isContainerCollapsed {
                containerState = .collapsed
            } else {
                containerState = .extanded
            }
        }
    }
    
    var runningAnimations = [UIViewPropertyAnimator]()
    
    var animationProgressWhenInterrupted: CGFloat = 0
    //end
    
    //MARK: ContainerView button resources
    lazy var topButtons : [Giuk_MainButtonItem] = {
        var controlButtons = [Giuk_MainButtonItem]()
        var addButton = Giuk_MainButtonItem()
        addButton.identifire = "add"
        addButton.setTitle("+", for: .normal)
        addButton.addTarget(self, action: #selector(handleOntap(_:)), for: .touchUpInside)
        addButton.backgroundColor = .red
        controlButtons.append(addButton)
        return controlButtons
    }()
    
    lazy var rightButtons : [Giuk_MainButtonItem] = {
        var controlButtons = [Giuk_MainButtonItem]()
        var addButton = Giuk_MainButtonItem()
        addButton.identifire = "right"
        addButton.setTitle("-", for: .normal)
        addButton.addTarget(self, action: #selector(handleOntap(_:)), for: .touchUpInside)
        addButton.backgroundColor = .red
        controlButtons.append(addButton)
        return controlButtons
    }()
    
    lazy var settingButtons : [Giuk_MainButtonItem] = {
        var controlButtons = [Giuk_MainButtonItem]()
        var addButton = Giuk_MainButtonItem()
        addButton.identifire = "setting"
        addButton.setTitle("set", for: .normal)
        addButton.addTarget(self, action: #selector(handleOntap(_:)), for: .touchUpInside)
        addButton.backgroundColor = .red
        controlButtons.append(addButton)
        return controlButtons
    }()
    //end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAnimationView()
        setContainers()
        setHandleAreas()
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
        layoutHandleAreas()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("will layout subviews - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    override func viewDidLayoutSubviews() {
        print("will did subviews - \n safeAreaRect : \(safeAreaRelatedAreaFrame)\n viewFrame: \(view.frame)")
    }
    
    //MARK: ContainerView DataSource part
    func containerViewButtonItem(_ containerView: Giuk_MainFrame_ContainerView) -> [Giuk_MainButtonItem] {
        if containerView == topContainerView {
            return topButtons
        } else if containerView == rightContainerView {
            return rightButtons
        } else {
            return settingButtons
        }
    }
    
    func containerViewButtonAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGRect {
        if containerView == topContainerView {
            return topButtonAreaFrame
        } else if containerView == rightContainerView {
            return rightButtonAreaFrame
        } else {
            return settingContainerViewButtonAreaFrame
        }
    }
    
    func containerViewContentAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGRect {
        return CGRect.zero
    }
    //end
    
    var initailBackgroundColor: UIColor {
        return UIColor.goyaBlack.withAlphaComponent(0.7)
    }
    
    //MARK: set Sub views - containerViews & handle area
    private func setAnimationView() {
        topAnimationView = generateUIView(view: topAnimationView, origin: topAnimationViewStartFrame.origin, size: topAnimationViewStartFrame.size)
        topAnimationView.backgroundColor = initailBackgroundColor
        topAnimationView.isOpaque = false
        view.addSubview(topAnimationView)
        
        rightAnimationView = generateUIView(view: rightAnimationView, origin: rightAnimationViewStartFrame.origin, size: rightAnimationViewStartFrame.size)
        rightAnimationView.backgroundColor = initailBackgroundColor
        rightAnimationView.isOpaque = false
        view.addSubview(rightAnimationView)
    }
    
    private func layoutAnimationView() {
        topAnimationView?.setNewFrame(topAnimationViewStartFrame)
        rightAnimationView?.setNewFrame(rightAnimationViewStartFrame)
    }
    
    
    private func setContainers() {
        
        topContainerView = generateUIView(view: topContainerView, origin: topContainerViewStartOrigin, size: fullFrameSize)
        topContainerView.backgroundColor = UIColor.clear
        topContainerView.dataSource = self
        view.addSubview(topContainerView)
        
        rightContainerView = generateUIView(view: rightContainerView, origin: rightContainerViewStartOrigin, size: fullFrameSize)
        rightContainerView.backgroundColor = UIColor.clear
        rightContainerView.dataSource = self
        view.addSubview(rightContainerView)
        
        containerView_settings = generateUIView(view: containerView_settings, origin: settingContainerViewStartOrigin, size: fullFrameSize)
        containerView_settings.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        containerView_settings.dataSource = self
        view.addSubview(containerView_settings)
        
        contentContainerView = generateUIView(view: contentContainerView, origin: contentAreaStartOrigin, size: contentAreaSize)
        contentContainerView.backgroundColor = UIColor.goyaYellowWhite.withAlphaComponent(1)
        view.addSubview(contentContainerView)
    }
    
    private func layoutContainers() {
        topContainerView?.setNewFrame(CGRect(origin: topContainerViewStartOrigin, size: fullFrameSize))
        rightContainerView?.setNewFrame(CGRect(origin: rightContainerViewStartOrigin, size: fullFrameSize))
        containerView_settings?.setNewFrame(CGRect(origin: settingContainerViewStartOrigin, size: fullFrameSize))
        contentContainerView?.setNewFrame(CGRect(origin: contentAreaStartOrigin, size: contentAreaSize))
    }
    
    private func setHandleAreas() {
        topHandleArea = generateUIView(view: topHandleArea, origin: topContainerViewHandleAreaFrame.origin, size: topContainerViewHandleAreaFrame.size)
        topContainerView.addSubview(topHandleArea)
        
        rightHandleArea = generateUIView(view: rightHandleArea, origin: rightContainerViewHandleAreaFrame.origin, size: rightContainerViewHandleAreaFrame.size)
        rightContainerView.addSubview(rightHandleArea)
    }
    
    private func layoutHandleAreas() {
        topHandleArea.setNewFrame(topContainerViewHandleAreaFrame)
        rightHandleArea.setNewFrame(rightContainerViewHandleAreaFrame)
    }
    
    //MARK: Container trigger button action
    @objc func handleOntap(_ sender: Giuk_MainButtonItem) {
        switch sender.identifire {
        case "add":
            if containerStateFormat == .normal {
                containerStateFormat = .topContainerMode
                containerState = .extanded
            } else {
                containerStateFormat = .normal
                containerState = .collapsed
            }
        case "right":
            if containerStateFormat == .normal {
                containerStateFormat = .rightContainerMode
                containerState = .extanded
            } else {
                containerStateFormat = .normal
                containerState = .collapsed
            }
        case "setting":
            if containerStateFormat == .normal {
                containerStateFormat = .settingMenuContainerMode
                containerState = .extanded
            } else {
                containerStateFormat = .normal
                containerState = .collapsed
            }
        default:
            break
        }
        
        startInteractiveTransition(state: self.containerStateFormat, duration: 0.9)
        endTransition()
    }
    //end
}

extension Giuk_MainFrameViewController {
    //MARK: Running animation part
    func startInteractiveTransition(state: ContatinerStateFormat, duration: TimeInterval, completion: (()->Void)? = nil) {
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
    
    func animationTranstionIfNeeded(state: ContatinerStateFormat, duration: TimeInterval, completion: (()->Void)? = nil) {
        if runningAnimations.isEmpty {
            
            self.contentContainerView.isUserInteractionEnabled = false
            self.topContainerView.isUserInteractionEnabled = false
            self.rightContainerView.isUserInteractionEnabled = false
            
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                [unowned self] in
                switch state {
                case .normal :
                    self.topAnimationView.frame = self.topAnimationViewStartFrame
                    self.rightAnimationView.frame = self.rightAnimationViewStartFrame
                    
                    self.contentContainerView.frame.origin = self.contentAreaStartOrigin
                    self.topContainerView?.frame.origin = self.topContainerViewStartOrigin
                    self.rightContainerView?.frame.origin = self.rightContainerViewStartOrigin
                    self.containerView_settings?.frame.origin = self.settingContainerViewStartOrigin
                    
                case .topContainerMode :
                    self.topAnimationView.frame = self.animationViewAnimatedFrame_extanded
                    self.rightAnimationView.frame = self.rightAnimationViewAnimatedFrame_collapsed
                    
                    self.contentContainerView.frame.origin = self.contentAreaCollapsedOrigin_TopContainerExtantedCase
                    self.topContainerView?.frame.origin = self.topContainerViewExtandedOrigin
                    self.rightContainerView?.frame.origin = self.rightContainerViewCollapsedOrigin
                    self.containerView_settings?.frame.origin = self.settingContainerViewCollapsedOrgin_topContainerExpanded
                    
                case .rightContainerMode :
                    self.topAnimationView.frame = self.topAnimationViewAnimatedFrame_collapsed
                    self.rightAnimationView.frame = self.animationViewAnimatedFrame_extanded
                    
                    self.contentContainerView.frame.origin = self.contentAreaCollapsedOrigin_RightContainerExtantedCase
                    self.topContainerView?.frame.origin = self.topContainerViewCollapedOrigin
                    self.rightContainerView?.frame.origin = self.rightContainerViewExtandedOrigin
                    self.containerView_settings?.frame.origin = self.settingContainerViewCollapsedOrgin_rightContainerExpanded
                    
                case .settingMenuContainerMode:
                    self.topAnimationView.frame = self.animationViewAnimatedFrame_extanded
                    self.rightAnimationView.frame = self.animationViewAnimatedFrame_extanded
                    
                    self.topContainerView.frame.origin = self.topContainerViewCollapedOrigin
                    self.rightContainerView.frame.origin = self.rightContainerViewCollapsedOrigin
                    self.contentContainerView.frame.origin = self.contentAreaCollapsedOrigin_SettingContainerExtanedCase
                    self.containerView_settings?.frame.origin = self.settingContainerViewExtandedOrgin
                }
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
//            let alphaAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
//                [unowned self] in
//                switch state {
//                case .normal :
//                    self.contentContainerView.alpha = 1
//                case .topContainerMode :
//                    self.contentContainerView.alpha = 0
//                case .rightContainerMode :
//                    self.contentContainerView.alpha = 0
//                case .settingMenuContainerMode:
//                    self.contentContainerView.alpha = 0
//                }
//            }
//
//            alphaAnimator.startAnimation()
//            runningAnimations.append(alphaAnimator)
            
            //when animation ended
            frameAnimator.addCompletion { [unowned self] (_) in
                self.runningAnimations.removeAll()
                self.contentContainerView.isUserInteractionEnabled = true
                self.topContainerView.isUserInteractionEnabled = true
                self.rightContainerView.isUserInteractionEnabled = true
                completion?()
            }
            //
        }
    }
    //end
}

extension Giuk_MainFrameViewController {
    //MARK: Computed Frame resource part
    
    //anchor factors
    var fullFrameSize: CGSize {
        return view.frame.size
    }
    
    var safeAreaRelatedTopFrameMargin: CGFloat {
        return safeAreaRelatedAreaFrame.origin.y.absValue
    }
    
    var safeAreaRelatedBottomFrameMargin: CGFloat {
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
        let size: CGSize = CGSize(width: fullFrameSize.width, height: topContainerViewAreaHeight + safeAreaRelatedTopFrameMargin)
        let origin = CGPoint(x: 0, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var rightAnimationViewStartFrame: CGRect {
        let size: CGSize = CGSize(width: rightContainerViewAreaWidth, height: fullFrameSize.height)
        let origin = CGPoint(x: fullFrameSize.width - size.width, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var animationViewAnimatedFrame_extanded: CGRect {
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
    var topContainerViewHandleAreaFrame: CGRect {
        let size: CGSize = CGSize(width: fullFrameSize.width, height: topContainerViewAreaHeight)
        let origin = CGPoint(x: 0, y: fullFrameSize.height - topContainerViewAreaHeight)
        return CGRect(origin: origin, size: size)
    }
    
    var topContainerViewStartOrigin: CGPoint {
        let originY: CGFloat = (-fullFrameSize.height) + topContainerViewAreaHeight + safeAreaRelatedTopFrameMargin
        return CGPoint(x: 0, y: originY)
    }
    
    var topContainerViewCollapedOrigin: CGPoint {
        return CGPoint(x: 0, y: (-fullFrameSize.height))
    }
    
    var topContainerViewExtandedOrigin: CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    var topButtonAreaFrame: CGRect {
        let topTriggerSizeHeight = topContainerViewAreaHeight - (estimateButtonMarign*2)
        let topTriggerSizeWidth = topContainerView.frame.width - rightContainerViewAreaWidth - (estimateButtonMarign*2)
        let topTriggerOriginX = estimateButtonMarign
        let topTriggrtOriginY = fullFrameSize.height - estimateButtonMarign - topTriggerSizeHeight
        return CGRect(origin: CGPoint(x: topTriggerOriginX, y: topTriggrtOriginY), size: CGSize(width: topTriggerSizeWidth, height: topTriggerSizeHeight))
    }
    
    var rightContainerViewHandleAreaFrame: CGRect {
        let size = CGSize(width: rightContainerViewAreaWidth, height: fullFrameSize.height - (topContainerViewAreaHeight + safeAreaRelatedTopFrameMargin))
        let origin = CGPoint(x: 0, y: fullFrameSize.height - size.height)
        return CGRect(origin: origin, size: size)
    }
    
    var rightButtonAreaFrame: CGRect {
        let height = rightContainerViewHandleAreaFrame.height - (estimateButtonMarign*2)
        let width = rightContainerViewHandleAreaFrame.width - (estimateButtonMarign*2)
        let origin = rightContainerViewHandleAreaFrame.origin.offSetBy(dX: estimateButtonMarign, dY: estimateButtonMarign)
        return CGRect(origin: origin, size: CGSize(width: width, height: height))
    }
    
    var rightContainerViewStartOrigin: CGPoint {
        let originX: CGFloat = fullFrameSize.width - rightContainerViewAreaWidth
        return CGPoint(x: originX, y: 0)
    }
    
    var rightContainerViewExtandedOrigin: CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    var rightContainerViewCollapsedOrigin: CGPoint {
        return CGPoint(x: fullFrameSize.width, y: 0)
    }
    
    var settingContainerViewStartOrigin: CGPoint {
        return CGPoint(x: fullFrameSize.width - rightContainerViewAreaWidth, y: (-fullFrameSize.height) + safeAreaRelatedTopFrameMargin + topContainerViewAreaHeight)
    }
    
    var settingContainerViewExtandedOrgin: CGPoint {
        return CGPoint.zero
    }
    
    var settingContainerViewCollapsedOrgin_topContainerExpanded: CGPoint {
        return CGPoint(x: fullFrameSize.width, y: settingContainerViewStartOrigin.y)
    }
    
    var settingContainerViewCollapsedOrgin_rightContainerExpanded: CGPoint {
        return CGPoint(x: settingContainerViewStartOrigin.x, y: -fullFrameSize.height)
    }
    
    var settingContainerViewButtonAreaFrame: CGRect {
        let buttonSizeAnchor = rightContainerViewAreaWidth - (estimateButtonMarign * 2)
        let size = CGSize(width: buttonSizeAnchor, height: buttonSizeAnchor)
        let origin = CGPoint(x: estimateButtonMarign, y: fullFrameSize.height - size.height - estimateButtonMarign)
        return CGRect(origin: origin, size: size)
    }
    
    var contentAreaSize: CGSize {
        let width: CGFloat = view.frame.width - rightContainerViewAreaWidth
        let height: CGFloat = view.frame.height - topContainerViewAreaHeight - safeAreaRelatedTopFrameMargin
        return CGSize(width: width, height: height)
    }
    
    var contentAreaStartOrigin: CGPoint {
        let originY: CGFloat = view.frame.height - contentAreaSize.height
        return CGPoint(x: 0, y: originY)
    }
    
    var contentAreaCollapsedOrigin_TopContainerExtantedCase: CGPoint {
        return CGPoint(x: contentAreaStartOrigin.x, y: fullFrameSize.height)
    }
    
    var contentAreaCollapsedOrigin_RightContainerExtantedCase: CGPoint {
        return CGPoint(x: -contentAreaSize.width, y: contentAreaStartOrigin.y)
    }
    
    var contentAreaCollapsedOrigin_SettingContainerExtanedCase: CGPoint {
        let originX = -contentAreaSize.width
        let originY = (fullFrameSize.height + contentContainerView.frame.height)
        return CGPoint(x: originX, y: originY)
    }
    //end
}
