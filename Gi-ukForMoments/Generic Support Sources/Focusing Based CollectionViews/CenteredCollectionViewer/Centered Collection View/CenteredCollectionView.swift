//
//  CenteredCollectionView.swift
//  linearCollectionViewTest
//
//  Created by goya on 24/03/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class CenteredCollectionView: FocusingIndexBasedCollectionView {
    
    //MARK: IBInspectableValues
    @IBInspectable var isHorizontal: Bool = true
    @IBInspectable var isFullscreen: Bool = true
    @IBInspectable var contentMinimumMargin: CGFloat = 0
    //End
    
    //MARK: init Methodes
    convenience init(frame: CGRect, isHorizontal: Bool, isFullscreen: Bool, contentMinimumMargin: CGFloat = 0) {
        self.init(frame: frame, collectionViewLayout: UICollectionViewLayout())
        generateCenteredLayout(displayType_isHorizontal: isHorizontal, displayType_isFullscreen: isFullscreen, contentMinimumMargin: contentMinimumMargin)
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        generateCenteredLayout(displayType_isHorizontal: self.isHorizontal, displayType_isFullscreen: self.isFullscreen, contentMinimumMargin: self.contentMinimumMargin)
        layer.masksToBounds = true
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        generateCenteredLayout(displayType_isHorizontal: self.isHorizontal, displayType_isFullscreen: self.isFullscreen, contentMinimumMargin: self.contentMinimumMargin)
        layer.masksToBounds = true
        self.backgroundColor = .clear
    }
    
    
    //MARK: Variables
    var requiredItemIndex: IndexPath?
    
//    private var focusingIndex : IndexPath? {
//        didSet {
//            if let indexRow = focusingIndex?.item {
//                updateIndexDelegate?.centeredCollectionViewDidUpdateFocusingIndex?(self, withIndexRow: indexRow)
//            }
//        }
//    }
    
   // weak var updateIndexDelegate: CenteredCollectionViewDelegate?
    
    //var transAnimator = ZoomingStyleTransitioningDelegate()
    
    weak var ownerViewController: UIViewController?
    
    weak var willPresentedController_fromCell: UIViewController?
    
    var willPredentedControllerAction_fromCell: ((UIViewController) -> Void)?
    
    var trackingFocusingCellAutomatically: Bool = false
    
    var flowLayouts : UICollectionViewLayout {
        return self.collectionViewLayout
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
        scrollWhenRequiredIndexExist()
    }
    
    override func reloadData() {
        super.reloadData()
        checkNowFocusedCell()
    }
    
    private func scrollWhenRequiredIndexExist() {
        if requiredItemIndex != nil {
            scrollToTargetIndex(index: requiredItemIndex, animated: false)
            focusingIndex = requiredItemIndex
            requiredItemIndex = nil
        } else {
            checkNowFocusedCell()
        }
    }
    
}

extension CenteredCollectionView {
    
    private func checkNowFocusedCell() {
        if let layout = self.flowLayouts as? CenteredCollectionViewFlowLayout {
            let scrollView = self as UIScrollView
            var fixedPosition : CGFloat {
                if layout.isHorizontal {
                    return self.bounds.height/2
                } else {
                    return self.bounds.width/2
                }
            }
            var mutablePosition : CGFloat {
                if layout.isHorizontal {
                    return scrollView.contentOffset.x + layout.draggingOffSet
                } else {
                    return scrollView.contentOffset.y + layout.draggingOffSet
                }
            }
            
            if isHorizontal {
                guard let item = indexPathForItem(at: CGPoint(x: mutablePosition, y: fixedPosition))
                    else {
                        focusingIndex = nil
                        return
                }
                focusingIndex = item
            } else {
                guard let item = indexPathForItem(at: CGPoint(x: fixedPosition, y: mutablePosition))
                    else {
                        focusingIndex = nil
                        return
                }
                focusingIndex = item
            }
        } else {
            focusingIndex = nil
        }
    }
    
    fileprivate func checkWillFocusedCell(_ scrollView: UIScrollView, direction: CGFloat) {
        if let layout = self.flowLayouts as? CenteredCollectionViewFlowLayout {
            var targetIndex : IndexPath?
            var fixedPosition : CGFloat {
                if layout.isHorizontal {
                    return self.bounds.height/2
                } else {
                    return self.bounds.width/2
                }
            }
            
            var mutablePosition : CGFloat {
                if layout.isHorizontal {
                    if direction > 0 {
                        return (scrollView.contentOffset.x) + (layout.draggingOffSet - layout.cellDraggingOffSet)
                    } else if direction < 0 {
                        return ((scrollView.contentOffset.x) + (layout.draggingOffSet + layout.cellDraggingOffSet))
                    } else {
                        return (scrollView.contentOffset.x) + (layout.draggingOffSet)
                    }
                } else {
                    if direction > 0 {
                        return scrollView.contentOffset.y + (layout.draggingOffSet - layout.cellDraggingOffSet)
                    } else if direction < 0 {
                        return scrollView.contentOffset.y + (layout.draggingOffSet + layout.cellDraggingOffSet)
                    } else {
                        return scrollView.contentOffset.y + (layout.draggingOffSet)
                    }
                }
            }
            
            if layout.isHorizontal {
                targetIndex = self.indexPathForItem(at: CGPoint(x: mutablePosition, y: fixedPosition))
            } else {
                targetIndex = self.indexPathForItem(at: CGPoint(x: fixedPosition, y: mutablePosition))
            }
            
            if targetIndex != nil {
                focusingIndex = targetIndex
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        trackingFocusingCellAutomatically = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if trackingFocusingCellAutomatically {
            scrollToTargetIndex(index: focusingIndex, animated: true)
        }
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if trackingFocusingCellAutomatically {
            scrollToTargetIndex(index: focusingIndex, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if trackingFocusingCellAutomatically {
            let translation = scrollView.panGestureRecognizer.translation(in: self)
            if let layOut = self.flowLayouts as? CenteredCollectionViewFlowLayout {
                if layOut.isHorizontal {
                    checkWillFocusedCell(scrollView, direction: translation.x)
                } else {
                    checkWillFocusedCell(scrollView, direction: translation.y)
                }
            }
        }
    }
    
    func scrollToTargetIndex(index : IndexPath?, animated: Bool, completion: (()->Void)? = nil) {
        guard let _index = index else {return}
        let scrollView = self as UIScrollView
        if let layOut = self.flowLayouts as? CenteredCollectionViewFlowLayout {
            scrollView.setContentOffset(layOut.positionOfCellForIndexpath(_index), animated: animated)
        }
        completion?()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("centered collectionview \(indexPath) cell selected")
        guard let cell = collectionView.cellForItem(at: indexPath) else
        { return }
        
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
                    self.checkNowFocusedCell()
                }
            }
        } else if indexPath.item == 0 {
            generateDetailView()
        } else if focusingIndex == nil && indexPath.item > 0 {
            scrollToTargetIndex(index: indexPath, animated: true) {
                [unowned self] in
                self.checkNowFocusedCell()
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


extension UICollectionView {
    
    func generateCenteredLayout(displayType_isHorizontal: Bool, displayType_isFullscreen: Bool, contentMinimumMargin: CGFloat, estimateCellSize: CGSize? = nil) {
        let layout = CenteredCollectionViewFlowLayout()
        if displayType_isHorizontal {
            layout.isHorizontal = displayType_isHorizontal
            layout.isFullscreen = displayType_isFullscreen
            layout.minimumMargin = contentMinimumMargin
            layout.estimateCellSize = estimateCellSize
            self.alwaysBounceHorizontal = true
            self.alwaysBounceVertical = false
        } else {
            layout.isHorizontal = displayType_isHorizontal
            layout.isFullscreen = displayType_isFullscreen
            layout.minimumMargin = contentMinimumMargin
            layout.estimateCellSize = estimateCellSize
            self.alwaysBounceHorizontal = false
            self.alwaysBounceVertical = true
        }
        
        self.collectionViewLayout = layout
        self.reloadData()
    }
    
    func setVerticalPopUpCollectionViewLayout() {
        let layout = VerticalSpotlightCollectionViewFlowLayout()
        self.collectionViewLayout = layout
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }
}
