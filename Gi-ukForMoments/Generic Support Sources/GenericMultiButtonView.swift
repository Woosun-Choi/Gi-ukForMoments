//
//  TappingButtonView.swift
//  LinearTimeLineViewDemo
//
//  Created by goya on 20/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol GenericMultiButtonViewDataSource {
    //func multiButtonView_NumberOfButtons(_ buttonView: GenericMultiButtonView) -> Int
    func multiButtonView_ButtonsForPresent(_ buttonView: GenericMultiButtonView) -> [UIButton_WithIdentifire]
}

@objc protocol GenericMultiButtonViewDelegate {
    //func multiButtonView_NumberOfButtons(_ buttonView: GenericMultiButtonView) -> Int
    @objc optional func multiButtonView(_ buttonView: GenericMultiButtonView, didPressedButton sender: UIButton_WithIdentifire)
}

@IBDesignable
class GenericMultiButtonView: UIView {
    
    var isSelectable: Bool = false
    
    var selectedButtonColor: UIColor = .goyaYellowWhite
    
    var deselectedButtonColor: UIColor = UIColor.init(red: 211/255, green: 210/255, blue: 210/255, alpha: 1)
    
    weak var dataSource: GenericMultiButtonViewDataSource?
    
    weak var delegate: GenericMultiButtonViewDelegate?
    
    weak var buttonContentArea: UIView!
    
    var buttons : [UIButton_WithIdentifire] {
        return dataSource?.multiButtonView_ButtonsForPresent(self) ?? [UIButton_WithIdentifire]()
    }
    
    @IBInspectable var requiredMarginBetweenItems: CGFloat = 3
    
    @IBInspectable var requiredMarginInsets: CGFloat = 5
    
    private var _requestedButtonAreaFrame: CGRect?
    
    var buttonAreaFrame: CGRect {
        get {
            return (_requestedButtonAreaFrame == nil) ? defaultButtonAreaFrame : _requestedButtonAreaFrame!
        }
        set {
            _requestedButtonAreaFrame = newValue
            layoutSubviews()
        }
    }
    
    private var estimatedButtonSize: CGSize {
        if buttons.count > 0 {
            let width = ((defaultButtonAreaFrame.width - (requiredMarginInsets*2) - (requiredMarginBetweenItems * CGFloat(buttons.count - 1).clearUnderDot)) / CGFloat(buttons.count).clearUnderDot)
            let height = (defaultButtonAreaFrame.height - (requiredMarginInsets*2))
            return CGSize(width: width, height: height)
        } else {
            return CGSize.zero
        }
    }
    
    private var defaultButtonAreaFrame: CGRect {
        let width = frame.width
        let height = frame.height
        let originX : CGFloat = 0
        let originY : CGFloat = 0
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    private func setOrReposition_ContentArea() {
        if buttonContentArea == nil {
            let contentView = UIView()
            contentView.contentMode = .redraw
            contentView.clipsToBounds = true
            buttonContentArea = contentView
            buttonContentArea.frame = buttonAreaFrame
            buttonContentArea.layer.cornerRadius = (buttonContentArea.frame.size.height * 0.1618).clearUnderDot
            addSubview(contentView)
        } else {
            buttonContentArea.frame = buttonAreaFrame
            buttonContentArea.layer.cornerRadius = (buttonContentArea.frame.size.height * 0.1618).clearUnderDot
        }
    }
    
    //MARK: set buttons
    func reloadButtons(completion: (()->Void)? = nil) {
        self.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.15, animations: {
            self.alpha = 0
        }) { [unowned self](finished) in
            if self.buttons.count > 0 {
                self.buttonContentArea.subviews.forEach { (view) in
                    view.removeFromSuperview()
                }
                
                var nowOriginX: CGFloat = self.requiredMarginInsets
                var nowOriginY: CGFloat = self.requiredMarginInsets
                var buttonOrigin: CGPoint {
                    return CGPoint(x: nowOriginX, y: nowOriginY)
                }
                for button in self.buttons {
                    button.addTarget(self, action: #selector(self.buttonPressed(_:)), for: .touchUpInside)
                    button.frame = CGRect(origin: buttonOrigin, size: self.estimatedButtonSize)
                    self.buttonContentArea.addSubview(button)
                    nowOriginX = (button.frame.maxX + self.requiredMarginBetweenItems)
                }
            } else {
                return
            }
            completion?()
            UIView.animate(withDuration: 0.25, animations: {
                self.alpha = 1
            }, completion:
                { [weak self](finished) in
                    self?.isUserInteractionEnabled = true
            })
        }
    }
    
    //button actions
    @objc func buttonPressed(_ sender: UIButton_WithIdentifire) {
        checkButtonStateWithIdentifire(sender.identifire)
        delegate?.multiButtonView?(self, didPressedButton: sender)
    }
    
    private func checkButtonStateWithIdentifire(_ identifire: String) {
        if isSelectable == true {
            for button in buttons {
                if button.identifire == identifire {
                    button.isSelected = true
                    button.backgroundColor = selectedButtonColor
                } else {
                    button.isSelected = false
                    button.backgroundColor = deselectedButtonColor
                }
            }
        }
    }
    //end
    //end
    
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
    
    func initialAction() {
        if buttons.count > 0 {
            for button in buttons.indices {
                if button == 0 {
                    buttons[button].sendActions(for: .touchUpInside)
                }
            }
        }
    }
    
    func requieredActionWithButtonIndex(_ index: Int?) {
        if let buttonIndex = index {
            buttons[buttonIndex].sendActions(for: .touchUpInside)
        } else {
            initialAction()
        }
    }
    
    //MARK: layouts
    override func layoutSubviews() {
        super.layoutSubviews()
        setOrReposition_ContentArea()
        reLayoutButtons()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrReposition_ContentArea()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrReposition_ContentArea()
    }
}


//    struct buttonContent {
//        var tag: Int?
//        var title: String?
//        var image: UIImage?
//        var function: (()->Void)?
//
//        init(tag: Int?, title: String?, image: UIImage?, function: (()->Void)?) {
//            self.tag = tag
//            self.title = title
//            self.image = image
//            self.function = function
//        }
//    }
//
//    var buttonContents = [buttonContent]()
//
//    func addButtonContent(title: String, function: (()->Void)?) {
//        buttonContents.append(buttonContent(tag: nil, title: title, image: nil, function: function))
//    }
