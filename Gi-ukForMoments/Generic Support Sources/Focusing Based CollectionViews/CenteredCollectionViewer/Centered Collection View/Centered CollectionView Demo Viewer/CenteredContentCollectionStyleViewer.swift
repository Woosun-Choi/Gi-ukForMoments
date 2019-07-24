//
//  CenteredContentCollectionStyleView.swift
//  linearCollectionViewTest
//
//  Created by goya on 24/03/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class CenteredContentCollectionStyleViewer: UIView, DotStylePresentorViewDatasource, FocusingIndexBasedCollectionViewDelegate {
    
    var nowIndex: Int = 0 {
        didSet {
            if nowIndex != oldValue {
                dotPresentor.updateDotIndexWith(indexItem: nowIndex)
                requestedFunctionWhenIndexChanges?()
            }
        }
    }
    
    var requestedFunctionWhenIndexChanges: (() -> Void)?
    
    var dotPresentorHeight: CGFloat?
    
    var estimateCellSize: CGSize?
    
    @IBInspectable var dotPresentorDotColor: UIColor?
    
    @IBInspectable var preferredDotSizeForDotPresentorView: CGFloat = 15
    
    @IBInspectable var isHorizontal: Bool = true
    
    @IBInspectable var isFullScreen: Bool = true
    
    @IBInspectable var contentMinimumMargin: CGFloat = 3
    
    @IBInspectable var requestedNibFileNameForCollectionView: String = ColorCollectionViewCell.reuseIdentifier
    
    private weak var dataSource: UICollectionViewDataSource? {
        didSet {
            centeredCollectionView.dataSource = dataSource
        }
    }
    
    var dotPredentorAnimatedLayoutChangeAllowed = false {
        didSet {
            dotPresentor?.dotAnimationAllowed = dotPredentorAnimatedLayoutChangeAllowed
        }
    }
    
    var dotPresentorIsHidden: Bool = false {
        didSet {
            dotPresentor?.isHidden = dotPresentorIsHidden
        }
    }
    
    lazy var centeredCollectionView: CenteredCollectionView! = {
        let collectionView = CenteredCollectionView.init(frame: fullView, isHorizontal: self.isHorizontal, isFullscreen: self.isFullScreen, contentMinimumMargin: self.contentMinimumMargin)
        collectionView.focusingCollectionViewDelegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(UINib(nibName: requestedNibFileNameForCollectionView, bundle: nil), forCellWithReuseIdentifier: requestedNibFileNameForCollectionView)
        self.addSubview(collectionView)
        return collectionView
    }()
    
    lazy var dotPresentor: DotStylePresentorView! = {
        let presentor = DotStylePresentorView()
        presentor.isUserInteractionEnabled = false
        presentor.datasource = self
        presentor.frame = bottomView
        if dotPresentorDotColor != nil {
            presentor.requestDotColorChangeWith(color: dotPresentorDotColor!)
        }
        presentor.dotSize = preferredDotSizeForDotPresentorView
        presentor.isHidden = dotPresentorIsHidden
        self.addSubview(presentor)
        return presentor
    }()
    
    private func reLayoutDotPresentor() {
        dotPresentor.frame = bottomView
        dotPresentor.dotSize = preferredDotSizeForDotPresentorView
        dotPresentor.isHidden = dotPresentorIsHidden
        dotPresentor.reloadData()
    }
    
    private func reLayoutCollectionView() {
        centeredCollectionView.frame = fullView
    }
    
    func numberOfItemsForDotPresentor() -> Int {
        return centeredCollectionView.numberOfItems(inSection: 0)
    }
    
    func collectionViewDidUpdateFocusingIndex(_ collectionView: UICollectionView, with: IndexPath) {
        nowIndex = with.item
    }
    
    func collectionViewDidEndScrollToIndex(_ collectionView: UICollectionView, finished: Bool) {
//        dotPresentor.updateDotIndexWith(indexItem: nowIndex)
//        requestedFunctionWhenIndexChanges?()
    }
    
    func setDataSource(source: UICollectionViewDataSource) {
        dataSource = source
        centeredCollectionView.reloadData()
    }
    
    func resignDataSource() {
        dataSource = nil
        centeredCollectionView.reloadData()
    }
    
    
    func reloadData() {
        centeredCollectionView?.reloadData()
        dotPresentor.reloadData()
    }
    
    func prepareForStoredIndexItem(with indexItem: Int) {
        if centeredCollectionView == nil {
            print("centerdCollectionView not setted")
        }
        centeredCollectionView.requiredItemIndex = IndexPath(item: indexItem, section: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reLayoutDotPresentor()
        reLayoutCollectionView()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        reLayoutDotPresentor()
        reLayoutCollectionView()
    }
}

extension CenteredContentCollectionStyleViewer {
    
    fileprivate var fullView: CGRect {
        let expectedWidth = self.frame.width
        let expectedHeigth = self.frame.height
        let requiredOriginX: CGFloat = 0
        let requiredOriginY: CGFloat = 0
        let origin = CGPoint(x: requiredOriginX, y: requiredOriginY)
        let size = CGSize(width: expectedWidth, height: expectedHeigth)
        return CGRect(origin: origin, size: size)
    }
    
    fileprivate var bottomView: CGRect {
        let exepctedWidth = self.frame.width
        let expectedHeigth = dotPresentorHeight ?? self.frame.height * 0.1
        let requiredOriginX: CGFloat = 0
        let requiredOriginY = self.frame.height - expectedHeigth - contentMinimumMargin
        return CGRect(origin: CGPoint(x: requiredOriginX, y: requiredOriginY), size: CGSize(width: exepctedWidth, height: expectedHeigth))
    }
    
}


//    var dotPresentor: DotStylePresentorView!
//
//    var centeredCollectionView: CenteredCollectionView!


//func generageCenteredCollectionView() {
//    if centeredCollectionView == nil {
//        let layout = CenteredCollectionViewFlowLayout()
//        let collectionView = CenteredCollectionView.init(frame: fullView, collectionViewLayout: layout)
//        //            collectionView.displayType_isHorizontal = isHorizontal
//        //            collectionView.displayType_isFullscreen = isFullScreen
//        collectionView.contentMinimumMargin = contentMinimumMargin
//        collectionView.updateIndexDelegate = self
//        collectionView.register(UINib(nibName: requestedNibFileNameForCollectionView, bundle: nil), forCellWithReuseIdentifier: requestedNibFileNameForCollectionView)
//        self.addSubview(collectionView)
//        centeredCollectionView = collectionView
//    } else {
//        return
//    }
//}
//
//func generateDotPresentor() {
//    if dotPresentor == nil {
//        let presentor = DotStylePresentorView()
//        presentor.isUserInteractionEnabled = false
//        presentor.datasource = self
//        presentor.frame = bottomView
//        if dotPresentorDotColor != nil {
//            presentor.requestDotColorChangeWith(color: dotPresentorDotColor!)
//        }
//        presentor.dotSize = preferredDotSizeForDotPresentorView
//        presentor.isHidden = dotPresentorIsHidden
//        self.addSubview(presentor)
//        dotPresentor = presentor
//    } else {
//        return
//    }
//}
