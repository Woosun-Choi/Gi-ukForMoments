//
//  CenteredCollectionView.swift
//  linearCollectionViewTest
//
//  Created by goya on 24/03/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class CenteredCollectionView: FocusingIndexBasedCollectionView {
    
    //MARK: Variables
    @IBInspectable var isHorizontal: Bool = true
    
    @IBInspectable var isFullscreen: Bool = true
    
    @IBInspectable var contentMinimumMargin: CGFloat = 0
    
    var requiredItemIndex: IndexPath?
    
    var is3DPresentingCell : Bool = true
    
    var flowLayouts : UICollectionViewLayout {
        return self.collectionViewLayout
    }
    //end
    
    override func reloadData() {
        super.reloadData()
        if let currentIndex = requiredItemIndex {
            if currentIndex.row < self.numberOfItems(inSection: currentIndex.section) {
                focusingIndex = requiredItemIndex
            } else {
                requiredItemIndex = IndexPath(item: (numberOfItems(inSection: currentIndex.section) - 1).absValue, section: currentIndex.section)
                focusingIndex = nil
            }
        } else {
            focusingIndex = nil
        }
        scrollWhenRequiredIndexExist()
    }
    
    func refreshAllData() {
        requiredItemIndex = nil
        reloadData()
    }
    
    func setStartIndexTo(_ index: IndexPath?) {
        self.requiredItemIndex = index
    }
    
    func scrollToTargetIndex(index : IndexPath?, animated: Bool) {
        guard let _index = index else {return}
        requiredItemIndex = nil
        if (_index.row < self.numberOfItems(inSection: _index.section)) {
            let scrollView = self as UIScrollView
            if let layOut = self.flowLayouts as? CenteredCollectionViewFlowLayout {
                scrollView.setContentOffset(layOut.positionOfCellForIndexpath(_index), animated: animated)
            }
        }
    }
    
    private func scrollToIndex(index : IndexPath?, animated: Bool) {
        guard let _index = index else {return}
        if (_index.row < self.numberOfItems(inSection: _index.section)) {
            let scrollView = self as UIScrollView
            if let layOut = self.flowLayouts as? CenteredCollectionViewFlowLayout {
                scrollView.setContentOffset(layOut.positionOfCellForIndexpath(_index), animated: animated)
            }
        }
    }
    
    //MARK: update layouts
    private func scrollWhenRequiredIndexExist() {
        if let required = requiredItemIndex {
            scrollToIndex(index: required, animated: false)
        } else {
            if let _ = focusingIndex {
            } else {
                checkNowCenteredFocusedCell(collectionView: self)
                if let currentFocused = focusingIndex {
                    scrollToIndex(index: currentFocused, animated: false)
                }
            }
        }
        updateTransform()
    }
    
    override var frame: CGRect {
        didSet {
            //if frame size changed. relayout with now focused cell get centered.
            if frame.size != oldValue.size {
                if requiredItemIndex == nil {
                    requiredItemIndex = focusingIndex
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollWhenRequiredIndexExist()
    }
    
    override func draw(_ rect: CGRect) {
//        scrollWhenRequiredIndexExist()
    }
    //end
    
    //MARK: overrided scrollview delegate from focusingindexbasedscrollview
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        scrollToIndex(index: focusingIndex, animated: true)
        focusingCollectionViewDelegate?.collectionViewScrollingState?(self, scrolling: false)
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        scrollToIndex(index: focusingIndex, animated: true)
    }
    
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
}

extension CenteredCollectionView {
    
    //MARK: scrollview delegates
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        requiredItemIndex = nil
        focusingCollectionViewDelegate?.collectionViewScrollingState?(self, scrolling: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollToIndex(index: focusingIndex, animated: true)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollToIndex(index: focusingIndex, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkWillFocusedCell(collectionView: self)
        updateTransform()
    }
    //end
    
    //MARK: focuing part
    var focusingArea: CGRect {
        if isHorizontal {
            let _width = bounds.width * 0.7
            let _height = bounds.height
            let size = CGSize(width: _width, height: _height)
            let originX = (contentOffset.x + ((bounds.width - _width)/2))
            let originY = (bounds.origin.y)
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        } else {
            let _width = bounds.width
            let _height = bounds.height * 0.8
            let size = CGSize(width: _width, height: _height)
            let originX = (bounds.origin.x)
            let originY = ((bounds.origin.y) + (bounds.height) - _height)
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        }
    }
    
    func checkFrameIsInFocusingArea(_ frame: CGRect?) -> Bool {
        if let targetFrame = frame {
            return focusingArea.intersects(targetFrame)
        } else {
            return false
        }
    }
    
    func cellFrame(collectionView: UICollectionView, cell: UICollectionViewCell) -> CGRect? {
        guard let indexPath = collectionView.indexPath(for: cell) else {
            assert(true, "cell missing")
            return nil }
        guard let attributes = collectionView.layoutAttributesForItem(at: indexPath) else {
            assert(true, "attribute missing")
            return nil }
        return attributes.frame
    }
    
    func checkCellIsInFocusingArea(collectionView: UICollectionView ,cell: UICollectionViewCell) -> (matching: Bool, index: IndexPath?) {
        let cellInfo = self.informationOfCell(cell: cell)
        let cellFrame = cellInfo.attributeCellFrame
        let cellIndex = cellInfo.index
        return (checkFrameIsInFocusingArea(cellFrame), cellIndex)
    }
    
    func checkWillFocusedCell(collectionView: UICollectionView) {
        let velocity = collectionView.panGestureRecognizer.velocity(in: collectionView)
        for cell in collectionView.visibleCells {
            let cellIsInFocusingArea = checkCellIsInFocusingArea(collectionView: collectionView, cell: cell)
            if velocity.x > 0 {
                if cellIsInFocusingArea.matching {
                    if let index = cellIsInFocusingArea.index {
                        if focusingIndex == nil {
                            focusingIndex = index
                        } else {
                            if (focusingIndex != cellIsInFocusingArea.index) && focusingIndex!.item > index.item {
                                focusingIndex = index
                            }
                        }
                    }
                }
            } else if velocity.x < 0 {
                if cellIsInFocusingArea.matching {
                    if let index = cellIsInFocusingArea.index {
                        if focusingIndex == nil {
                            focusingIndex = index
                        } else {
                            if (focusingIndex != cellIsInFocusingArea.index) && focusingIndex!.item < index.item {
                                focusingIndex = index
                            }
                        }
                    }
                }
            }
        }
    }
    
    func checkNowFocusedCell(collectionView: UICollectionView) {
        for cell in collectionView.visibleCells {
            let cellIsInFocusingArea = checkCellIsInFocusingArea(collectionView: collectionView, cell: cell)
            if cellIsInFocusingArea.matching {
                if let index = cellIsInFocusingArea.index {
                    focusingIndex = index
                }
            }
        }
    }
    
    //MARK: check centeredCell
    func checkAreaSizeInFocusingArea(_ frame: CGRect?) -> CGFloat {
        if let targetFrame = frame {
            let value = focusingArea.intersection(targetFrame).areaSize
            return value
        } else {
            return 0
        }
    }
    
    func areaSizeOfCellInFocusingArea(collectionView: UICollectionView ,cell: UICollectionViewCell) -> (size: CGFloat, index: IndexPath?) {
        let cellInfo = self.informationOfCell(cell: cell)
        let cellFrame = cellInfo.attributeCellFrame
        let cellIndex = cellInfo.index
        return (checkAreaSizeInFocusingArea(cellFrame), cellIndex)
    }
    
    func checkNowCenteredFocusedCell(collectionView: UICollectionView) {
        var indexs = [(size: CGFloat, index: IndexPath?)]()
        
        for cell in collectionView.visibleCells {
            let cellIsInFocusingArea = areaSizeOfCellInFocusingArea(collectionView: collectionView, cell: cell)
            indexs.append(cellIsInFocusingArea)
        }
        
        indexs.sort{ $0.size > $1.size }
        
        focusingIndex = indexs.first?.index
    }
    //end
    
    //MARK: 3D presenting cell method
    fileprivate func animateCell(cellFrame: CGRect, contentOffSet: CGFloat) -> CATransform3D? {
        let angleFromX = -Double(((cellFrame.origin.x - contentOffSet)) / 8)
        let angle = CGFloat((angleFromX * Double.pi) / 180.0)
        var transform = CATransform3DIdentity
        transform.m34 = -1.0/1000
        
        let factor = (cellFrame.origin.x - contentOffSet)/cellFrame.width * 100
        
        if angleFromX < 0 {
            var scaleFromX = (1000 + (factor)*3) / 1000
            let scaleMax: CGFloat = 1.0
            let scaleMin: CGFloat = 0.6
            if scaleFromX > scaleMax {
                scaleFromX = scaleMax
            }
            if scaleFromX < scaleMin {
                scaleFromX = scaleMin
            }
            let rotation = CATransform3DRotate(transform, angle, 0, 1, 0)
            let scale = CATransform3DScale(CATransform3DIdentity, scaleFromX, scaleFromX, 1)
            return CATransform3DConcat(rotation, scale)
        } else {
            var scaleFromX = (1000 - (factor)*3) / 1000
            let scaleMax: CGFloat = 1.0
            let scaleMin: CGFloat = 0.6
            if scaleFromX > scaleMax {
                scaleFromX = scaleMax
            }
            if scaleFromX < scaleMin {
                scaleFromX = scaleMin
            }
            let rotation = CATransform3DRotate(transform, angle, 0, 1, 0)
            let scale = CATransform3DScale(CATransform3DIdentity, scaleFromX, scaleFromX, 1)
            return CATransform3DConcat(rotation, scale)
        }
    }
    
    func updateTransform() {
        if is3DPresentingCell {
            if let layout = self.collectionViewLayout as? CenteredCollectionViewFlowLayout {
                for cell in self.visibleCells {
                    if let _cellFrame = self.attributeFrameOfCell(cell: cell) {
                        if let transform = animateCell(cellFrame: _cellFrame, contentOffSet: self.contentOffset.x.absValue + layout.leftOverMargin) {
                            cell.layer.transform = transform
                        }
                    }
                }
            }
        }
    }
    //end
    
    //MARK: collectionView delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("centered collectionview \(indexPath) cell selected")
        guard let cell = collectionView.cellForItem(at: indexPath) else
        { return }
        if let focusedCellIndex = focusingIndex {
            if indexPath == focusedCellIndex {
                focusingCollectionViewDelegate?.collectionViewDidSelectFocusedIndex?(self, focusedIndex: indexPath, cell: cell)
            } else {
                focusingIndex = indexPath
                focusingCollectionViewDelegate?.collectionViewScrollingState?(self, scrolling: true)
                scrollToIndex(index: indexPath, animated: true)
            }
        } else {
            focusingIndex = indexPath
            focusingCollectionViewDelegate?.collectionViewScrollingState?(self, scrolling: true)
            scrollToIndex(index: indexPath, animated: true)
        }
    }
}

//private func setTransitionAnimatorFromCell(_ collectionView: UICollectionView, indexPath: IndexPath) {
//    let attributes = collectionView.layoutAttributesForItem(at: indexPath)
//    let attributesFrame = attributes?.frame
//    let frameToOpenFrom = collectionView.convert(attributesFrame!, to: collectionView.superview)
//    //transAnimator.setOpeningFrameWithRect(frameToOpenFrom)
//}

//func generateDetailView() {
//    setTransitionAnimatorFromCell(collectionView, indexPath: indexPath)
//    if let detailViewController = willPresentedController_fromCell {
//        //detailViewController.transitioningDelegate = transAnimator
//        detailViewController.modalPresentationStyle = .custom
//        willPredentedControllerAction_fromCell?(detailViewController)
//        ownerViewController?.present(detailViewController, animated: true, completion: nil)
//    } else { return }
//}

//private func checkNowFocusedCell() {
//    if let layout = self.flowLayouts as? CenteredCollectionViewFlowLayout {
//        let scrollView = self as UIScrollView
//        var fixedPosition : CGFloat {
//            if layout.isHorizontal {
//                return self.bounds.height/2
//            } else {
//                return self.bounds.width/2
//            }
//        }
//        var mutablePosition : CGFloat {
//            if layout.isHorizontal {
//                return scrollView.contentOffset.x + layout.draggingOffSet
//            } else {
//                return scrollView.contentOffset.y + layout.draggingOffSet
//            }
//        }
//
//        if isHorizontal {
//            guard let item = indexPathForItem(at: CGPoint(x: mutablePosition, y: fixedPosition))
//                else {
//                    focusingIndex = nil
//                    return
//            }
//            focusingIndex = item
//        } else {
//            guard let item = indexPathForItem(at: CGPoint(x: fixedPosition, y: mutablePosition))
//                else {
//                    focusingIndex = nil
//                    return
//            }
//            focusingIndex = item
//        }
//    } else {
//        focusingIndex = nil
//    }
//}

//fileprivate func checkWillFocusedCell(_ scrollView: UIScrollView, direction: CGFloat) {
//    if let layout = self.flowLayouts as? CenteredCollectionViewFlowLayout {
//        var targetIndex : IndexPath?
//        var fixedPosition : CGFloat {
//            if layout.isHorizontal {
//                return self.bounds.height/2
//            } else {
//                return self.bounds.width/2
//            }
//        }
//
//        var mutablePosition : CGFloat {
//            if layout.isHorizontal {
//                if direction > 0 {
//                    return (scrollView.contentOffset.x) + (layout.draggingOffSet - layout.cellDraggingOffSet)
//                } else if direction < 0 {
//                    return ((scrollView.contentOffset.x) + (layout.draggingOffSet + layout.cellDraggingOffSet))
//                } else {
//                    return (scrollView.contentOffset.x) + (layout.draggingOffSet)
//                }
//            } else {
//                if direction > 0 {
//                    return scrollView.contentOffset.y + (layout.draggingOffSet - layout.cellDraggingOffSet)
//                } else if direction < 0 {
//                    return scrollView.contentOffset.y + (layout.draggingOffSet + layout.cellDraggingOffSet)
//                } else {
//                    return scrollView.contentOffset.y + (layout.draggingOffSet)
//                }
//            }
//        }
//
//        if layout.isHorizontal {
//            targetIndex = self.indexPathForItem(at: CGPoint(x: mutablePosition, y: fixedPosition))
//        } else {
//            targetIndex = self.indexPathForItem(at: CGPoint(x: fixedPosition, y: mutablePosition))
//        }
//
//        if targetIndex != nil {
//            focusingIndex = targetIndex
//        }
//    }
//}
