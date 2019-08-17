//
//  Giuk_MainFrame_ViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 30/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class Giuk_MainFrame_ViewController: StartWithAnimation_ViewController, AnimateButtonViewButtonDataSource, FrameTransitionDataSource, HashTagScrollViewDataSource, HashTagScrollViewDelegate {
    
//    var filterEffect : ImageFilterModule.CIFilterName = .CIPhotoEffectInstant
    var filterEffect : ImageFilterModule.CIFilterName = .CIPhotoEffectTonal
    
    //MARK: screenversion?
    var isFullScreenVersion: Bool = true {
        didSet {
            UIView.animate(withDuration: 0.25) {
                [unowned self] in
                self.viewDidLayoutSubviews()
            }
        }
    }
    
    //MARK: subviews
    private(set) weak var animationView_Top: AnimateButtonView!
    
    private(set) weak var animationView_Right: AnimateButtonView!
    
    private(set) weak var animationView_Setting: AnimateButtonView!
    
    private(set) weak var containerView_MainContent: InnerShadowUIView!
    
    private(set) weak var tagView: GiukHashtagScrollView!
    //end
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    var container: NSPersistentContainer? = AppDelegate.persistentContainer
    
    var context: NSManagedObjectContext {
        if let context = container?.viewContext {
            return context
        } else {
            return AppDelegate.viewContext
        }
    }
    
    //MARK: Variables for running animations
    var transitionAnimator = FrameTransitioningDelegate()
    
    var animationLoader = PropertyAnimationLoader()
    //end

    //MARK: Variables For Buttons
    enum buttonLocation: String {
        case top
        case right
        case rightTop
    }
    
    private var buttons : Dictionary<buttonLocation,[UIButton_WithIdentifire]> =
        [
            buttonLocation.top : [],
            buttonLocation.right : [],
            buttonLocation.rightTop : []
    ]
    
    private var allButtons: [UIButton_WithIdentifire] {
        let allbuttons = buttons[.top]! + buttons[.right]! + buttons[.rightTop]!
        return allbuttons
    }
    //end
    
    //MARK: Variable for tags
    var _tags: [String]?
    
    var tags: [String]? {
        get {
            return _tags
        } set {
            if newValue != _tags {
                updateTagsWithReloading(newTags: newValue, reload: true)
            }
        }
    }
    //end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PrimarySettings.checkAndCreateSettings(context: context)
        //for authorize - passcode or login
        authorized = true
        
        //if authorizing failed - create a VC for authorize
        requieredBehaviorWhenAuthrizeFailed = {
            [unowned self] in
            let newVC = Giuk_OpenFromFrame_ViewController()
            newVC.closingFunction = {
                [weak self] in
                self?.authorized = true
            }
            self.openViewControllerFromRect(self.topOpeningFrame, viewController: newVC)
        }
        
        //set variables
        transitionAnimator.animationDuration = animationDuration
        transitionAnimator.presentAnimationCurveStyle = .curveEaseOut
        transitionAnimator.dismissAnimationCurveStyle = .curveEaseOut
        view.backgroundColor = .goyaWhite
        
        //set subviews
        setButtonDataSource()
        setContainers()
        setTagView()
        setAnimationView()
        setAnimationBehaviorForInitailAnimation()
        setAnimationBehaviorToAnimationLoader()
        
        //set initailSettings
        if initailStage {
            allButtons.forEach { (button) in
                button.alpha = 0
            }
            containerView_MainContent.alpha = 0
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let setting = PrimarySettings.callSettings(context: context) {
            if let filterName = setting.filterName {
                filterEffect = ImageFilterModule.CIFilterName.requestedFilter(filterName) ?? .CIPhotoEffectTonal
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if animationLoader.animationCondition == .collapsed {
            layoutContainers()
            layoutAnimationView()
            layoutTagView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !initailStage && authorized {
            setTagsOnTagView()
        }
    }
    
    //MARK: Main Button datasource
    func containerViewButtonItem(_ containerView: AnimateButtonView) -> [UIButton_WithIdentifire] {
        switch containerView {
        case animationView_Top :
            return buttons[.top] ?? []
        case animationView_Right :
            return buttons[.right] ?? []
        case animationView_Setting :
            return buttons[.rightTop] ?? []
        default:
            return []
        }
    }
    
    func containerViewButtonAreaRect(_ containerView: AnimateButtonView) -> CGRect {
        switch containerView {
        case animationView_Top :
            return containerView_Top_ButtonAreaFrame
        case animationView_Right :
            return containerView_Right_ButtonAreaFrame
        case animationView_Setting :
            return containerView_Setting_ButtonAreaFrame
        default:
            return CGRect.zero
        }
    }
    
    func buttonsForTop(target: Any = self ,selector: Selector = #selector(handleOntap(_:)), forEvent: UIControl.Event = .touchUpInside) -> [UIButton_WithIdentifire] {
        var controlButtons = [UIButton_WithIdentifire]()
        let addButton = UIButton_WithIdentifire()
        addButton.identifire = buttonLocation.top.rawValue
        addButton.setImage(UIImage(named: ButtonImageNames.ButtonName_Main_Giuk), for: .normal)
        addButton.addTarget(target, action: selector, for: forEvent)
        addButton.backgroundColor = .clear
        controlButtons.append(addButton)
        return controlButtons
    }
    
    func buttonsForRight(target: Any = self ,selector: Selector = #selector(handleOntap(_:)), forEvent: UIControl.Event = .touchUpInside) -> [UIButton_WithIdentifire] {
        var controlButtons = [UIButton_WithIdentifire]()
        let addButton = UIButton_WithIdentifire()
        addButton.identifire = buttonLocation.right.rawValue
        addButton.setImage(UIImage(named: ButtonImageNames.ButtonName_Main_Key), for: .normal)
        addButton.addTarget(target, action: selector, for: forEvent)
        addButton.backgroundColor = .clear
        controlButtons.append(addButton)
        return []
    }
    
    func buttonsForRightTop(target: Any = self ,selector: Selector = #selector(handleOntap(_:)), forEvent: UIControl.Event = .touchUpInside) -> [UIButton_WithIdentifire] {
        var controlButtons = [UIButton_WithIdentifire]()
        let addButton = UIButton_WithIdentifire()
        addButton.identifire = buttonLocation.rightTop.rawValue
        addButton.setTitle("⚙︎", for: .normal)
        addButton.addTarget(target, action: selector, for: forEvent)
        addButton.backgroundColor = .clear
        controlButtons.append(addButton)
        return []
    }
    
    private func setButtonDataSource() {
        buttons[.top] = buttonsForTop()
        buttons[.right] = buttonsForRight()
        buttons[.rightTop] = buttonsForRightTop()
    }
    //end
    
    //MARK: set Sub views
    private func setContainers() {
        let contentContainer = generateUIView(view: containerView_MainContent, origin: contentAreaOrigin_Start, size: contentAreaSize)
        containerView_MainContent = contentContainer
        containerView_MainContent.isOpaque = false
        containerView_MainContent.backgroundColor = .clear
        mainContainer.addSubview(containerView_MainContent)
    }
    
    private func layoutContainers() {
        containerView_MainContent?.setNewFrame(contentAreaOrigin_Start, size: contentAreaSize)
    }
    
    private func setTagView() {
        let newTagView = generateUIView(view: tagView, frame: containerView_MainContent.bounds)
        tagView = newTagView
        tagView.hashTagScrollViewDelegate = self
        tagView.dataSource = self
        tagView.clipsToBounds = true
        tagView.tagItemCornerRadius_Percent = 20
        tagView.itemMinSize = SizeSources.tagItemMinimumSize
        //        tagView.backgroundColor = UIColor(patternImage: UIImage(named: "GiukBackground")!)
        containerView_MainContent.addSubview(tagView)
    }
    
    private func layoutTagView() {
        tagView?.setNewFrame(containerView_MainContent.bounds)
    }
    
    private func setAnimationView() {
        let topAnimationView = generateUIView(view: animationView_Top, frame: topAnimationViewFrame)
        animationView_Top = topAnimationView
        animationView_Top.layer.backgroundColor = animationView_InitailBackgroundColor.cgColor
        animationView_Top.dataSource = self
        animationView_Top.buttonAlignType = .centered
        animationView_Top.isOpaque = false
        mainContainer.addSubview(animationView_Top)
        
        let rightAnimationView = generateUIView(view: animationView_Right, frame: rightAnimationViewFrame)
        animationView_Right = rightAnimationView
        animationView_Right.layer.backgroundColor = animationView_InitailBackgroundColor.cgColor
        animationView_Right.dataSource = self
        animationView_Right.isOpaque = false
        mainContainer.addSubview(animationView_Right)
        
        let settingAnimationView = generateUIView(view: animationView_Setting, frame: settingAnimationViewStartFrame)
        animationView_Setting = settingAnimationView
        animationView_Setting.backgroundColor = .clear
        animationView_Setting.buttonAlignType = .negativeAligned
        animationView_Setting.dataSource = self
        animationView_Setting.isOpaque = false
        mainContainer.addSubview(animationView_Setting)
    }
    
    private func layoutAnimationView() {
        animationView_Top?.setNewFrame(topAnimationViewFrame)
        animationView_Right?.setNewFrame(rightAnimationViewFrame)
        animationView_Setting?.setNewFrame(settingAnimationViewStartFrame)
    }
    //end
    
    //MARK: Initial animation behavior
    func setAnimationBehaviorForInitailAnimation() {
        requieredAnimationWithInInitialStage = { [unowned self] in
            if self.animationLoader.animationCondition == .collapsed {
                self.layoutContainers()
                self.layoutAnimationView()
                self.view.backgroundColor = .goyaYellowWhite
                self.animationView_Top.setNewFrame(
                    self.initialAnimationFrameFor_TopAnimationView(self.initialAnimationFrame_Big)
                        .offSetBy(dX: self.fixedOriginXForInitialAnimation, dY: 0)
                )
                self.animationView_Right.setNewFrame(
                    self.initialAnimationFrameFor_RightAnimationView(self.initialAnimationFrame_Big)
                        .offSetBy(dX: self.fixedOriginXForInitialAnimation, dY: 0)
                )
                //self.animationView_Top.layer.backgroundColor = self.animationView_FinalBackgroundColor.cgColor
                //self.animationView_Right.layer.backgroundColor = self.animationView_FinalBackgroundColor.cgColor
            }
        }
        requieredFunctionWithInInitialStageAnimationCompleted = { [unowned self] in
            self.layoutContainers()
            self.layoutAnimationView()
            self.containerView_MainContent.isInnerShadowRequired = true
            UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
                self.allButtons.forEach({ (button) in
                    button.alpha = 1
                })
                self.containerView_MainContent.alpha = 1
            }, completion: {(finished) in
                self.setTagsOnTagView()
            })
        }
    }
    //end
    
    //MARK: Will Presented ViewController for Button Identifire
    func viewControllerForButtonIdentifire(_ identifire: String) -> Giuk_OpenFromFrame_ViewController? {
        switch identifire {
        case buttonLocation.top.rawValue:
            let newVC = WriteSectionViewController()
            newVC.isEditOnly = false
            return newVC
        case buttonLocation.right.rawValue:
            let newVC = WriteSectionViewController()
            newVC.view.backgroundColor = .GiukBackgroundColor_depth_1
            return newVC
        case buttonLocation.rightTop.rawValue:
            let newVC = Giuk_OpenFromFrame_ViewController()
            newVC.view.backgroundColor = .GiukBackgroundColor_depth_2
            return newVC
        default:
            return nil
        }
    }
    
    private func openingFrameForButtonIdentifire(_ identifire: String) -> CGRect {
        switch identifire {
        case buttonLocation.top.rawValue:
            return topOpeningFrame
        case buttonLocation.right.rawValue:
            return rightOpeningFrame
        case buttonLocation.rightTop.rawValue:
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
    
    private func openViewControllerFromRect(_ rect: CGRect, viewController: UIViewController, duration: TimeInterval) {
        transitionAnimator.setOpeningFrameWithRect(rect)
        transitionAnimator.animationDuration = duration
        viewController.transitioningDelegate = transitionAnimator
        present(viewController, animated: true)
    }
    
    private func requestedViewControllerWithButtonIdentifire(_ identifire: String) -> Giuk_OpenFromFrame_ViewController? {
        var newVC : Giuk_OpenFromFrame_ViewController?
        func setFrameViewControllerClosingFunction(_ controller: Giuk_OpenFromFrame_ViewController?) {
            controller?.closingFunction = {
                [weak self] in
                self?.closingActionWhenPresentedViewControllerDismissed()
            }
        }
        newVC = viewControllerForButtonIdentifire(identifire)
        setFrameViewControllerClosingFunction(newVC)
        return newVC
    }
    
    func closingActionWhenPresentedViewControllerDismissed() {
        performAnimationWithState(.normal, duration: animationDuration)
    }
    //end
    
    //MARK: Will Presneted ViewController AnimationSettings - frametransitiondatasource
    func completionAction_ToViewController(_ viewController: UIViewController) {
        if let controller = viewController as? WriteSectionViewController {
            UIView.animate(withDuration: 0.3) {
                controller.writingSection.alpha = 1
                controller.closeButton.alpha = 1
            }
        } else if let controller = viewController as? GiukViewerViewController {
            UIView.animate(withDuration: 0.3) {
                controller.presentCollectionView.alpha = 1
                controller.frontButtons.forEach { $0?.alpha = 1 }
            }
        }
    }
    
    func initialAction_ToViewController(_ viewController: UIViewController) {
        if let controller = viewController as? WriteSectionViewController {
            controller.filterEffect = filterEffect
            controller.writingSection.alpha = 0
            controller.closeButton.alpha = 0
        } else if let controller = viewController as? GiukViewerViewController{
            controller.filterEffect = filterEffect
            controller.presentCollectionView.alpha = 0
            controller.frontButtons.forEach { $0?.alpha = 0 }
        }
    }
    //end
    
    //MARK: ViewController present button action - animationView's button action
    @objc private func handleOntap(_ sender: UIButton_WithIdentifire) {
        let identifire = sender.identifire
        if let newVC = requestedViewControllerWithButtonIdentifire(identifire) {
            openViewControllerFromRect(openingFrameForButtonIdentifire(identifire), viewController: newVC)
        }
        setAnimateStateForButtonIdentifire(identifire)
        performAnimationWithState(self.animationLoader.animationState)
    }
    
    func setAnimateStateForButtonIdentifire(_ identifire: String) {
        if animationLoader.animationState == .normal {
            switch identifire {
            case buttonLocation.top.rawValue:
                animationLoader.animationState = .topContainerMode
            case buttonLocation.right.rawValue:
                animationLoader.animationState = .rightContainerMode
            case buttonLocation.rightTop.rawValue:
                animationLoader.animationState = .settingMenuContainerMode
            default:
                break
            }
        }
    }
    //end
}

extension Giuk_MainFrame_ViewController {
    
    //MARK: Tag related function
    func setTagsOnTagView() {
        tags = Tag.findAllTags(context: AppDelegate.viewContext)
    }
    
    func updateTagsWithReloading(newTags: [String]? ,reload: Bool) {
        _tags = newTags
        if reload {
            tagView.reloadData(animate: true, duration: animationDuration)
        }
    }
    //end
    
    //MARK: TagView delegate methods
    func hashTagScrollView_tagItems(_ hashTagScrollView: HashTagScrollView) -> [String]? {
        return tags
    }
    
    func hashTagScrollView(_ hashTagScrollView: HashTagScrollView, didSelectItemAt item: Int, tag: String) {
        let identifire = "right"
        setAnimateStateForButtonIdentifire(identifire)
        let newVC = GiukViewerViewController()
        newVC.closingFunction = {
            [weak self] in
            self?.closingActionWhenPresentedViewControllerDismissed()
        }
        newVC.view.backgroundColor = .GiukBackgroundColor_depth_1
        
        //should create tag on main vc? or just passing tagString to present vc.. hm...
        let targetTag = Tag.findTagFromTagName(context: context, tagName: tag)
        newVC.tag = targetTag
        openViewControllerFromRect(openingFrameForButtonIdentifire(identifire), viewController: newVC)
        animationLoader.startInteractiveTransition(state: self.animationLoader.animationState, duration: animationDuration)
        animationLoader.endTransition()
    }
    
    func hashTagScrollView(_ hashTagScrollView: HashTagScrollView, didLongPressedItemAt item: Int, tag: String) {
        let title = DescribingSources.MainTagView.deleteTag_notice_Title + "\n" + "“\(tag)”"
//        let alert = UIAlertController(title: title, message: DescribingSources.MainTagView.deleteTag_notice_SubTiltle, preferredStyle: .alert)
        let alert = WoosunAlertController(title: title, message: DescribingSources.MainTagView.deleteTag_notice_SubTiltle, style: .bottom)
        let confirmButton = WoosunAlertControllerItem(style: .destructive, title: DescribingSources.MainTagView.delete_Title_DeleteAction) {
            let context = self.context
            Tag.findTagFromTagName(context: context, tagName: tag)?.delete(context: context) {
                [weak self] in
                self?.tagView.removeHashItem(at: item)
                self?._tags?.remove(at: item)
            }
        }
        let cancelButton = WoosunAlertControllerItem(style: .cancel, title: DescribingSources.MainTagView.delete_Title_CancelAction, completion: nil)
        alert.addAction(cancelButton)
        alert.addAction(confirmButton)
        
        
//        let confirmButton = UIAlertAction(title: DescribingSources.MainTagView.delete_Title_DeleteAction, style: .destructive) { (action) in
//            let context = self.context
//            Tag.findTagFromTagName(context: context, tagName: tag)?.delete(context: context) {
//                [weak self] in
//                self?.tagView.removeHashItem(at: item)
//                self?._tags?.remove(at: item)
//            }
//        }
//        let cancelButton = UIAlertAction(title: DescribingSources.MainTagView.delete_Title_CancelAction, style: .cancel, handler: nil)
//
//        alert.addAction(cancelButton)
//        alert.addAction(confirmButton)
        
        present(alert, animated: true)
    }
    //end
    
}

extension Giuk_MainFrame_ViewController {
    //MARK: set animation part
    func setAnimationBehaviorToAnimationLoader() {
        animationLoader.settings_BeforeAnimationStarts = {
            [unowned self] (state) in
            self.containerView_MainContent.isUserInteractionEnabled = false
            
            if state != .normal {
                self.allButtons.forEach{ $0.alpha = 0 }
            }
        }
        
        animationLoader.settings_Animations = {
            [unowned self] (state) in
            print("animationcalled")
            
            switch state {
            case .normal :
                self.animationView_Top.frame = self.topAnimationViewStartFrame
                self.animationView_Right.frame = self.rightAnimationViewStartFrame
                self.animationView_Setting.frame = self.settingAnimationViewStartFrame
                self.containerView_MainContent.frame = self.contentAreaFrame_start
//                self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Start
                
            case .topContainerMode :
                self.animationView_Top.frame = self.animationViewAnimatedFrame_Extended
                self.animationView_Right.frame = self.rightAnimationViewAnimatedFrame_Collapsed
                self.animationView_Setting.frame = self.settingAnimationViewAnimatedFrame_Collapsed_TopAnimationViewExtendedCase
                self.containerView_MainContent.frame = self.contentAreaFrame_Collapsed_TopContainerExtended
//                self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Collapsed_TopContainerExtended
                
            case .rightContainerMode :
                self.animationView_Top.frame = self.topAnimationViewAnimatedFrame_Collapsed
                self.animationView_Right.frame = self.animationViewAnimatedFrame_Extended
                self.animationView_Setting.frame = self.settingAnimationViewAnimatedFrame_Collapsed_RightAnimationViewExtendedCase
                self.containerView_MainContent.frame = self.contentAreaFrame_Collapsed_RightContainerExtended
                
//                self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Collapsed_RightContainerExtended
                
            case .settingMenuContainerMode:
                self.animationView_Top.frame = self.animationViewAnimatedFrame_Extended
                self.animationView_Right.frame = self.animationViewAnimatedFrame_Extended
                self.animationView_Setting.frame = self.animationViewAnimatedFrame_Extended
                self.containerView_MainContent.frame = self.contentAreaFrame_Collapsed_SettingContainerExtended
//                self.containerView_MainContent.frame.origin = self.contentAreaOrigin_Collapsed_SettingContainerExtended
            }
            
            self.tagView.frame = self.containerView_MainContent.bounds
        }
        
        animationLoader.settings_Completion = {
            [unowned self] (state) in
            self.containerView_MainContent.isUserInteractionEnabled = true
            if state == .normal {
                UIView.animate(withDuration: 0.25, animations: {
                    self.allButtons.forEach{ $0.alpha = 1 }
                })
            }
        }
    }
    
    //MARK: animation functions
    private func performAnimationWithState(_ state: PropertyAnimationLoader.AnimationState) {
        animationLoader.animationState = state
        animationLoader.startInteractiveTransition(state: animationLoader.animationState, duration: animationDuration)
        animationLoader.endTransition()
    }
    
    private func performAnimationWithState(_ state: PropertyAnimationLoader.AnimationState, duration: TimeInterval) {
        animationLoader.animationState = state
        animationLoader.startInteractiveTransition(state: animationLoader.animationState, duration: duration)
        animationLoader.endTransition()
    }
    
    private func backToNormalState() {
        performAnimationWithState(.normal)
    }
    //end
    //end
}

extension Giuk_MainFrame_ViewController {
    
    //MARK: Computed Frame resource part
    
    //MARK: Grid for initial animation
    var initialAnimationFrame_small: CGRect {
        let viewFrame = view.frame
        let height = viewFrame.height * 0.1618
        let width = height*3/4
        let size = CGSize(width: width, height: height)
        let originX = (viewFrame.width - width)/2
        let originY = (viewFrame.height - height)/2
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)
    }
    
    var initialAnimationFrame_Big: CGRect {
        let ratioFactor: CGFloat = 50/(50 - 23.177)
        let expectedFactor = (fullFrameSize.height - estimateTopContainerHeight)
        let height = expectedFactor * ratioFactor
        let width = height*3/4
        let size = CGSize(width: width, height: height)
        let originX: CGFloat = 0
        let originY = fullFrameSize.height - height
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)
    }
    
    func initialAnimationFrameFor_TopAnimationView(_ from: CGRect) -> CGRect {
        let width = from.size.width
        let height = width/1.618
        let size = CGSize(width: width, height: height)
        let origin = from.origin
        return CGRect(origin: origin, size: size)
    }
    
    func initialAnimationFrameFor_RightAnimationView(_ from: CGRect) -> CGRect {
        let height = from.size.height
        let width = height/2.589
        let size = CGSize(width: width, height: height)
        let origin = from.origin.offSetBy(dX: from.width - width, dY: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var fixedOriginXForInitialAnimation: CGFloat {
        let expectedWidthDeference = initialAnimationFrameFor_TopAnimationView(initialAnimationFrame_Big).width - initialAnimationFrameFor_RightAnimationView(initialAnimationFrame_Big).width + rightAnimationViewAreaWidth
        let requiredFixedOriginX = fullFrameSize.width - expectedWidthDeference
        return requiredFixedOriginX
    }
    //end
    
    
    //MARK: Animation values
    var animationDuration: TimeInterval {
        return 0.5
    }
    
    var animationView_InitailBackgroundColor: UIColor {
        return UIColor.goyaSemiBlackColor.withAlphaComponent(0.7)
    }
    
    var animationView_FinalBackgroundColor: UIColor {
        return UIColor.goyaSemiBlackColor.withAlphaComponent(0.7)
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
    //end
    
    //MARK: Basic Grid values
    var mainContainer: UIView! {
        return view
    }
    
    var fullFrameSize: CGSize {
        return mainContainer?.frame.size ?? CGSize.zero
    }
    
    var fullFrameRatio: CGFloat {
        return fullFrameSize.width/view.frame.width
    }
    
    var fullViewRatio: CGFloat {
        return fullFrameSize.width/fullFrameSize.height
    }
    
    var safeAreaRelatedTopMargin: CGFloat {
        return safeAreaRelatedAreaFrame.minY.absValue * fullFrameRatio
    }
    
    var safeAreaRelatedBottomMargin: CGFloat {
        return (view.frame.height - safeAreaRelatedAreaFrame.maxY) * fullFrameRatio
    }
    
    var topAnimationViewAreaHeight: CGFloat {
        return max(fullFrameSize.height * 0.0818, 45)
    }
    
    var rightAnimationViewAreaWidth: CGFloat {
        if isFullScreenVersion {
            return 0
        } else {
            return topAnimationViewAreaHeight * 0.618
        }
    }
    
    var estimateTopContainerHeight: CGFloat {
        return safeAreaRelatedTopMargin + topAnimationViewAreaHeight
    }
    
    // anchor end
    
    //source frames
    // - Animation View Frames
    
    var topAnimationViewFrame: CGRect {
        if initailStage {
            return initialAnimationFrameFor_TopAnimationView(initialAnimationFrame_small)
        } else {
            return topAnimationViewStartFrame
        }
    }
    
    var topAnimationViewStartFrame: CGRect {
        let size: CGSize = CGSize(width: fullFrameSize.width, height: topAnimationViewAreaHeight + safeAreaRelatedTopMargin)
        let origin = CGPoint(x: 0, y: 0)
        return CGRect(origin: origin, size: size)
    }
    
    var rightAnimationViewFrame: CGRect {
        if initailStage {
            return initialAnimationFrameFor_RightAnimationView(initialAnimationFrame_small)
        } else {
            return rightAnimationViewStartFrame
        }
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
        let estimateWidth = fullFrameSize.width - rightAnimationViewAreaWidth
        let estimateHeight = estimateWidth / fullViewRatio
        return CGRect(x: 0, y: (-estimateHeight), width: estimateWidth, height: estimateHeight)
    }
    
    var rightOpeningFrame: CGRect {
        let estimateHeight = fullFrameSize.height - estimateTopContainerHeight
        let estimateWidth = estimateHeight * fullViewRatio
        return CGRect(x: fullFrameSize.width, y: estimateTopContainerHeight, width: estimateWidth, height: estimateHeight)
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
    
    var contentAreaSize_TopContainerExtended: CGSize {
        let width: CGFloat = view.frame.width
        let height: CGFloat = contentAreaSize.height
        return CGSize(width: width, height: height)
    }
    
    var contentAreaSize_RightContainerExtended: CGSize {
        let width: CGFloat = contentAreaSize.width
        let height: CGFloat = view.frame.height
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
        return CGPoint(x: -contentAreaSize.width, y: 0)
    }
    
    var contentAreaOrigin_Collapsed_SettingContainerExtended: CGPoint {
        let originX = -contentAreaSize.width
        let originY = (fullFrameSize.height + containerView_MainContent.frame.height)
        return CGPoint(x: originX, y: originY)
    }
    
    var contentAreaFrame_start: CGRect {
        return CGRect(origin: contentAreaOrigin_Start, size: contentAreaSize)
    }
    
    var contentAreaFrame_Collapsed_TopContainerExtended: CGRect {
        return CGRect(origin: contentAreaOrigin_Collapsed_TopContainerExtended, size: contentAreaSize_TopContainerExtended)
    }
    
    var contentAreaFrame_Collapsed_RightContainerExtended: CGRect {
        return CGRect(origin: contentAreaOrigin_Collapsed_RightContainerExtended, size: contentAreaSize_RightContainerExtended)
    }
    
    var contentAreaFrame_Collapsed_SettingContainerExtended: CGRect {
        return CGRect(origin: contentAreaOrigin_Collapsed_SettingContainerExtended, size: contentAreaSize)
    }
    
    //Button area frames
    
    var estimateButtonMarign: CGFloat {
        return 5
    }
    
    var estimateTopButtonMarign: CGFloat {
        return 10
    }
    
    var estimateButtonSizeFactor: CGFloat {
        return containerView_Right_ButtonAreaFrame.width
    }
    
    var containerView_Top_ButtonAreaFrame: CGRect {
        let topTriggerSizeHeight = min(CGFloat(40), (topAnimationViewAreaHeight - (estimateTopButtonMarign*2)))
        let topTriggerSizeWidth = fullFrameSize.width - rightAnimationViewAreaWidth - (estimateTopButtonMarign*2) - 16
        let topTriggerOriginX = estimateTopButtonMarign + 8
        let topTriggrtOriginY = animationView_Top.bounds.height - estimateTopButtonMarign - topTriggerSizeHeight
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
