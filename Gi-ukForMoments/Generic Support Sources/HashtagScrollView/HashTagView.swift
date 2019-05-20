//
//  HashTagView.swift
//  infinitePageViewTest
//
//  Created by goya on 2018. 9. 9..
//  Copyright © 2018년 goya. All rights reserved.
//

import UIKit

class HashTagView: UIView {
    
    private var targetWidth : CGFloat?
    
    var tags : ([String], HashTagItemView.requestedHashTagManagement)? {
        didSet {
            clearHashItem()
            if let _tags = tags {
                generateTags(_tags.0, type: _tags.1)
            }
        }
    }
    
    var areaWidth : CGFloat? {
        get {
            if targetWidth == nil {
                return self.frame.width
            } else {
                return targetWidth
            }
        }
        set { targetWidth = newValue } //targetView.bounds.width
    }
    
    fileprivate struct generalSettings {
        static var verticalEdgeMargin : CGFloat = 8
        static var horizontalEdgeMargin : CGFloat = 8
        static var itemVerticalSpace : CGFloat = 4
        static var itemHorizontalSpace : CGFloat = 4
    }
    
    private var estimateHeight : CGFloat = 0
    
    private var nowX : CGFloat = generalSettings.horizontalEdgeMargin
    private var nowY : CGFloat = generalSettings.verticalEdgeMargin
    
    var nowOffSet : CGPoint {
        return CGPoint(x: nowX, y: nowY)
    }
    
    func clearHashItem() {
        nowX = generalSettings.horizontalEdgeMargin
        nowY = generalSettings.verticalEdgeMargin
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    private var widthLimit : CGFloat {
        return areaWidth! - (generalSettings.horizontalEdgeMargin*2)
    }
    
    private var trailingEdgeLimit: CGFloat {
        return widthLimit + generalSettings.horizontalEdgeMargin
    }
    
    private var newViewSize: CGSize {
        return CGSize(width: frame.width, height: estimateHeight)
    }
    
    private var newFrame: CGRect {
        return CGRect(origin: frame.origin, size: newViewSize)
    }
    
    func generateTags(_ tags: [String], type: HashTagItemView.requestedHashTagManagement = .fetch) {
        clearHashItem()
        for item in tags {
            let hash = HashTagItemView(limitWidth: widthLimit, tag: item, touchType: type)
            self.addSubview(hash)
        }
        setNeedsLayout()
    }
    
    func addHashItem(text: String, touchType type: HashTagItemView.requestedHashTagManagement = .fetch) {
        let hash = HashTagItemView(limitWidth: widthLimit, tag: text, touchType: type)
        self.addSubview(hash)
        setNeedsLayout()
    }
    
    func removewHashItem(text: String) {
        for subview in subviews {
            if let singleView = subview as? HashTagItemView {
                if singleView.tagString == text {
                    singleView.removeFromSuperview()
                }
            }
        }
        updateSubviewsLocation_WithAnimation()
    }
    
    private func updateSubviewsLocation_WithAnimation() {
        var shouldUpdatedItems = [UIView]()
        var newFrameOrigins = [CGPoint]()
        nowX = generalSettings.horizontalEdgeMargin
        nowY = generalSettings.verticalEdgeMargin
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
            estimateHeight = nowY + subview.frame.height + generalSettings.verticalEdgeMargin
        }
        
        UIView.animate(withDuration: 0.25) {
            for index in shouldUpdatedItems.indices {
                shouldUpdatedItems[index].frame.origin = newFrameOrigins[index]
            }
        }
        
        frame = newFrame
    }
    
    private func updateSubviewsLocation() {
        nowX = generalSettings.horizontalEdgeMargin
        nowY = generalSettings.verticalEdgeMargin
        for subview in self.subviews {
            if round(nowX + subview.frame.width) > round(trailingEdgeLimit) {
                nowY = subview.frame.height + generalSettings.itemVerticalSpace + nowY
                nowX = generalSettings.horizontalEdgeMargin
            }
            subview.frame.origin = nowOffSet
            nowX += (subview.frame.width + generalSettings.itemHorizontalSpace)
            estimateHeight = nowY + subview.frame.height + generalSettings.verticalEdgeMargin
        }
        frame = newFrame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.subviews.count > 0 {
            updateSubviewsLocation()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(rect: CGRect(origin: self.frame.origin, size: bounds.size))
        path.addClip()
        UIColor.clear.setFill()
        path.fill()
    }
}

extension HashTagView {
    convenience init(areaWidth: CGFloat, verticalEdgeMargin: CGFloat, horizontalEdgeMargin: CGFloat, itemVerticalMargin: CGFloat, itemHorizontalMargin: CGFloat) {
        self.init()
        self.areaWidth = areaWidth
        generalSettings.verticalEdgeMargin = verticalEdgeMargin
        generalSettings.horizontalEdgeMargin = horizontalEdgeMargin
        generalSettings.itemVerticalSpace = itemVerticalMargin
        generalSettings.itemHorizontalSpace = itemHorizontalMargin
    }
}
