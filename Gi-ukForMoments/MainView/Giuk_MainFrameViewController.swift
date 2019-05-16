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
    
    private(set) var topContainerView: Giuk_MainFrame_ContainerView!
    
    private var topHandleArea: UIView!
    
    private(set) var rightContainerView: Giuk_MainFrame_ContainerView!
    
    private var rightHandleArea: UIView!
    
    private(set) var contentContainerView: UIView!
    
    //MARK: Variables for running animations
    enum ContatinerStateFormat {
        case normal
        case topContainerMode
        case rightContainerMode
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
    //end
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        } else {
            return rightButtons
        }
    }
    
    func containerViewButtonAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGRect {
        if containerView == topContainerView {
            return topButtonAreaFrame
        } else {
            return rightContainerViewHandleAreaFrame
        }
    }
    
    func containerViewContentAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGRect {
        return CGRect.zero
    }
    //end
    
    
    //MARK: set Sub views - containerViews & handle area
    private func setContainers() {
        
        topContainerView = generateUIView(view: topContainerView, origin: topContainerViewStartOrigin, size: fullFrameSize)
        topContainerView.backgroundColor = UIColor.goyaBlack.withAlphaComponent(0.7)
        topContainerView.dataSource = self
        view.addSubview(topContainerView)
        
        rightContainerView = generateUIView(view: rightContainerView, origin: rightContainerViewStartOrigin, size: fullFrameSize)
        rightContainerView.backgroundColor = UIColor.goyaBlack.withAlphaComponent(0.7)
        rightContainerView.dataSource = self
        view.addSubview(rightContainerView)
        
        contentContainerView = generateUIView(view: contentContainerView, origin: contentAreaStartOrigin, size: contentAreaSize)
        contentContainerView.backgroundColor = UIColor.goyaYellowWhite.withAlphaComponent(1)
        view.addSubview(contentContainerView)
    }
    
    private func layoutContainers() {
        topContainerView?.setNewFrame(CGRect(origin: topContainerViewStartOrigin, size: fullFrameSize))
        rightContainerView?.setNewFrame(CGRect(origin: rightContainerViewStartOrigin, size: fullFrameSize))
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
        if sender.identifire == "add" {
            print("top touched")
            if containerStateFormat == .normal {
                containerStateFormat = .topContainerMode
                containerState = .extanded
            } else {
                containerStateFormat = .normal
                containerState = .collapsed
            }
        } else {
            print("right touched")
            if containerStateFormat == .normal {
                containerStateFormat = .rightContainerMode
                containerState = .extanded
            } else {
                containerStateFormat = .normal
                containerState = .collapsed
            }
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
                    self.contentContainerView.frame.origin = self.contentAreaStartOrigin
                    self.topContainerView?.frame.origin = self.topContainerViewStartOrigin
                    self.rightContainerView?.frame.origin = self.rightContainerViewStartOrigin
                    
                    self.topContainerView?.backgroundColor = UIColor.goyaBlack.withAlphaComponent(0.7)
                    self.rightContainerView?.backgroundColor = UIColor.goyaBlack.withAlphaComponent(0.7)
                    
                case .topContainerMode :
                    self.contentContainerView.frame.origin = self.contentAreaCollapsedOrigin_TopContainerExtantedCase
                    self.topContainerView?.frame.origin = self.topContainerViewExtandedOrigin
                    self.rightContainerView?.frame.origin = self.rightContainerViewCollapsedOrigin
                    
                    self.topContainerView?.backgroundColor = UIColor.goyaBlack.withAlphaComponent(1)
                    self.rightContainerView?.backgroundColor = UIColor.goyaBlack.withAlphaComponent(0)
                case .rightContainerMode :
                    self.contentContainerView.frame.origin = self.contentAreaCollapsedOrigin_RightContainerExtantedCase
                    self.topContainerView?.frame.origin = self.topContainerViewCollapedOrigin
                    self.rightContainerView?.frame.origin = self.rightContainerViewExtandedOrigin
                    
                    self.topContainerView?.backgroundColor = UIColor.goyaBlack.withAlphaComponent(0)
                    self.rightContainerView?.backgroundColor = UIColor.goyaBlack.withAlphaComponent(1)
                }
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let alphaAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
                [unowned self] in
                switch state {
                case .normal :
                    self.contentContainerView.alpha = 1
                case .topContainerMode :
                    self.contentContainerView.alpha = 0
                case .rightContainerMode :
                    self.contentContainerView.alpha = 0
                }
            }
            
            alphaAnimator.startAnimation()
            runningAnimations.append(alphaAnimator)
            
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
    
    var topContainerViewHandleAreaFrame: CGRect {
        let size: CGSize = CGSize(width: fullFrameSize.width, height: topContainerViewAreaHeight)
        let origin = CGPoint(x: 0, y: fullFrameSize.height - topContainerViewAreaHeight)
        return CGRect(origin: origin, size: size)
    }
    
    var rightContainerViewAreaWidth: CGFloat {
        return topContainerViewAreaHeight * 0.618
    }
    
    var rightContainerViewHandleAreaFrame: CGRect {
        let size = CGSize(width: rightContainerViewAreaWidth, height: fullFrameSize.height - (topContainerViewAreaHeight + safeAreaRelatedTopFrameMargin))
        let origin = CGPoint(x: 0, y: fullFrameSize.height - size.height)
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
    
    var estimateButtonMarign: CGFloat {
        return 3
    }
    
    var topTriggerButtonFrame: CGRect {
        let topTriggerSizeHeight = topContainerViewAreaHeight - (estimateButtonMarign*2)
        let topTriggerOriginX = estimateButtonMarign
        let topTriggrtOriginY = fullFrameSize.height - estimateButtonMarign - topTriggerSizeHeight
        return CGRect(origin: CGPoint(x: topTriggerOriginX, y: topTriggrtOriginY), size: CGSize(width: topTriggerSizeHeight, height: topTriggerSizeHeight))
    }
    
    var topButtonAreaFrame: CGRect {
        let topTriggerSizeHeight = topContainerViewAreaHeight - (estimateButtonMarign*2)
        let topTriggerSizeWidth = topContainerView.frame.width - rightContainerViewAreaWidth - (estimateButtonMarign*2)
        let topTriggerOriginX = estimateButtonMarign
        let topTriggrtOriginY = fullFrameSize.height - estimateButtonMarign - topTriggerSizeHeight
        return CGRect(origin: CGPoint(x: topTriggerOriginX, y: topTriggrtOriginY), size: CGSize(width: topTriggerSizeWidth, height: topTriggerSizeHeight))
    }
    
    var rightTriggerBittonFrame: CGRect {
        let rightTriggerSizeWidth = rightContainerViewAreaWidth - (estimateButtonMarign*2)
        let rightTriggerOriginX = estimateButtonMarign
        let rightTriggerOriginY = topContainerViewAreaHeight + safeAreaRelatedTopFrameMargin + estimateButtonMarign
        return CGRect(origin: CGPoint(x: rightTriggerOriginX, y: rightTriggerOriginY), size: CGSize(width: rightTriggerSizeWidth, height: rightTriggerSizeWidth))
    }
    //end
}
