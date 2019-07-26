//
//  PresentTextView.swift
//  Gi-ukForMoments
//
//  Created by goya on 16/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class PresentTextView: UIView {
    
    private var isHorizontal : Bool {
        return ((frame.width/frame.height) > 1)
    }
    
    private var fontSize: CGFloat {
        var factor = CGFloat.zero
        if isHorizontal {
            factor = (((frame.width/3) * 4 )/1.863).clearUnderDot
        } else {
            factor = (frame.height/1.863).clearUnderDot
        }
        let estimateFontSize = factor/15
        let size = valueBetweenMinAndMax(maxValue: 16, minValue: 10, mutableValue: estimateFontSize)
        return size
    }
    
    var estimateMarginForTextView: CGFloat {
        return fontSize*0.55
    }
    
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
                if isCenteredPresenting {
                    sizeToFitTextView()
                }
            }
        }
    }
    
    var isCenteredPresenting: Bool = false
    
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
            textView.font = UIFont.appleSDGothicNeo.medium.font(size: fontSize)
            textView.textColor = .goyaFontColor
            textView.backgroundColor = .clear
            textView.autocorrectionType = .no
            textView.showsVerticalScrollIndicator = false
            textView.showsHorizontalScrollIndicator = false
            textView.isEditable = false
            textView.isSelectable = false
            backgroundView.addSubview(textView)
        } else {
            if isCenteredPresenting {
                textView.font = UIFont.appleSDGothicNeo.medium.font(size: fontSize)
                sizeToFitTextView()
            } else {
                textView.setNewFrame(estimateArea_TextView)
            }
            textView.font = UIFont.appleSDGothicNeo.medium.font(size: fontSize)
        }
    }
    
    private func sizeToFitTextView() {
        if textView.text != "" {
            textView.frame.size.width = estimateArea_TextView.width
            textView.sizeToFit()
            if textView.frame.height < estimateArea_TextView.height {
                let requierdRepositionY: CGFloat = (estimateArea_TextView.height - textView.frame.height)/2
                textView.frame.origin = estimateArea_TextView.origin.offSetBy(dX: 0, dY: requierdRepositionY)
                textView.frame.size.width = estimateArea_TextView.width
            } else {
                textView.frame = estimateArea_TextView
            }
        } else {
            textView.setNewFrame(estimateArea_TextView)
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
        let width = estimateArea_BackgroundView.width - (estimateMarginForTextView * 2)
        let height = estimateArea_BackgroundView.height - (estimateMarginForTextView * 2)
        let size = CGSize(width: width, height: height)
        let origin = CGPoint(x: estimateMargin_TextView, y: estimateMarginForTextView)
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
