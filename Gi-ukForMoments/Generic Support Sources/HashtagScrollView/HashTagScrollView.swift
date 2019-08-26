//
//  HashTagView_Scroll.swift
//  Gi-ukForMoments
//
//  Created by goya on 25/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol HashTagScrollViewDelegate {
    @objc optional func hashTagScrollView(_ hashTagScrollView: HashTagScrollView, didSelectItemAt item: Int, tag: String)
    @objc optional func hashTagScrollView(_ hashTagScrollView: HashTagScrollView, didLongPressedItemAt item: Int, tag: String)
}

@objc protocol HashTagScrollViewDataSource {
//    @objc func hashTagScrollView_numberOfSection(_ hashTagScrollView: HashTagView_Scroll) -> Int
//    @objc func hashTagScrollView_numberItemsInSection(_ hashTagScrollView: HashTagView_Scroll, section: Int) -> Int
    @objc func hashTagScrollView_tagItems(_ hashTagScrollView: HashTagScrollView) -> [String]?
}

class HashTagScrollView: UIScrollView, HashTagDelegate {
    
    weak var hashTagScrollViewDelegate: HashTagScrollViewDelegate?
    
    weak var dataSource: HashTagScrollViewDataSource? {
        didSet {
            reloadData()
        }
    }
    
    var itemColor: UIColor = .black {
        didSet {
            setNeedsLayout()
        }
    }
    
    var backgroundLayer: CALayer? {
        didSet {
            if self.backgroundLayer != nil {
                layer.sublayers?.forEach {$0.removeFromSuperlayer()}
                layer.addSublayer(backgroundLayer!)
            }
        }
    }
    
    fileprivate struct generalSettings {
        static var verticalEdgeMargin : CGFloat = 16
        static var horizontalEdgeMargin : CGFloat = 12
        static var itemVerticalSpace : CGFloat = 5
        static var itemHorizontalSpace : CGFloat = 5
    }
    
    //MARK: Variables
    private(set) var tags : [String]?
    
    private var widthLimitForPresentingTags : CGFloat?
    
    var widthLimit : CGFloat {
        get {
            if widthLimitForPresentingTags == nil {
                return self.bounds.width - (generalSettings.itemHorizontalSpace * 2)
            } else {
                return widthLimitForPresentingTags!
            }
        }
        set { widthLimitForPresentingTags = newValue }
    }
    
    var tagItemCornerRadius_Percent: CGFloat = 100 {
        didSet {
            reloadData()
        }
    }
    
    var tagItemMinHeight: CGFloat = 35 {
        didSet {
            reloadData()
        }
    }
    
    var itemMinSize: CGSize = CGSize(width: 10, height: 10) {
        didSet {
            reloadData()
        }
    }
    
    var isShadowedItem : Bool = false {
        didSet {
            reloadData()
        }
    }
    //end
    
    //MARK: Computed Variables
    var checkDataIsChanged: Bool {
        return (tags != dataSource?.hashTagScrollView_tagItems(self)) ? (true) : (false)
    }
    
    var numberOfTags: Int {
        return tags?.count ?? 0
    }
    //end
    
    //MARK: tag item delegate
    func hashTagItem(_ tagItemView: HashTagItem, selectedTag tag: String) {
        if let index = subviews.firstIndex(of: tagItemView) {
            hashTagScrollViewDelegate?.hashTagScrollView?(self, didSelectItemAt: index, tag: tag)
        }
    }
    
    func hashTagItem(_ tagItemView: HashTagItem, longPressed tag: String) {
        if let index = subviews.firstIndex(of: tagItemView) {
            hashTagScrollViewDelegate?.hashTagScrollView?(self, didLongPressedItemAt: index, tag: tag)
        }
    }
    //end
    
    //MARK: Public functions
    
    func itemForIndexAt(_ index: Int) -> HashTagItem? {
        if let item = subviews[index] as? HashTagItem {
            return item
        } else {
            return nil
        }
    }
    
    func itemForTagName(_ tagName: String) -> HashTagItem? {
        var result : HashTagItem?
        if let items = subviews as? [HashTagItem] {
            for item in items {
                if item.tagString == tagName {
                    result = item
                }
            }
        }
        return result
    }
    
    func addHashItem(text: String) {
        tags?.append(text)
        let hash = HashTagItem(limitWidth: estimateWidthLimit, tag: text)
        hash.delegate = self
        self.addSubview(hash)
        setNeedsLayout()
    }
    
    func removeHashItem(at index: Int) {
        tags?.remove(at: index)
        subviews[index].removeFromSuperview()
        updateSubviewsLocation_WithAnimation()
    }
    
    func removeHashItem(for tagName: String) {
        guard let currentTags = tags else { return }
        var targetIndex : Int?
        for tag in currentTags {
            if tag == tagName {
                targetIndex = currentTags.firstIndex(of: tagName)
            }
        }
        guard let selectedIndex = targetIndex else { return }
        tags?.remove(at: selectedIndex)
        subviews[selectedIndex].removeFromSuperview()
        updateSubviewsLocation_WithAnimation()
    }
    
    func clearHashItem() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func reloadData(animate: Bool = false, duration: TimeInterval = 0) {
        if animate {
            self.alpha = 0
            if checkDataIsChanged {
                tags = dataSource?.hashTagScrollView_tagItems(self)
                clearHashItem()
                if let _tags = tags {
                    generateTags(_tags)
                }
            }
            UIView.animate(withDuration: duration) {
                self.alpha = 1
            }
        } else {
            if checkDataIsChanged {
                tags = dataSource?.hashTagScrollView_tagItems(self)
                clearHashItem()
                if let _tags = tags {
                    generateTags(_tags)
                }
            }
        }
    }
    
    func setNewInsets(verticalEdgeMargin : CGFloat?, horizontalEdgeMargin : CGFloat?, itemVerticalSpace : CGFloat?, itemHorizontalSpace : CGFloat?) {
        (verticalEdgeMargin != nil) ? (generalSettings.verticalEdgeMargin = verticalEdgeMargin!) : ()
        (horizontalEdgeMargin != nil) ? (generalSettings.horizontalEdgeMargin = horizontalEdgeMargin!) : ()
        (itemVerticalSpace != nil) ? (generalSettings.itemVerticalSpace = itemVerticalSpace!) : ()
        (itemHorizontalSpace != nil) ? (generalSettings.itemHorizontalSpace = itemHorizontalSpace!) : ()
        setNeedsLayout()
    }
    //end
    
    //MARK: Private functions
    private func generateTags(_ tags: [String]) {
        for item in tags {
//            let hash = HashTagItem(limitWidth: estimateWidthLimit, tag: item, fontSize: estimatedFontSizeForTagItem)
//            let hash = HashTagItem(limitWidth: estimateWidthLimit, tag: item, fontSize: estimatedFontSizeForTagItem, itemMinHeight: tagItemMinHeight)
            let hash = HashTagItem(limitWidth: estimateWidthLimit, tag: item, fontSize: estimatedFontSizeForTagItem, itemMinSize: itemMinSize)
            hash.cornerRadiusRatio = tagItemCornerRadius_Percent
            hash.shadowVisible = isShadowedItem
            hash.contentColor = itemColor
            hash.delegate = self
            self.addSubview(hash)
        }
        setNeedsLayout()
    }
    
    private func updateSubviewsLocation_WithAnimation(completion: ((Bool) -> Void)? = nil) {
        var shouldUpdatedItems = [UIView]()
        var newFrameOrigins = [CGPoint]()
        var nowX = generalSettings.horizontalEdgeMargin
        var nowY = generalSettings.verticalEdgeMargin
        
        var nowOffSet : CGPoint {
            return CGPoint(x: nowX, y: nowY)
        }
        
        for subview in self.subviews {
            if round(nowX + subview.frame.width) > round(trailingEdgeLimit) {
                nowY = subview.frame.height + generalSettings.itemVerticalSpace + nowY
                nowX = generalSettings.horizontalEdgeMargin
            }
            if subview.frame.origin != nowOffSet {
                shouldUpdatedItems.append(subview)
                newFrameOrigins.append(nowOffSet)
            }
            nowX += (subview.frame.width + generalSettings.itemHorizontalSpace)
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            for index in shouldUpdatedItems.indices {
                shouldUpdatedItems[index].frame.origin = newFrameOrigins[index]
            }
        }) { (finished) in
            self.setNeedsLayout()
            completion?(finished)
        }
        
        contentSize = newFrame.size
    }
    
    private func updateSubviewsLocation() {
        var nowX = generalSettings.horizontalEdgeMargin
        var nowY = generalSettings.verticalEdgeMargin
        
        var nowOffSet : CGPoint {
            return CGPoint(x: nowX, y: nowY)
        }
        
        for subview in self.subviews {
            subview.setNeedsLayout()
            if round(nowX + subview.frame.width) > round(trailingEdgeLimit) {
                nowY = subview.frame.height + generalSettings.itemVerticalSpace + nowY
                nowX = generalSettings.horizontalEdgeMargin
            }
            subview.frame.origin = nowOffSet
            nowX += (subview.frame.width + generalSettings.itemHorizontalSpace)
        }
        contentSize = newFrame.size
    }
    //end
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.subviews.count > 0 {
            updateSubviewsLocation()
        }
    }
    
    override func draw(_ rect: CGRect) {
        reloadData()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceVertical = true
        clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceVertical = true
        clipsToBounds = true
    }
}

extension HashTagScrollView {
    //MARK: Grid informations
    private var estimateWidthLimit : CGFloat {
        return widthLimit - (generalSettings.horizontalEdgeMargin*2)
    }
    
    private var trailingEdgeLimit: CGFloat {
        return estimateWidthLimit + generalSettings.horizontalEdgeMargin
    }
    
    private var newViewSize: CGSize {
        return CGSize(width: frame.width, height: estimateHeight)
    }
    
    private var newFrame: CGRect {
        return CGRect(origin: frame.origin, size: newViewSize)
    }
    
    private var estimateHeight : CGFloat {
        return (subviews.last?.frame.maxY ?? 0) + generalSettings.verticalEdgeMargin
    }
    
    var estimatedFontSizeForTagItem: CGFloat {
        let size = valueBetweenMinAndMax(maxValue: 14, minValue: 12, mutableValue: bounds.height / 10)
        return size
    }
    //end
}
