//
//  LabelWithContainer.swift
//  Gi-ukForMoments
//
//  Created by goya on 28/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class LabelWithContainer: UIView {
    
    weak var label: UILabel!
    
    var text: String? {
        didSet {
            label.text = self.text
        }
    }
    
    var attributedText: NSAttributedString? {
        didSet {
            label.attributedText = self.attributedText
        }
    }
    
    var textColor: UIColor? {
        didSet {
            label.textColor = self.textColor
        }
    }
    
    private func setOrRepostionLabel() {
        if label == nil {
            let newLabel = generateUIView(view: label, frame: estimateLabelGrid)
            newLabel?.setLabelAsSDStyleWithSpecificFontSize(type: .semiBold, fontSize: (newLabel!.frame.height * 0.55))
            label = newLabel
            label.textAlignment = .left
            addSubview(label)
        } else {
            label.setNewFrame(estimateLabelGrid)
            label.setLabelAsSDStyleWithSpecificFontSize(type: .semiBold, fontSize: (label.frame.height * 0.55))
        }
    }
    
    override func layoutSubviews() {
        setOrRepostionLabel()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRepostionLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrRepostionLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRepostionLabel()
    }
    
    var requiredTopAndBottomMargin: CGFloat?
    
    var requiredLeftAndRightMargin: CGFloat?
    
    private var estimateTopAndBottomMargin: CGFloat {
        return max((bounds.height * 0.1), 10)
    }
    
    private var estimateLeftAndRightMargin: CGFloat {
        return bounds.width * 0.1
    }
    
    private var estimateLabelGrid: CGRect {
        let width = bounds.width - (requiredLeftAndRightMargin ?? estimateLeftAndRightMargin)
        let height = bounds.height - (requiredTopAndBottomMargin ?? estimateTopAndBottomMargin)
        let size = CGSize(width: width, height: height)
        let originX = (requiredLeftAndRightMargin ?? estimateLeftAndRightMargin)/2
        let originY = (requiredTopAndBottomMargin ?? estimateTopAndBottomMargin)/2
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)
    }
}
