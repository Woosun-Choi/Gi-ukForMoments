//
//  Giuk_MainFrame_ContainerView.swift
//  Gi-ukForMoments
//
//  Created by goya on 16/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol ContainerViewButtonDataSource {
    func containerViewButtonItem(_ containerView: Giuk_MainFrame_ContainerView) -> [Giuk_MainButtonItem]
    func containerViewContentAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGRect
    func containerViewButtonAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGRect
}

class Giuk_MainFrame_ContainerView: UIView
{
    var buttonGrid = ButtonGridManager()
    
    weak var dataSource: ContainerViewButtonDataSource?
    
    var buttonArea: UIView!
    
    var contentArea: UIView!
    
    var buttonItems: [Giuk_MainButtonItem] {
        return dataSource?.containerViewButtonItem(self) ?? [Giuk_MainButtonItem]()
    }
    
    var buttonFrame: CGRect {
        return dataSource?.containerViewButtonAreaRect(self) ?? CGRect.zero
    }
    
    var contentAreaFrame: CGRect {
        return dataSource?.containerViewContentAreaRect(self) ?? CGRect.zero
    }
    
    private func setOrRepositionButtonArea() {
        if buttonArea == nil {
            let areaView = UIView()
            areaView.backgroundColor = .green
            areaView.frame = buttonFrame
            buttonArea = areaView
            addSubview(buttonArea)
        } else {
            buttonArea.frame = buttonFrame
        }
    }
    
    private func setOrRepositionContentArea() {
        if contentArea == nil {
            let areaView = UIView()
            areaView.backgroundColor = .yellow
            areaView.frame = contentAreaFrame
            contentArea = areaView
            addSubview(contentArea)
        } else {
            contentArea.frame = contentAreaFrame
        }
    }
    
    private func setOrRepositionButtonsInButtonArea() {
        buttonGrid.alignmentStyle = .positiveAligned
        for subView in buttonArea.subviews {
            subView.removeFromSuperview()
        }
        
        let rects = buttonGrid.requestButtonFramesWith(frame: buttonFrame, minSpace: 3, numberOfButtons: buttonItems.count)
        for button in buttonItems {
            if let buttonIndex = buttonItems.firstIndex(of: button) {
                button.frame = rects[buttonIndex]
                buttonArea.addSubview(button)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setOrRepositionContentArea()
        setOrRepositionButtonArea()
        setOrRepositionButtonsInButtonArea()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRepositionContentArea()
        setOrRepositionButtonArea()
        setOrRepositionButtonsInButtonArea()
    }

}
