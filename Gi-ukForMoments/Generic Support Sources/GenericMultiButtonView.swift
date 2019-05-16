//
//  TappingButtonView.swift
//  LinearTimeLineViewDemo
//
//  Created by goya on 20/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class tapButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .goyaBlack
        setTitleColor(.goyaWhite, for: .selected)
        setTitleColor(.gray, for: .normal)
        let estimateSizeOfFont: CGFloat = self.frame.height * 0.418
        titleLabel?.setLabelAsSDStyleWithSpecificFontSize(type: .bold, fontSize: estimateSizeOfFont)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .goyaBlack
        setTitleColor(.goyaWhite, for: .selected)
        setTitleColor(.gray, for: .normal)
        let estimateSizeOfFont: CGFloat = self.frame.height * 0.418
        titleLabel?.setLabelAsSDStyleWithSpecificFontSize(type: .bold, fontSize: estimateSizeOfFont)
    }
    
    func resizeTitleLabelContent() {
        let estimateSizeOfFont: CGFloat = self.frame.height * 0.418
        titleLabel?.setLabelAsSDStyleWithSpecificFontSize(type: .bold, fontSize: estimateSizeOfFont)
        setNewTitle()
    }
    
    private func setNewTitle() {
        if let currentTitle = title {
            setTitle(currentTitle, for: .normal)
        }
    }
    
    private var _title : String?
    
    var title: String? {
        get {
            return _title
        } set {
            _title = newValue
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        resizeTitleLabelContent()
    }
}

class GenericMultiButtonView: UIView {
    
    //MARK: buttons
    
    var gridManager = ButtonGridManager()
    
    var buttons = [tapButton]()
    
    struct buttonContent {
        var tag: Int?
        var title: String?
        var image: UIImage?
        var function: (()->Void)?
        
        init(tag: Int?, title: String?, image: UIImage?, function: (()->Void)?) {
            self.tag = tag
            self.title = title
            self.image = image
            self.function = function
        }
    }
    
    var buttonContents = [buttonContent]()
    
    func addButtonContent(title: String, function: (()->Void)?) {
        buttonContents.append(buttonContent(tag: nil, title: title, image: nil, function: function))
    }
    
    func configureButtons() {
        if buttons.count > 0 {
            buttonContentArea.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
            buttons.removeAll()
        }
        
        var nowOriginX: CGFloat = requiredMarginInsets
        var nowOriginY: CGFloat = requiredMarginInsets
        var buttonOrigin: CGPoint {
            return CGPoint(x: nowOriginX, y: nowOriginY)
        }
        for button in buttonContents {
            let newButton = tapButton()
            newButton.title = button.title
            newButton.frame = CGRect(origin: buttonOrigin, size: estimatedButtonSize)
            newButton.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(newButton)
            buttonContentArea.addSubview(newButton)
            nowOriginX = (newButton.frame.maxX + requiredMarginBetweenItems)
        }
    }
    
    //MARK: buttonContentView
    var buttonContentArea: UIView!
    
    private var requieredButtonAreaFrame: CGRect {
        let width = (frame.width * 0.618).clearUnderDot
        let height = (frame.height * 0.618).clearUnderDot
        let originX = (frame.width - width)/2
        let originY = (frame.height - height)/2
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    private var _requestedButtonAreaFrame: CGRect?
    
    var requestedButtonAreaFrame: CGRect {
        get {
            if _requestedButtonAreaFrame == nil {
                return requieredButtonAreaFrame
            } else {
                return _requestedButtonAreaFrame!
            }
        }
        set {
            _requestedButtonAreaFrame = newValue
        }
    }
    
    func setOrReposition_ContentArea(_ withFrame: CGRect) {
        if buttonContentArea == nil {
            let contentView = UIView()
            contentView.contentMode = .redraw
            contentView.clipsToBounds = true
            buttonContentArea = contentView
            buttonContentArea.frame = withFrame
            buttonContentArea.layer.cornerRadius = (buttonContentArea.frame.size.height * 0.1618).clearUnderDot
            addSubview(contentView)
        } else {
            buttonContentArea.frame = requieredButtonAreaFrame
            buttonContentArea.layer.cornerRadius = (buttonContentArea.frame.size.height * 0.1618).clearUnderDot
        }
    }
    
    var estimatedButtonSize: CGSize {
        let width = ((requieredButtonAreaFrame.width - (requiredMarginInsets*2) - (requiredMarginBetweenItems * CGFloat(buttonContents.count - 1).clearUnderDot)) / CGFloat(buttonContents.count).clearUnderDot)
        let height = (requieredButtonAreaFrame.height - (requiredMarginInsets*2))
        return CGSize(width: width, height: height)
    }
    
    var requiredMarginBetweenItems: CGFloat = 3
    
    var requiredMarginInsets: CGFloat = 0
    
    func reLayoutButtons() {
        if buttons.count > 0 {
            var nowOriginX: CGFloat = requiredMarginInsets
            var nowOriginY: CGFloat = requiredMarginInsets
            var buttonOrigin: CGPoint {
                return CGPoint(x: nowOriginX, y: nowOriginY)
            }
            for button in buttons {
                button.frame = CGRect(origin: buttonOrigin, size: estimatedButtonSize)
                nowOriginX = (button.frame.maxX + requiredMarginBetweenItems)
            }
        }
    }
    
    @objc func buttonTapped(_ button: tapButton) {
        let buttonTitle = button.title
        
        for buttonItem in buttonContents {
            if buttonItem.title == buttonTitle {
                buttonItem.function?()
            }
        }
        
        for subView in buttonContentArea.subviews {
            if let buttonView = subView as? tapButton {
                if buttonView.title == buttonTitle {
                    buttonView.isSelected = true
                } else {
                    buttonView.isSelected = false
                }
            }
        }
    }
    
    func initialAction() {
        if buttons.count > 0 {
            for button in buttons.indices {
                if button == 0 {
                    buttons[button].sendActions(for: .touchUpInside)
                }
            }
        }
    }
    
    //MARK: layouts
    override func layoutSubviews() {
        super.layoutSubviews()
        gridManager.updateFrameInformation(targetFrame: requestedButtonAreaFrame, minSpacing: 3, alignment: .centered)
        setOrReposition_ContentArea(requestedButtonAreaFrame)
        reLayoutButtons()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrReposition_ContentArea(requestedButtonAreaFrame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrReposition_ContentArea(requestedButtonAreaFrame)
    }
}

extension GenericMultiButtonView {
    
}
