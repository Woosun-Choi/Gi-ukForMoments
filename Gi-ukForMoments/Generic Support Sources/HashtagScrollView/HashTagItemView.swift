//
//  HashTagView.swift
//  infinitePageViewTest
//
//  Created by goya on 2018. 9. 7..
//  Copyright © 2018년 goya. All rights reserved.
//

import UIKit

protocol HashTagDelegate : class {
    func requestHashTagAction(_ tag: String, editType type: HashTagItemView.requestedHashTagManagement)
}

class HashTagItemView: UIView {
    
    enum requestedHashTagManagement {
        case delete
        case removeFromNote
        case fetch
        case addToSavingContent
        case removeFromSavingContent
    }
    
    var contentColor = UIColor.lightGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    static weak var delegate : HashTagDelegate?
    
    private var widthLimit : CGFloat?
    
    private(set) var tagString : String?
    
    private var _touchType : requestedHashTagManagement!
    
    private func addGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(returnTagString(_:)))
        self.addGestureRecognizer(gesture)
    }
    
    @objc private func returnTagString(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .ended:
            if let tag = tagString {
                HashTagItemView.delegate?.requestHashTagAction(tag, editType: _touchType)
            }
        default:
            break
        }
    }
    
    private func centeredAttributedString(_ string: String, fontSize: CGFloat) -> NSAttributedString {
        let font = UIFont.appleSDGothicNeo.semiBold.font(size: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        return NSAttributedString(string: string, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle,.font: font])
    }
    
    private lazy var _tagItem : UILabel = {
        let label = UILabel()
        label.textColor = generalSettings.textColor
        addSubview(label)
        return label
    }()
    
    private func createTagItem() {
        
        guard let tag = tagString else { return }
        let targetTag = "# " + tag
        let targetString = centeredAttributedString(targetTag, fontSize: generalSettings.fontSize)
        let targetSize = targetString.size()
        
//        let tagItemString = NSString(string: "# " + tag)
//        let size = tagItemString.size(withAttributes: [NSAttributedString.Key.font : tagItem.font])
        
        var width: CGFloat {
            guard let limit = widthLimit else { return 0 }
            let expectedSize = targetSize.width
            let actualLimit = limit - (generalSettings.leftAndRightMargins * 2)
            if expectedSize >= actualLimit {
                return actualLimit
            } else {
                return expectedSize
            }
        }
        let height = targetSize.height
        
        let itemSize = CGSize(width: width, height: height)
        
        _tagItem.attributedText = targetString
//        tagItem.text = tagItemString as String
        _tagItem.frame = CGRect(origin: generalSettings.itemOrigin, size: itemSize)
        
        
        let newFrameWidth = _tagItem.frame.width + (generalSettings.leftAndRightMargins * 2)
        let newFrameHeight = _tagItem.frame.height + (generalSettings.topAndBottomMargins * 2)
        let newFrameSize = CGSize(width: newFrameWidth, height: newFrameHeight)
        frame = CGRect(origin: self.frame.origin, size: newFrameSize)
        
        addGesture()
    }
    
    var viewSize: CGSize {
        let width = _tagItem.frame.width + (generalSettings.leftAndRightMargins * 2)
        let height = _tagItem.frame.height + (generalSettings.topAndBottomMargins * 2)
        return CGSize(width: width, height: height)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor.clear
        isOpaque = false
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height * generalSettings.cornerRadiusRatio)
        path.addClip()
        contentColor.setFill()
        path.fill()
    }
}

extension HashTagItemView {
    
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
    
    convenience init(limitWidth width: CGFloat, tag: String, touchType: HashTagItemView.requestedHashTagManagement) {
        self.init()
        widthLimit = width
        tagString = tag
        _touchType = touchType
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
