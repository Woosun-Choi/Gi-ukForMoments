//
//  HashTagView.swift
//  infinitePageViewTest
//
//  Created by goya on 2018. 9. 7..
//  Copyright © 2018년 goya. All rights reserved.
//

import UIKit

@objc protocol HashTagDelegate: class {
    @objc optional func hashTagItem(_ tagItemView: HashTagItem, selectedTag tag: String)
    @objc optional func hashTagItem(_ tagItemView: HashTagItem, longPressed tag: String)
}

class HashTagItem: UIView {
    
    var fontSize: CGFloat = 12 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var printOutFrameInformation: Bool = false
    
    var cornerRadiusRatio: CGFloat {
        get {
            return generalSettings.cornerRadiusRatio
        } set {
            if newValue > 100 {
                generalSettings.cornerRadiusRatio = 1
            } else if newValue < 0 {
                generalSettings.cornerRadiusRatio = 0
            } else {
                generalSettings.cornerRadiusRatio = newValue/100
            }
            setNeedsDisplay()
        }
    }
    
    weak var delegate : HashTagDelegate?
    
    weak var tagLabel: UILabel!
    
    private var widthLimit : CGFloat?
    
    private var itemMinHeight: CGFloat?
    
    private var itemMinSize: CGSize?
    
    private(set) var tagString : String?
    
    var contentColor = UIColor.goyaFontColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private func setTagLabel() {
        if tagLabel == nil {
            let newLable = UILabel()
            newLable.textColor = generalSettings.textColor
            newLable.numberOfLines = 1
            tagLabel = newLable
            addSubview(tagLabel)
        }
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        let font = UIFont.appleSDGothicNeo.semiBold.font(size: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle,.font: font])
    }
    
    private func setTagItem(withHashMark: Bool = false) {
        
        guard let tag = tagString else { return }
        var targetTag = tag
        if withHashMark {
            targetTag = "# " + tag
        }
        let targetString = centeredAttributedString(targetTag, fontSize: fontSize)
        let targetSize = targetString.size()
        
        var width: CGFloat {
            let expectedSize = targetSize.width
            if let limit = widthLimit, limit > 0 {
                let actualLimit = limit - (generalSettings.leftAndRightMargins * 2)
                if expectedSize >= actualLimit {
                    if printOutFrameInformation {
                        print("limit = \(limit), actualLimit = \(actualLimit)")
                    }
                    return actualLimit
                } else {
                    if printOutFrameInformation {
                        print("limit = \(limit), expextedsize = \(expectedSize)")
                    }
                    return expectedSize
                }
            } else {
                if printOutFrameInformation {
                    print("limit = nil, expextedsize = \(expectedSize)")
                }
                return expectedSize
            }
        }
        
        let height = targetSize.height
        
        let itemSize = CGSize(width: width, height: height)
        
        var newFrameWidth = itemSize.width + (generalSettings.leftAndRightMargins * 2)
        var newFrameHeight = itemSize.height + (generalSettings.topAndBottomMargins * 2)
        
        if let requieredHeight = itemMinHeight, requieredHeight > newFrameHeight {
            newFrameHeight = requieredHeight
        }
        
        if let requieredSize = itemMinSize {
            if newFrameHeight < requieredSize.height {
                newFrameHeight = requieredSize.height
            }
            if newFrameWidth < requieredSize.width {
                newFrameWidth = requieredSize.width
            }
        }
        
        let newFrameSize = CGSize(width: newFrameWidth, height: newFrameHeight)
        
        frame.size = newFrameSize
//        frame = CGRect(origin: self.frame.origin, size: newFrameSize)
        
        let originX = (newFrameWidth - itemSize.width)/2
        let originY = (newFrameHeight - itemSize.height)/2
        let origin = CGPoint(x: originX, y: originY)
        
        tagLabel.frame = CGRect(origin: origin, size: itemSize)
        tagLabel.attributedText = targetString
    }
    
    private func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureActivated(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    private func addPressGesture() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureActivated(_:)))
        addGestureRecognizer(gesture)
    }
    
    @objc private func longPressGestureActivated(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let tag = tagString {
                delegate?.hashTagItem?(self, longPressed: tag)
            }
        default:
            break
        }
    }
    
    @objc private func tapGestureActivated(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .ended:
            if let tag = tagString {
                delegate?.hashTagItem?(self ,selectedTag: tag)
            }
        default:
            break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setTagItem()
    }
    
    override func draw(_ rect: CGRect) {
        var path = UIBezierPath(rect: bounds)
        path = UIBezierPath(roundedRect: bounds, cornerRadius: fixedCornerRadius)
        path.addClip()
        contentColor.setFill()
        path.fill()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .redraw
        backgroundColor = UIColor.clear
        isOpaque = false
        addGesture()
        addPressGesture()
        setTagLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = .redraw
        backgroundColor = UIColor.clear
        isOpaque = false
        addGesture()
        addPressGesture()
        setTagLabel()
    }
}

extension HashTagItem {
    
    var isHorizontal : Bool {
        return (frame.width/frame.height) > 1
    }
    
    var fixedCornerRadius: CGFloat {
        return bounds.height * generalSettings.cornerRadiusRatio
    }
    
    var flexibleCornerRadius: CGFloat {
        if isHorizontal {
            return bounds.height * generalSettings.cornerRadiusRatio
        } else {
            return bounds.width * generalSettings.cornerRadiusRatio
        }
    }
    
    var viewSize: CGSize {
        let width = tagLabel.frame.width + (generalSettings.leftAndRightMargins * 2)
        let height = tagLabel.frame.height + (generalSettings.topAndBottomMargins * 2)
        return CGSize(width: width, height: height)
    }
    
    fileprivate struct generalSettings {
        static var fontSize : CGFloat = 12
        static var textColor = UIColor.goyaWhite
        static var textBackground = UIColor.GiukBackgroundColor_depth_1.cgColor
        static var leftAndRightMargins : CGFloat = 8
        static var topAndBottomMargins : CGFloat = 5
        static var cornerRadiusRatio : CGFloat = 1
        static var itemOrigin : CGPoint {
            return CGPoint(x: leftAndRightMargins, y: topAndBottomMargins)
        }
    }
    
    convenience init(limitWidth width: CGFloat, tag: String) {
        self.init()
        widthLimit = width
        tagString = tag
        setTagItem()
    }
    
    convenience init(limitWidth width: CGFloat, tag: String, fontSize: CGFloat) {
        self.init()
        self.widthLimit = width
        self.tagString = tag
        self.fontSize = fontSize
        setTagItem()
    }
    
    convenience init(limitWidth width: CGFloat, tag: String, fontSize: CGFloat, itemMinHeight: CGFloat) {
        self.init()
        self.widthLimit = width
        self.tagString = tag
        self.fontSize = fontSize
        self.itemMinHeight = itemMinHeight
        setTagItem()
    }
    
    convenience init(limitWidth width: CGFloat, tag: String, fontSize: CGFloat, itemMinSize: CGSize) {
        self.init()
        self.widthLimit = width
        self.tagString = tag
        self.fontSize = fontSize
        self.itemMinSize = itemMinSize
        setTagItem()
    }

    convenience init(limitWidth width: CGFloat, tag: String, fontSize: CGFloat = 11, textColor: UIColor = UIColor.white, backgroundColor: CGColor = UIColor.lightGray.cgColor, leftAndRightMargins: CGFloat = 8, topAndBottomMargins: CGFloat = 5, cornerRadiusRatio: CGFloat = 100) {
        self.init()
        widthLimit = width
        tagString = tag
        self.fontSize = fontSize
        generalSettings.textColor = textColor
        generalSettings.textBackground = backgroundColor
        generalSettings.leftAndRightMargins = leftAndRightMargins
        generalSettings.topAndBottomMargins = topAndBottomMargins
        generalSettings.cornerRadiusRatio = cornerRadiusRatio
        setTagItem()
    }
}
