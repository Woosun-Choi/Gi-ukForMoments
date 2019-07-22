//
//  FocusingBasedCollectionview.swift
//  CenteredCollectionViewTest
//
//  Created by goya on 23/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

/*
 Focusing based collection view - Protocol and Providing inheritence
 
 Using : Inherite FocusingIndexBaseCollectionView instead UICollectionView
 */
@objc protocol FocusingIndexBasedCollectionViewDelegate: class {
    @objc optional func collectionViewDidUpdateFocusingIndex(_ collectionView: UICollectionView, with indexPath: IndexPath)
    @objc optional func collectionViewDidEndScrollToIndex(_ collectionView: UICollectionView, finished: Bool)
    @objc optional func collectionViewDidSelectFocusedIndex(_ collectionView: UICollectionView, focusedIndex: IndexPath, cell: UICollectionViewCell)
    @objc optional func collectionViewScrollingState(_ collectionView: UICollectionView, scrolling: Bool)
}

class FocusingIndexBasedCollectionView: UICollectionView, UICollectionViewDelegate {
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        delegate = self
    }
    
    weak var focusingCollectionViewDelegate: FocusingIndexBasedCollectionViewDelegate?
    
    var focusingIndex : IndexPath? {
        didSet {
            if let index = focusingIndex {
                focusingCollectionViewDelegate?.collectionViewDidUpdateFocusingIndex?(self, with: index)
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        print("focusedCell end decelerating")
        focusingCollectionViewDelegate?.collectionViewDidEndScrollToIndex?(self, finished: true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
//        print("focusedCell end scrolling animation")
        focusingCollectionViewDelegate?.collectionViewDidEndScrollToIndex?(self, finished: true)
    }
}
