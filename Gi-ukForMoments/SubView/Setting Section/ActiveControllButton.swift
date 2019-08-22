//
//  ActiveUiButton.swift
//  Gi-ukForMoments
//
//  Created by goya on 22/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class ActiveControllButton: UIButton_WithIdentifire {
    
    weak var textLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.25) {
                self.setTextLabel()
            }
        }
    }
    
    var activeColor: UIColor = .goyaWhite
    var deActiveColor: UIColor {
        return activeColor.withAlphaComponent(0.5)
    }
    var activeTitle: String = "Activated"
    var deActiveTitle: String = "Deactivated"
    
    private var fontSize: CGFloat {
        return valueBetweenMinAndMax(maxValue: 16.cgFloat, minValue: 10.cgFloat, mutableValue: bounds.height * 0.618)
    }
    
    private func setTextLabel() {
        
        var nowColor: UIColor {
            if isSelected {
                return activeColor
            } else {
                return deActiveColor
            }
        }
        
        var nowTilte: String {
            if isSelected {
                return activeTitle
            } else {
                return deActiveTitle
            }
        }
        
        if textLabel == nil {
            let newLable = generateUIView(view: textLabel, frame: bounds)
            textLabel = newLable
            textLabel.numberOfLines = 0
            textLabel.textAlignment = .center
            textLabel.setLabelAsSDStyleWithSpecificFontSize(type: .bold, fontSize: fontSize)
            textLabel.textColor = nowColor
            textLabel.text = nowTilte
            textLabel.isUserInteractionEnabled = false
            addSubview(textLabel)
        } else {
            textLabel.setNewFrame(bounds)
            textLabel.setLabelAsSDStyleWithSpecificFontSize(type: .bold, fontSize: fontSize)
            textLabel.textColor = nowColor
            textLabel.text = nowTilte
        }
    }
    
    private func drawRoundedPath() {
        var nowColor: UIColor {
            if isSelected {
                return activeColor
            } else {
                return deActiveColor
            }
        }
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 16)
        nowColor.setStroke()
        path.lineWidth = 2
        path.stroke()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setTextLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setTextLabel()
    }
    
    override func draw(_ rect: CGRect) {
//        drawRoundedPath()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTextLabel()
    }
    
    convenience init(activeTitle: String, deactiveTitle: String, activeColor: UIColor = .goyaWhite, deActiveColor: UIColor = .goyaSemiBlackColor) {
        self.init()
        self.activeTitle = activeTitle
        self.deActiveTitle = deactiveTitle
        self.activeColor = activeColor
        //        self.deActiveColor = deActiveColor
    }
    
}
