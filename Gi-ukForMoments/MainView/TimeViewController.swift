//
//  TimeViewController.swift
//  LinearTimeLineViewDemo
//
//  Created by goya on 09/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class TimeViewController: UIViewController {
    
    @IBOutlet weak var safeAreaLayoutGuideFrame: UIView!
    
    var checker = DateChecker(date: Date.currentDate.dateWithDateComponents)
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    enum CardState {
        case expanded
        case collapsed
    }
    
    var nextState: CardState {
        return cardVisible ? .collapsed : .expanded
    }
    
    var cardHeight_expanded: CGFloat {
        return (self.safeAreaLayoutGuideFrame.frame.height * 0.9).clearUnderDot
    }
    
    var cardHeight_colapsed: CGFloat {
        //return cardHeight_expanded * 0.085
        return (self.innerBottomFrame.height * 0.4).clearUnderDot
    }
    
    var cardVisible: Bool = false
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    var timeViewer: TimeCollectionViewer!
    
    var effectView: UIVisualEffectView!
    
    var bottomCurverView: UIView!
    
    var monthLabel: UILabel!
    
    lazy var photoSelector: PhotoTestViewController = {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let photoVC = storyBoard.instantiateViewController(withIdentifier: "PhotoSelectController") as! PhotoTestViewController
        photoVC.view.clipsToBounds = true
        addChild(photoVC)
        view.addSubview(photoVC.view)
        photoVC.view.frame = self.cardFrame
        photoVC.view.setNeedsLayout()
        return photoVC
    }()
    
    lazy var timeSelector: TimeSettingViewController = {
        let storyBoard = UIStoryboard(name: "Main", bundle: .main)
        let timeVC = storyBoard.instantiateViewController(withIdentifier: "TimeSelectorViewController") as! TimeSettingViewController
        timeVC.view.clipsToBounds = true
        timeVC.view.backgroundColor = UIColor.goyaWhite
        
        timeVC.requestedFunctionWhenDateUpdated = {
            [weak self] (date) in
            self?.timeViewer.nowDate = date
        }
        addChild(timeVC)
        view.addSubview(timeVC.view)
        timeVC.view.frame = self.cardFrame
        timeVC.view.setNeedsLayout()
        return timeVC
    }()
    
    lazy var timeSelectors: TimeSetViewController = {
        let nibName = TimeSetViewController.nib_Name
        let timeVC = TimeSetViewController(nibName: nibName, bundle: nil)
        timeVC.view.clipsToBounds = true
        timeVC.view.backgroundColor = UIColor.goyaWhite
        
        timeVC.requestedFunctionWhenDateUpdated = {
            [weak self] (date) in
            self?.timeViewer.nowDate = date
        }
        addChild(timeVC)
        view.addSubview(timeVC.view)
        timeVC.view.frame = self.cardFrame
        timeVC.view.setNeedsLayout()
        return timeVC
    }()
    
    func setGestureToTimeSelector() {
        timeSelector.updateConstraintsWithVlaue(top: timeSelector.view.frame.height * 0.1, handleAreaHeight: self.cardHeight_colapsed)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardtap(recognizer:)))
        tapGesture.numberOfTapsRequired = 1
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCardpan(recognizer:)))
        
        timeSelector.handlingArea.addGestureRecognizer(tapGesture)
        timeSelector.handlingArea.addGestureRecognizer(panGesture)
    }
    
    func setGestureToPhotoSelector() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleCardtap(recognizer:)))
        tapGesture.numberOfTapsRequired = 1
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCardpan(recognizer:)))
        
        photoSelector.handlingArea.addGestureRecognizer(tapGesture)
        photoSelector.handlingArea.addGestureRecognizer(panGesture)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print(UIDevice.modelName)
        view.backgroundColor = UIColor.goyaYellowWhite
        
        setEffectView()
        
//        setGestureToTimeSelector()
        
        setGestureToPhotoSelector()
        
        setBottomCurverView()
        
        setTimeViewer()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        relayOutSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        relayOutSubviews()
    }
    
    private func relayOutSubviews() {
        bottomCurverView.setNewFrame(bottomFrame)
        timeViewer.setNewFrame(innerBottomFrame)
//        timeSelector.setNewFrame(cardFrame)
//        timeSelector.updateConstraintsWithVlaue(top: timeSelector.view.frame.height * 0.1, handleAreaHeight: self.cardHeight_colapsed)
        photoSelector.setNewFrame(cardFrame)
        photoSelector.view.layoutIfNeeded()
    }
    
    private func setEffectView() {
        effectView = UIVisualEffectView()
        effectView.frame = self.view.frame
        view.addSubview(effectView)
    }
    
    private func setBottomCurverView() {
        let curverView = UIView(frame: bottomFrame)
        curverView.backgroundColor = UIColor.goyaSemiBlackColor
        bottomCurverView = curverView
        view.addSubview(curverView)
    }
    
    private func setTimeViewer() {
        timeViewer = TimeCollectionViewer(frame: innerBottomFrame)
        timeViewer.requestedFunctionWhenCellDidSelected = {
            [weak self] (collectionView, indexPath, cell) in
            if let targetCell = cell as? ColorCollectionViewCell {
//                self?.timeSelector.timeChecker = DateChecker(date: targetCell.date!)
//                self?.timeSelector.updateLabelsWithDate()
            }
        }
        timeViewer.requestedFunctionWhenNowDateChanged = {
            [weak self] (date) in
//            self?.timeSelector.timeChecker = DateChecker(date: date)
            self?.photoSelector.requestedDate = date
        }
        bottomCurverView.addSubview(timeViewer)
    }

}

extension TimeViewController {
    //MARK: subFrames and factors
    var cardFrame: CGRect {
        let size = CGSize(width: self.view.frame.width, height: cardHeight_expanded)
        let origin = CGPoint(x: 0, y: self.bottomFrame.origin.y - self.cardHeight_colapsed)
        return CGRect(origin: origin, size: size)
    }
    
    var bottomFrame: CGRect {
        let width = self.view.frame.width
        let height = (width / 5/*(2.621 + 1.618)*/).clearUnderDot
        let originY = self.view.frame.height - height - (bottomExtention) - bottomMargin
        let originX: CGFloat = 0
        return CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: width, height: height + bottomExtention + bottomMargin))
    }
    
    var innerBottomFrame: CGRect {
        let margins : CGFloat = 10
        let width = bottomFrame.width
        let height = ((bottomFrame.height) - bottomExtention)
        let expectedWidth = width - margins
        let expectedHeight = (height - margins) - bottomMargin
        let originY = margins/2
        let originX = margins/2
        return CGRect(origin: CGPoint(x: originX, y: originY), size: CGSize(width: expectedWidth, height: expectedHeight))
    }
    
    var bottomMargin: CGFloat {
        return (view.frame.height * 0.01618).clearUnderDot.absValue
    }
    
    var bottomExtention: CGFloat {
        return (view.frame.height - bottomGuideOriginY).clearUnderDot.absValue
    }
    
    var bottomGuideOriginY: CGFloat {
        return safeAreaLayoutGuideFrame.frame.maxY
    }
}

extension TimeViewController {
    //MARK: handle timeselector area functions
    
    @objc
    func handleCardtap(recognizer: UITapGestureRecognizer) {
        startInteractiveTransition(state: nextState, duration: 0.9) {
            [unowned self] in
            if self.nextState == .expanded {
                //                self.timeViewer.refreshDatesWithOrigin(date:  self.timeSelector.timeChecker.date)
                self.photoSelector.clearImageView()
            }
        }
        photoSelector.changePhotoModuleRequestType(type: .aDay)
        endTransition()
    }
    
    @objc
    func handleCardpan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            startInteractiveTransition(state: nextState, duration: 0.9) {
                [unowned self] in
                if self.nextState == .expanded {
                    self.photoSelector.clearImageView()
                }
            }
            photoSelector.changePhotoModuleRequestType(type: .aDay)
        case .changed:
            let translation = recognizer.translation(in: self.photoSelector.handlingArea)
            var fractionCompleted = translation.y / cardHeight_expanded
            fractionCompleted = cardVisible ? fractionCompleted : -fractionCompleted
            updateTranstion(fractionCompleted: fractionCompleted)
        case .ended:
            endTransition {
                if self.nextState == .collapsed {
//                    self.timeViewer.refreshDatesWithOrigin(date: self.timeSelector.timeChecker.date)
                }
            }
        default:
            break
        }
    }
    
    func animationTranstionIfNeeded(state: CardState, duration: TimeInterval, completion: (()->Void)? = nil) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                [unowned self] in
                switch state {
                case .expanded :
                    self.photoSelector.view.frame.origin.y = (self.view.frame.height - self.cardHeight_expanded)
                case .collapsed :
                    self.photoSelector.view.frame.origin.y = (self.bottomFrame.origin.y - self.cardHeight_colapsed)
                }
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let cornerAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
                [unowned self] in
                switch state {
                case .expanded :
                    self.photoSelector.view.layer.cornerRadius = 12
                case .collapsed :
                    self.photoSelector.view.layer.cornerRadius = 0
                }
            }
            
            cornerAnimator.startAnimation()
            runningAnimations.append(cornerAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                [unowned self] in
                switch state {
                case .expanded :
                    let effect = UIBlurEffect(style: .light)
                    self.effectView.effect = effect
                    self.bottomCurverView.frame.origin.y = self.view.frame.height
                    //self.timeViewer.frame.origin.y = self.view.frame.height
                case .collapsed :
                    self.effectView.effect = nil
                    self.bottomCurverView.frame.origin.y = self.bottomFrame.origin.y
                    //self.timeViewer.frame.origin.y = self.subFrame.origin.y
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
            //when animation ended
            frameAnimator.addCompletion { [unowned self] (_) in
                self.cardVisible = !self.cardVisible
                self.runningAnimations.removeAll()
                completion?()
            }
            //
        }
    }
    
    func startInteractiveTransition(state: CardState, duration: TimeInterval, completion: (()->Void)? = nil) {
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
}
