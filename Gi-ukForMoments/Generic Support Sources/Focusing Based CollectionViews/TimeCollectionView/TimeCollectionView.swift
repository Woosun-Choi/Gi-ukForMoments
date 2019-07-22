//
//  TimeCollectionView.swift
//  LinearTimeLineViewDemo
//
//  Created by goya on 08/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol TimeCollectionViewDelegate: class {
    @objc optional func timeCollectionViewDidUpdateFocusingIndex(_ collectionView: TimeCollectionView, focusedIndex: IndexPath)
    @objc optional func timeCollectionViewDidEndUpdateFocusingIndex(_ collectionView: TimeCollectionView, finished: Bool)
    @objc optional func timeCollectionViewDidSelecteFocusedIndex(_ collectionView: TimeCollectionView, focusedIndex: IndexPath, cell: UICollectionViewCell)
}

class TimeCollectionView: FocusingIndexBasedCollectionView {
    
    override var dataSource: UICollectionViewDataSource? {
        didSet {
            //setOriginState()
        }
    }
    
    var is3DPresentingCell : Bool = true
    
//    weak var pointerView: UIView!
//
//    func setPointerView() {
//        if pointerView == nil {
//            let newView = generateUIView(view: pointerView, frame: focusingArea)
//            pointerView = newView
//            pointerView.backgroundColor = .red
//            addSubview(pointerView)
//        } else {
//            pointerView?.setNewFrame(focusingArea)
//        }
//    }
    
    var requiredItemIndex: IndexPath?
    
    private var maxIndex: IndexPath {
        let max = self.numberOfItems(inSection: 0)
        return IndexPath(item: max - 1, section: 0)
    }
    
//    var trackingFocusingCellAutomatically: Bool = false
    
    private var flowLayout: UICollectionViewLayout {
        return self.collectionViewLayout
    }
    
    override var frame: CGRect {
        didSet {
            //if frame size changed. relayout with now focused cell get centered.
            if frame.size != oldValue.size {
//                trackingFocusingCellAutomatically = false
                if requiredItemIndex == nil {
                    requiredItemIndex = focusingIndex
                    scrollWhenRequiredIndexExist()
                }
            }
        }
    }
    
    private func setOriginState() {
        self.requiredItemIndex = maxIndex
    }
    
    func setStartState(with index: IndexPath, completion:(()->Void)? = nil) {
//        self.trackingFocusingCellAutomatically = false
        self.requiredItemIndex = index
        self.reloadData()
        //self.trackingFocusingCellAutomatically = true
        completion?()
    }
    
    private func scrollWhenRequiredIndexExist() {
        if requiredItemIndex != nil {
            scrollToTargetIndex(index: requiredItemIndex, animated: false)
            focusingIndex = requiredItemIndex
            requiredItemIndex = nil
        } else {
            checkNowFocusedCell(collectionView: self)
            (is3DPresentingCell) ? updateTransform() : ()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        scrollWhenRequiredIndexExist()
    }
    
    //MARK: override delegate
    override func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        super.scrollViewDidEndScrollingAnimation(scrollView)
        focusingCollectionViewDelegate?.collectionViewScrollingState?(self, scrolling: false)
    }
    //end
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        if trackingFocusingCellAutomatically == false {
            scrollWhenRequiredIndexExist()
//        }
    }
    
    override func draw(_ rect: CGRect) {
        scrollWhenRequiredIndexExist()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        (self.collectionViewLayout is CenteredSquareTypeCollectionViewFlowlayout) ? () : (self.collectionViewLayout = CenteredSquareTypeCollectionViewFlowlayout())
        self.delegate = self
        self.clipsToBounds = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        (self.collectionViewLayout is CenteredSquareTypeCollectionViewFlowlayout) ? () : (self.collectionViewLayout = CenteredSquareTypeCollectionViewFlowlayout())
        self.delegate = self
        self.clipsToBounds = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        fatalError("init(coder:) has not been implemented")
    }
}

extension TimeCollectionView {
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
//        if trackingFocusingCellAutomatically {
            scrollToTargetIndex(index: focusingIndex, animated: true)
//        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        trackingFocusingCellAutomatically = true
        focusingCollectionViewDelegate?.collectionViewScrollingState?(self, scrolling: true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        if trackingFocusingCellAutomatically {
            scrollToTargetIndex(index: focusingIndex, animated: true)
//        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        checkWillFocusedCell(collectionView: self)
        (is3DPresentingCell) ? updateTransform() : ()
//        if trackingFocusingCellAutomatically {
//            let translation = scrollView.panGestureRecognizer.translation(in: self)
//            if let _ = self.flowLayout as? CenteredSquareTypeCollectionViewFlowlayout {
//                checkWillFocusedCell(scrollView, direction: translation.x)
//            }
//        }
    }
    
    //MARK: 3D presenting part
    func updateTransform() {
        if let layout = self.collectionViewLayout as? CenteredSquareTypeCollectionViewFlowlayout {
            for cell in self.visibleCells {
                if let _cellFrame = self.attributeFrameOfCell(cell: cell) {
                    if let transform = animateCell(cellFrame: _cellFrame, contentOffSet: self.contentOffset.x.absValue + layout.leftOverMargin) {
                        cell.layer.transform = transform
                    }
                }
                
            }
        }
    }
    
    fileprivate func animateCell(cellFrame: CGRect, contentOffSet: CGFloat) -> CATransform3D? {
        let angleFromX = Double(((cellFrame.origin.x - contentOffSet)) / 5)
        var angleFactor : Double {
            if angleFromX.absValue < 3 {
                return 0
            } else {
                return angleFromX
            }
        }
        let angle = CGFloat((angleFactor * Double.pi) / 180.0)
        var transform = CATransform3DIdentity
        transform.m34 = -1.0/1000
        let rotation = CATransform3DRotate(transform, angle, 0, 1, 0)
        
        let factor = (cellFrame.origin.x - contentOffSet)/cellFrame.width * 100
        
        if angleFromX < 0 {
            var scaleFromX = (1000 + (factor)*2) / 1000
            let scaleMax: CGFloat = 1.0
            let scaleMin: CGFloat = 0.6
            if scaleFromX > scaleMax {
                scaleFromX = scaleMax
            }
            if scaleFromX < scaleMin {
                scaleFromX = scaleMin
            }
            let scale = CATransform3DScale(CATransform3DIdentity, scaleFromX, scaleFromX, 1)
            return CATransform3DConcat(rotation, scale)
        } else {
            var scaleFromX = (1000 - (factor)*2) / 1000
            let scaleMax: CGFloat = 1.0
            let scaleMin: CGFloat = 0.6
            if scaleFromX > scaleMax {
                scaleFromX = scaleMax
            }
            if scaleFromX < scaleMin {
                scaleFromX = scaleMin
            }
            let scale = CATransform3DScale(CATransform3DIdentity, scaleFromX, scaleFromX, 1)
            return CATransform3DConcat(rotation, scale)
        }
    }
    //end
    
    //MARK: update focuing index part
    var focusingArea: CGRect {
        var _width = bounds.width * 0.8
        if let layout = self.collectionViewLayout as? CenteredSquareTypeCollectionViewFlowlayout {
            if layout.isHorizontal {
                _width = layout.estimateCellSize.width
                let _height = bounds.height
                let size = CGSize(width: _width, height: _height)
                let originX = contentOffset.x + layout.leftOverMargin
                let originY = (bounds.origin.y)
                let origin = CGPoint(x: originX, y: originY)
                return CGRect(origin: origin, size: size)
            } else {
                _width = layout.estimateCellSize.width
                let _height = layout.estimateCellSize.height
                let size = CGSize(width: _width, height: _height)
                let originX = (bounds.origin.x)
                let originY = ((bounds.height) - _height)/2 + bounds.origin.y
                let origin = CGPoint(x: originX, y: originY)
                return CGRect(origin: origin, size: size)
            }
        } else {
            let _height = bounds.height
            let size = CGSize(width: _width, height: _height)
            let originX = ((bounds.width) - _width)/2 + bounds.origin.x
            let originY = (bounds.origin.y)
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        }
    }
    
    func checkFrameIsInFocusingArea(_ frame: CGRect?) -> Bool {
        if let targetFrame = frame {
//            print("focusingFrame : \(focusingArea)")
//            print("targetcellframe : \(targetFrame)")
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
                            if (focusingIndex != index) && focusingIndex!.item > index.item {
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
                            if (focusingIndex != index) && focusingIndex!.item < index.item {
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
    //end
    
    
    func scrollToTargetIndex(index : IndexPath?, animated: Bool, completion: (()->Void)? = nil) {
        guard let _index = index else {return}
        focusingCollectionViewDelegate?.collectionViewScrollingState?(self, scrolling: true)
        if let layOut = self.flowLayout as? CenteredSquareTypeCollectionViewFlowlayout {
            let scrollView = self as UIScrollView
            scrollView.setContentOffset(layOut.postionOfCellForIndexpath(_index), animated: animated)
            completion?()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("centered collectionview \(indexPath) cell selected")
        //trackingFocusingCellAutomatically = true
        guard let cell = collectionView.cellForItem(at: indexPath) else
        { return }
        
        if let focusedCellIndex = focusingIndex {
            if focusedCellIndex == indexPath {
                focusingCollectionViewDelegate?.collectionViewDidSelectFocusedIndex?(self, focusedIndex: indexPath, cell: cell)
            } else {
                focusingIndex = indexPath
                scrollToTargetIndex(index: indexPath, animated: true)
            }
        } else {
            focusingIndex = indexPath
            scrollToTargetIndex(index: indexPath, animated: true)
        }
    }
    
}

//fileprivate func checkWillFocusedCell(_ scrollView: UIScrollView, direction: CGFloat) {
//    if let layout = self.flowLayout as? CenteredSquareTypeCollectionViewFlowlayout {
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
//                    return (scrollView.contentOffset.y) + (layout.draggingOffSet - layout.cellDraggingOffSet)
//                } else if direction < 0 {
//                    return ((scrollView.contentOffset.y) + (layout.draggingOffSet + layout.cellDraggingOffSet))
//                } else {
//                    return (scrollView.contentOffset.y) + (layout.draggingOffSet)
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

//private func checkNowFocusedCell() {
//    let scrollView = self as UIScrollView
//    guard let layout = self.flowLayout as? CenteredSquareTypeCollectionViewFlowlayout else {
//        focusingIndex = nil
//        return
//    }
//
//    var fixedPosition : CGFloat {
//        if layout.isHorizontal {
//            return self.bounds.height/2
//        } else {
//            return self.bounds.width/2
//        }
//    }
//
//    var mutablePosition : CGFloat {
//        if layout.isHorizontal {
//            return scrollView.contentOffset.x + layout.draggingOffSet
//        } else {
//            return scrollView.contentOffset.y + layout.draggingOffSet
//        }
//    }
//
//    if layout.isHorizontal {
//        guard let item = indexPathForItem(at: CGPoint(x: mutablePosition, y: fixedPosition))
//            else {
//                focusingIndex = nil
//                return
//        }
//
//        focusingIndex = item
//    } else {
//        guard let item = indexPathForItem(at: CGPoint(x: fixedPosition, y: mutablePosition))
//            else {
//                focusingIndex = nil
//                return
//        }
//
//        focusingIndex = item
//    }
//}
