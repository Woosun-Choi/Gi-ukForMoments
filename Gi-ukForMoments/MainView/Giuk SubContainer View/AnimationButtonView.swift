//
//  AnimationButtonView.swift
//  Gi-ukForMoments
//
//  Created by goya on 08/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol AnimateButtonViewButtonDataSource {
    func containerViewButtonItem(_ containerView: AnimateButtonView) -> [UIButton_WithIdentifire]
    func containerViewButtonAreaRect(_ containerView: AnimateButtonView) -> CGRect
}

class AnimateButtonView: UIView
{
    var buttonGrid = ButtonGridManager()
    weak var dataSource: AnimateButtonViewButtonDataSource?
    weak var buttonArea: UIView!
    
    var buttonItems: [UIButton_WithIdentifire] {
        return dataSource?.containerViewButtonItem(self) ?? [UIButton_WithIdentifire]()
    }
    
    var buttonFrame: CGRect {
        return dataSource?.containerViewButtonAreaRect(self) ?? frame
    }
    
    private func setOrRepositionButtonArea() {
        if buttonArea == nil {
            let areaView = UIView()
            areaView.backgroundColor = .clear
            areaView.frame = buttonFrame
            buttonArea = areaView
            addSubview(buttonArea)
        } else {
            buttonArea.frame = buttonFrame
        }
    }
    
    private func setOrRepositionButtonsInButtonArea() {
        
        for subView in buttonArea.subviews {
            subView.removeFromSuperview()
        }
        
        if buttonItems.count != 0 {
            let rects = buttonGrid.requestButtonFramesWith(frame: buttonFrame, minSpace: 3, numberOfButtons: buttonItems.count)
            for button in buttonItems {
                if let buttonIndex = buttonItems.firstIndex(of: button) {
                    button.frame = rects[buttonIndex]
                    buttonArea.addSubview(button)
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setOrRepositionButtonArea()
        setOrRepositionButtonsInButtonArea()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRepositionButtonArea()
        setOrRepositionButtonsInButtonArea()
    }
    
}
