//
//  VerticalLinearCollectionView.swift
//  linearCollectionViewTest
//
//  Created by goya on 31/12/2018.
//  Copyright © 2018 goya. All rights reserved.
//

import UIKit

class VerticalLinearCollectionView: FocusingIndexBasedCollectionView {
    
    //init frame calls when view has initiallize with code
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setVerticalPopUpCollectionViewLayout()
        let scrollview = self as UIScrollView
        scrollview.decelerationRate = .normal
        scrollview.alwaysBounceVertical = true
        clipsToBounds = true
        self.backgroundColor = .clear
        //print("init frame called")
    }
    
    //init coder calls when view has came from Storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setVerticalPopUpCollectionViewLayout()
        let scrollview = self as UIScrollView
        scrollview.decelerationRate = .normal
        scrollview.alwaysBounceVertical = true
        clipsToBounds = true
        self.backgroundColor = .clear
        //print("init coder called")
    }
    
    //convenience init can be used to provide your view to escape some layout or sequence issue
    //And helps to setup more variable and functions for initialize
    convenience init(frame: CGRect, registCellNibName: String? = nil) {
        self.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        setVerticalPopUpCollectionViewLayout()
        let scrollview = self as UIScrollView
        scrollview.decelerationRate = .normal
        scrollview.alwaysBounceVertical = true
        clipsToBounds = true
        self.backgroundColor = .clear
        if let nibName = registCellNibName {
            self.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: nibName)
        }
    }
    
    //weak var focusingCellCheckingDelegate: VerticalLinearCollectionViewDelegate?
    
    var trackingFocusingCellAutomatically: Bool = false
    
    var requiredItemIndex: IndexPath?
    
    //var transAnimator = ZoomingStyleTransitioningDelegate()
    
    let storyBoard = UIStoryboard(name: "Main", bundle: Bundle.main)
    
    weak var ownerViewController: UIViewController?
    
    weak var willPresentedController_fromCell: UIViewController?
    
    var willPredentedControllerAction_fromCell: ((UIViewController) -> Void)?
    
    private var flowLayouts : VerticalSpotlightCollectionViewFlowLayout {
        return (self.collectionViewLayout as? VerticalSpotlightCollectionViewFlowLayout) ?? VerticalSpotlightCollectionViewFlowLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if trackingFocusingCellAutomatically == false {
            scrollWhenRequiredIndexExist()
        }
    }
    
    override var frame: CGRect {
        didSet {
            //if frame size changed. relayout with now focused cell get centered.
            if frame.size != oldValue.size {
                trackingFocusingCellAutomatically = false
                if requiredItemIndex == nil {
                    requiredItemIndex = focusingIndex
                }
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
//        scrollWhenRequiredIndexExist()
        checkNowFocused()
    }
    
    private func scrollWhenRequiredIndexExist() {
        if requiredItemIndex != nil {
            scrollToTargetIndex(index: requiredItemIndex, animated: false)
            focusingIndex = requiredItemIndex
            requiredItemIndex = nil
        } else {
           // checkNowFocused()
        }
    }

}


extension VerticalLinearCollectionView {
    
    private func checkNowFocused() {
        let layout = self.flowLayouts
        let scrollView = self as UIScrollView
        let x = self.center.x
        var y : CGFloat {
                return scrollView.contentOffset.y + (layout.cellFeaturedHeight * 0.5)
        }
        let targerIndex = self.indexPathForItem(at: CGPoint(x: x, y: y))
        focusingIndex = targerIndex
    }
    
    private func checkWillFocusedCell(_ scrollView: UIScrollView, direction: CGFloat) {
        let layout = self.flowLayouts //as StandardVisualLayout
        let x = self.frame.midX
        var y : CGFloat {
            if direction > 0 {
                return scrollView.contentOffset.y + (layout.cellFeaturedHeight * 0.15)
            } else if direction < 0 {
                return scrollView.contentOffset.y + (layout.cellFeaturedHeight * 0.95)
            } else {
                return scrollView.contentOffset.y + (layout.cellFeaturedHeight * 0.5)
            }
        }
        let targerIndex = self.indexPathForItem(at: CGPoint(x: x, y: y))
        focusingIndex = targerIndex
    }
    
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollToTargetIndex(index: focusingIndex, animated: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollToTargetIndex(index: focusingIndex, animated: true)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        trackingFocusingCellAutomatically = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let translation = scrollView.panGestureRecognizer.translation(in: self)
        checkWillFocusedCell(scrollView, direction: translation.y)
    }
    
    func scrollToTargetIndex(index : IndexPath?, animated: Bool, completion: (()->Void)? = nil) {
        guard let _index = index else {return}
        let scrollView = self as UIScrollView
        let layOut = self.flowLayouts as VerticalSpotlightCollectionViewFlowLayout
        let position = layOut.dragOffset * CGFloat(_index.item) + layOut.minMarginForPreventinglayOutIssue
        scrollView.setContentOffset(CGPoint(x: 0, y: position), animated: animated)
        completion?()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {
            return
        }
        //print(indexPath)
        
        func generateDetailView() {
            setTransitionAnimatorFromCell(collectionView, indexPath: indexPath)
            if let detailViewController = willPresentedController_fromCell {
                //detailViewController.transitioningDelegate = transAnimator
                detailViewController.modalPresentationStyle = .custom
                willPredentedControllerAction_fromCell?(detailViewController)
                ownerViewController?.present(detailViewController, animated: true, completion: nil)
            } else { return }
        }
        
        if let focusedCellIndex = focusingIndex {
            if indexPath == focusedCellIndex {
                generateDetailView()
            } else {
                scrollToTargetIndex(index: indexPath, animated: true) {
                    [unowned self] in
                    self.checkNowFocused()
                }
            }
        } else if indexPath.item == 0 {
            generateDetailView()
        } else if focusingIndex == nil || indexPath.item != focusingIndex?.item {
            scrollToTargetIndex(index: indexPath, animated: true) {
                [unowned self] in
                self.checkNowFocused()
            }
        }
    }
    
    private func setTransitionAnimatorFromCell(_ collectionView: UICollectionView, indexPath: IndexPath) {
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        let attributesFrame = attributes?.frame
        let frameToOpenFrom = collectionView.convert(attributesFrame!, to: collectionView.superview)
        //transAnimator.setOpeningFrameWithRect(frameToOpenFrom)
    }
}
