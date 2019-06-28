//
//  HashTagView.swift
//  infinitePageViewTest
//
//  Created by goya on 2018. 9. 7..
//  Copyright © 2018년 goya. All rights reserved.
//

import UIKit

protocol HashTagDelegate : class {
//    func requestHashTagAction(_ tag: String, editType type: HashTagItemView.requestedHashTagManagement)
    func hashTagItem(_ tagItemView: HashTagItem, selectedTag tag: String)
}

class HashTagItem: UIView {
    
    weak var delegate : HashTagDelegate?
    
    weak var tagLabel: UILabel!
    
    private var widthLimit : CGFloat?
    
    private(set) var tagString : String?
    
    var contentColor = UIColor.lightGray {
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
    
    private func createTagItem() {
        
        guard let tag = tagString else { return }
        let targetTag = "# " + tag
        let targetString = centeredAttributedString(targetTag, fontSize: generalSettings.fontSize)
        let targetSize = targetString.size()
        
        var width: CGFloat {
            let expectedSize = targetSize.width
            if let limit = widthLimit {
                let actualLimit = limit - (generalSettings.leftAndRightMargins * 2)
                if expectedSize >= actualLimit {
                    return actualLimit
                } else {
                    return expectedSize
                }
            } else {
                return expectedSize
            }
        }
        
        let height = targetSize.height
        
        let itemSize = CGSize(width: width, height: height)
        
        let newFrameWidth = itemSize.width + (generalSettings.leftAndRightMargins * 2)
        let newFrameHeight = itemSize.height + (generalSettings.topAndBottomMargins * 2)
        let newFrameSize = CGSize(width: newFrameWidth, height: newFrameHeight)
        frame = CGRect(origin: self.frame.origin, size: newFrameSize)
        
        tagLabel.frame = CGRect(origin: generalSettings.itemOrigin, size: itemSize)
        tagLabel.attributedText = targetString
    }
    
    private func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(returnTagString(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    @objc private func returnTagString(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .ended:
            if let tag = tagString {
                delegate?.hashTagItem(self ,selectedTag: tag)
            }
        default:
            break
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height * generalSettings.cornerRadiusRatio)
        path.addClip()
        contentColor.setFill()
        path.fill()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        isOpaque = false
        addGesture()
        setTagLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        isOpaque = false
        addGesture()
        setTagLabel()
    }
}

extension HashTagItem {
    
    var viewSize: CGSize {
        let width = tagLabel.frame.width + (generalSettings.leftAndRightMargins * 2)
        let height = tagLabel.frame.height + (generalSettings.topAndBottomMargins * 2)
        return CGSize(width: width, height: height)
    }
    
    fileprivate struct generalSettings {
        static var fontSize : CGFloat = 12
        static var textColor = UIColor.white
        static var textBackground = UIColor.lightGray.cgColor
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
        createTagItem()
    }

    convenience init(limitWidth width: CGFloat, tag: String, fontSize: CGFloat = 11, textColor: UIColor = UIColor.white, backgroundColor: CGColor = UIColor.lightGray.cgColor, leftAndRightMargins: CGFloat = 8, topAndBottomMargins: CGFloat = 5, cornerRadiusRatio: CGFloat = 100) {
        self.init()
        widthLimit = width
        tagString = tag
        generalSettings.fontSize = fontSize
        generalSettings.textColor = textColor
        generalSettings.textBackground = backgroundColor
        generalSettings.leftAndRightMargins = leftAndRightMargins
        generalSettings.topAndBottomMargins = topAndBottomMargins
        generalSettings.cornerRadiusRatio = cornerRadiusRatio
        createTagItem()
    }
}
