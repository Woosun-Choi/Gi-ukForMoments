//
//  Giuk_MainFrame_ContainerView.swift
//  Gi-ukForMoments
//
//  Created by goya on 16/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol ContainerViewButtonDataSource {
    func containerViewButtonItem(_ containerView: Giuk_MainFrame_ContainerView) -> [UIButton_WithIdentifire]
    func containerViewContentAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGSize
    func containerViewButtonAreaRect(_ containerView: Giuk_MainFrame_ContainerView) -> CGRect
}

class Giuk_MainFrame_ContainerView: UIView
{
    weak var dataSource: ContainerViewButtonDataSource?
    
    private var buttonGrid = ButtonGridManager()
    
    private weak var contentArea: UIView!
    
    private weak var closeButton: UIButton!
    
    var contentAreaBackgroundColor: UIColor?
    
    var closingButtonRequired: Bool = true
    
    weak var buttonArea: UIView!
    
    weak var contentView: UIView!
    
    var requieredTopMargin: CGFloat = 0
    
    var requieredBottomMargin: CGFloat = 0
    
    
    var buttonItems: [UIButton_WithIdentifire] {
        return dataSource?.containerViewButtonItem(self) ?? [UIButton_WithIdentifire]()
    }
    
    var buttonFrame: CGRect {
        return dataSource?.containerViewButtonAreaRect(self) ?? defaultButtonFrame
    }
    
    var contentAreaFrame: CGSize {
        return dataSource?.containerViewContentAreaRect(self) ?? CGSize.zero
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
    
    private func setOrRepositionContentArea() {
        if contentArea == nil {
            let areaView = UIView()
            areaView.isOpaque = false
            areaView.backgroundColor = contentAreaBackgroundColor ?? UIColor.goyaSemiBlackColor
            areaView.frame = CGRect(origin: contentAreaOrigin, size: contentAreaFrame)
            contentArea = areaView
            addSubview(contentArea)
        } else {
            contentArea.frame = CGRect(origin: contentAreaOrigin, size: contentAreaFrame)
        }
        setOrRepositionContentView()
    }
    
    private func setOrRepositionContentView() {
        if contentView == nil {
            let areaView = UIView()
            areaView.isOpaque = false
            areaView.backgroundColor = UIColor.clear
            areaView.frame = CGRect(origin: expectedContentOriginInContentArea, size: expectedContentSize)
            contentView = areaView
            contentArea.addSubview(contentView)
        } else {
            contentView.frame = CGRect(origin: expectedContentOriginInContentArea, size: expectedContentSize)
        }
    }
    
    private func setOrRepositionButtonsInButtonArea() {
        buttonGrid.alignmentStyle = .positiveAligned
        
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
    
    private func setOrRepositionColseButton() {
        if closingButtonRequired {
            if closeButton == nil {
                let newButton = generateUIView(view: closeButton, origin: closeButtonOrigin, size: closeButtonSize)
                closeButton = newButton
                closeButton?.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
                closeButton?.setTitle("-", for: .normal)
                closeButton?.backgroundColor = .green
                addSubview(closeButton)
            } else {
                closeButton.setNewFrame(CGRect(origin: closeButtonOrigin, size: closeButtonSize))
            }
        } else {
            return
        }
    }
    
    var requestedActionForClose : (() -> Void)?
    
    @objc func closeButtonAction(_ sender: UIButton) {
        requestedActionForClose?()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setOrRepositionContentArea()
        setOrRepositionButtonArea()
        setOrRepositionButtonsInButtonArea()
        setOrRepositionColseButton()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRepositionContentArea()
        setOrRepositionButtonArea()
        setOrRepositionButtonsInButtonArea()
        setOrRepositionColseButton()
    }

}

extension Giuk_MainFrame_ContainerView {
    
    private var contentAreaOrigin : CGPoint {
        let originX = frame.size.width - contentAreaFrame.width
        let originY: CGFloat = 0
        return CGPoint(x: originX, y: originY)
    }
    
    private var expectedContentSize: CGSize {
        let width = contentAreaFrame.width
        let height = contentAreaFrame.height - requieredTopMargin - requieredBottomMargin
        return CGSize(width: width, height: height)
    }
    
    private var expectedContentOriginInContentArea: CGPoint {
        let originX = (contentAreaFrame.width - expectedContentSize.width).absValue/2
        let originY = requieredTopMargin
        return CGPoint(x: originX, y: originY)
    }
    
    private var expectedContentOriginInView: CGPoint {
        return contentAreaOrigin.offSetBy(dX: expectedContentOriginInContentArea.x, dY: expectedContentOriginInContentArea.y)
    }
    
    private var closeButtonSize: CGSize {
        let width = (frame.width * 0.08).clearUnderDot
        let height = width
        return CGSize(width: width, height: height)
    }
    
    private var closeButtonOrigin: CGPoint {
        let originX = GiukContentFrameFactors.contentMinimumMargin.dX + contentAreaOrigin.x
        let originY = GiukContentFrameFactors.contentMinimumMargin.dY + contentAreaOrigin.y + requieredTopMargin
        return CGPoint(x: originX, y: originY)
    }
    
    private var defaultButtonFrame: CGRect {
        let width = frame.width
        let height = frame.height * 0.0618
        let originX: CGFloat = 0
        let originY = frame.height - height
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}
