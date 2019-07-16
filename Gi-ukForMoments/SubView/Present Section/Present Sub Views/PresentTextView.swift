//
//  PresentTextView.swift
//  Gi-ukForMoments
//
//  Created by goya on 16/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class PresentTextView: UIView {
    
    weak var backgroundView: UIView!
    
    weak var textView: UITextView!
    
    var textData: TextInformation? {
        didSet {
            if let data = textData {
                switch data.alignment {
                case "left":
                    textView.textAlignment = .left
                case "center":
                    textView.textAlignment = .center
                case "right":
                    textView.textAlignment = .right
                default:
                    break
                }
                textView.text = data.comment
                sizeToFitTextView()
            }
        }
    }
    
    var estimateMarginForTextView: CGFloat = 10 {
        didSet {
            layoutSubviews()
        }
    }
    
    private func setOrRepositionBackgroundView() {
        if backgroundView == nil {
            let newView = generateUIView(view: backgroundView, frame: estimateArea_BackgroundView)
            backgroundView = newView
            backgroundView.backgroundColor = .clear
            backgroundView.layer.cornerRadius = 8
            addSubview(backgroundView)
        } else {
            backgroundView.setNewFrame(estimateArea_BackgroundView)
        }
    }
    
    private func setOrRepositionTextView() {
        if textView == nil {
            let newView = generateUIView(view: textView, frame: estimateArea_TextView)
            textView = newView
            textView.font = UIFont.appleSDGothicNeo.medium.font(size: 16)
            textView.textColor = .goyaFontColor
            textView.backgroundColor = .clear
            textView.autocorrectionType = .no
            textView.showsVerticalScrollIndicator = false
            textView.showsHorizontalScrollIndicator = false
            textView.isEditable = false
            textView.isSelectable = false
            backgroundView.addSubview(textView)
        } else {
            if textView.text == "" {
                textView.setNewFrame(estimateArea_TextView)
            } else {
                sizeToFitTextView()
            }
        }
    }
    
    private func sizeToFitTextView() {
        textView.frame.size.width = estimateArea_TextView.width
        textView.sizeToFit()
        if textView.frame.height < estimateArea_TextView.height {
            let requierdRepositionY: CGFloat = (estimateArea_TextView.height - textView.frame.height)/2
            textView.frame.origin = estimateArea_TextView.origin.offSetBy(dX: 0, dY: requierdRepositionY)
            textView.frame.size.width = estimateArea_TextView.width
        } else {
            textView.frame = estimateArea_TextView
        }
    }
    
    var estimateArea_BackgroundView: CGRect {
        let width = bounds.width - (estimateMarginForTextView*2)
        let height = bounds.height - (estimateMarginForTextView*2)
        let size = CGSize(width: width, height: height)
        let originX = (bounds.width - width)/2
        let originY = (bounds.height - height)/2
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)//bounds
    }
    
    var estimateMargin_TextView: CGFloat {
        return 5
    }
    
    var estimateArea_TextView: CGRect {
        let width = estimateArea_BackgroundView.width - (estimateMargin_TextView * 2)
        let height = estimateArea_BackgroundView.height - (estimateMargin_TextView * 2)
        let size = CGSize(width: width, height: height)
        let origin = CGPoint(x: estimateMargin_TextView, y: estimateMargin_TextView)
        return CGRect(origin: origin, size: size)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setOrRepositionBackgroundView()
        setOrRepositionTextView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrRepositionBackgroundView()
        setOrRepositionTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRepositionBackgroundView()
        setOrRepositionTextView()
    }
}
