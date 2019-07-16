//
//  TextFieldWithContainer.swift
//  Gi-ukForMoments
//
//  Created by goya on 28/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol TextFieldWithContainerDelegate {
    @objc optional func textFieldWithContainer_DidEndEditing(_ textFieldInContainer: UITextField, text: String?, expectedEndEditingState: Bool)
}

class TextFieldWithContainer: UIView, UITextFieldDelegate {
    
    weak var delegate: TextFieldWithContainerDelegate?
    
    weak var textField: UITextField!
    
    var toolBarHeight: CGFloat = 35
    
    private func setOrRepostionTextField() {
        if textField == nil {
            let newLabel = generateUIView(view: textField, frame: estimateLabelGrid)
            textField = newLabel
            textField.backgroundColor = .goyaWhite
            let fontSize = max((textField.frame.height * 0.418), 12)
            textField.font = UIFont.appleSDGothicNeo.regular.font(size: fontSize)
            textField.layer.cornerRadius = textField.frame.height * 0.1618
//            textField.placeholder = " ADD NEW MARK"
            textField.autocorrectionType = .no
            textField.delegate = self
            textField.textAlignment = .center
            textField.attributedPlaceholder = "Add new mark".centeredAttributedString(fontSize: fontSize)
            setKeyboardToTextField()
            addSubview(textField)
        } else {
            textField.setNewFrame(estimateLabelGrid)
            let fontSize = max((textField.frame.height * 0.418), 12)
            textField.font = UIFont.appleSDGothicNeo.regular.font(size: fontSize)
            textField.layer.cornerRadius = textField.frame.height * 0.1618
        }
    }
    
    private func setKeyboardToTextField() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.backgroundColor = UIColor.clear
        keyboardToolbar.barTintColor = UIColor.goyaSemiBlackColor
        keyboardToolbar.frame.size.height = toolBarHeight
        
        let flexibleSapce = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(image: nil, style: .done, target: self, action: #selector(donePressed))
        doneButton.image = UIImage(named: ButtonImageNames.ButtonName_Content_Confirm_Blank)
        doneButton.tintColor = .goyaWhite
        
        keyboardToolbar.setItems([flexibleSapce, doneButton], animated: false)
        
        textField.inputAccessoryView = keyboardToolbar
    }
    
    
    //MARK: AccessoryView Button pressed method
    @objc func donePressed() {
        delieverTextToDelegate(true)
    }
    //end
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        delieverTextToDelegate(false)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == " " {
            delieverTextToDelegate(false)
            return false
        } else {
            return true
        }
    }
    
    private func delieverTextToDelegate(_ endEditingState: Bool) {
        if let text = textField.text, text != "" && text != " " {
            delegate?.textFieldWithContainer_DidEndEditing?(textField, text: text, expectedEndEditingState: endEditingState)
        } else {
            delegate?.textFieldWithContainer_DidEndEditing?(textField, text: nil, expectedEndEditingState: endEditingState)
        }
    }
    
    override func layoutSubviews() {
        setOrRepostionTextField()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRepostionTextField()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .goyaSemiBlackColor
        setOrRepostionTextField()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .goyaSemiBlackColor
        setOrRepostionTextField()
    }
    
    var requiredTopAndBottomMargin: CGFloat?
    
    var requiredLeftAndRightMargin: CGFloat?
    
    private var estimateTopAndBottomMargin: CGFloat {
        return max((bounds.height * 0.1), 10)
    }
    
    private var estimateLeftAndRightMargin: CGFloat {
        return bounds.width * 0.10
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
