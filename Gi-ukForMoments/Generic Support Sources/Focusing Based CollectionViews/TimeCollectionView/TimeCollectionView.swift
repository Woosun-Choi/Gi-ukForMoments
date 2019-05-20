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
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.collectionViewLayout = CenteredSquareTypeCollectionViewFlowlayout()
        self.delegate = self
        self.clipsToBounds = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.collectionViewLayout = CenteredSquareTypeCollectionViewFlowlayout()
        self.delegate = self
        self.clipsToBounds = true
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        fatalError("init(coder:) has not been implemented")
    }
    
    override var dataSource: UICollectionViewDataSource? {
        didSet {
            //setOriginState()
        }
    }
    
    var requiredItemIndex: IndexPath?
    
    private var maxIndex: IndexPath {
        let max = self.numberOfItems(inSection: 0)
        return IndexPath(item: max - 1, section: 0)
    }
    
    var trackingFocusingCellAutomatically: Bool = false {
        didSet {
            print("trackingFocusingCellAutomatically setted - \(self.trackingFocusingCellAutomatically)")
        }
    }
    
    private var flowLayout: UICollectionViewLayout {
        return self.collectionViewLayout
    }
    
    override var frame: CGRect {
        didSet {
            //if frame size changed. relayout with now focused cell get centered.
            if frame.size != oldValue.size {
                trackingFocusingCellAutomatically = false
                if requiredItemIndex == nil {
                    requiredItemIndex = focusingIndex
//                    scrollWhenRequiredIndexExist()
                }
            }
        }
    }
    
    private func setOriginState() {
        print("timeView  - setOriginStateCalled")
        self.requiredItemIndex = maxIndex
    }
    
    func setStartState(with index: IndexPath, completion:(()->Void)? = nil) {
        self.trackingFocusingCellAutomatically = false
        self.requiredItemIndex = index
        self.reloadData()
        //self.trackingFocusingCellAutomatically = true
        completion?()
    }
    
    private func scrollWhenRequiredIndexExist() {
        if requiredItemIndex != nil {
            print("timeView  - scrollWhenRequiredIndexExist get called")
            scrollToTargetIndex(index: requiredItemIndex, animated: false)
            focusingIndex = requiredItemIndex
            requiredItemIndex = nil
        } else {
            checkNowFocusedCell()
        }
    }
    
    override func reloadData() {
        super.reloadData()
        scrollWhenRequiredIndexExist()
    }
    
    override func layoutSubviews() {
        print("timeView - layoutSubviews get called")
        super.layoutSubviews()
        if trackingFocusingCellAutomatically == false {
            scrollWhenRequiredIndexExist()
        }
    }
    
    override func draw(_ rect: CGRect) {
        print("timeView - draw get called")
        scrollWhenRequiredIndexExist()
    }
}

extension TimeCollectionView {
    
    private func checkNowFocusedCell() {
        let scrollView = self as UIScrollView
        guard let layout = self.flowLayout as? CenteredSquareTypeCollectionViewFlowlayout else {
            focusingIndex = nil
            return
        }
        
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
        
        if layout.isHorizontal {
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
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if trackingFocusingCellAutomatically {
            scrollToTargetIndex(index: focusingIndex, animated: true)
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if trackingFocusingCellAutomatically {
            let translation = scrollView.panGestureRecognizer.translation(in: self)
            if let _ = self.flowLayout as? CenteredSquareTypeCollectionViewFlowlayout {
                checkWillFocusedCell(scrollView, direction: translation.x)
            }
        }
    }
    
    fileprivate func checkWillFocusedCell(_ scrollView: UIScrollView, direction: CGFloat) {
        if let layout = self.flowLayout as? CenteredSquareTypeCollectionViewFlowlayout {
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
                        return (scrollView.contentOffset.y) + (layout.draggingOffSet - layout.cellDraggingOffSet)
                    } else if direction < 0 {
                        return ((scrollView.contentOffset.y) + (layout.draggingOffSet + layout.cellDraggingOffSet))
                    } else {
                        return (scrollView.contentOffset.y) + (layout.draggingOffSet)
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
    
    func scrollToTargetIndex(index : IndexPath?, animated: Bool, completion: (()->Void)? = nil) {
        guard let _index = index else {return}
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
            if indexPath == focusedCellIndex {
                focusingCollectionViewDelegate?.collectionViewDidSelectFocusedIndex?(self, focusedIndex: indexPath, cell: cell)
            } else {
                scrollToTargetIndex(index: indexPath, animated: true) {
                    self.checkNowFocusedCell()
                }
            }
        } else if focusingIndex == nil && indexPath.item > 0 {
            scrollToTargetIndex(index: indexPath, animated: true) {
                self.checkNowFocusedCell()
            }
        }
    }
    
}
