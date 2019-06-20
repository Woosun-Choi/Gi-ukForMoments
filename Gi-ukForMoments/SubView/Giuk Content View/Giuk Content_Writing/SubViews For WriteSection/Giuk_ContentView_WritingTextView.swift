//
//  Giuk_ContentView_WritingTextView.swift
//  Gi-ukForMoments
//
//  Created by goya on 14/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class Giuk_ContentView_WritingTextView: UIView, UITextViewDelegate {

    weak var textView: UITextView!
    
    var estimateAreaOfWritingModeView: CGRect {
        return frame
    }
    
    //setView
    private func setOrRepositionTextView() {
        if textView == nil {
            let newView = generateUIView(view: textView, frame: estimateAreaOfWritingModeView)
            textView = newView
            textView.font = UIFont.appleSDGothicNeo.medium.font(size: 16)
            textView.delegate = self
            addSubview(textView)
        } else {
            textView.setNewFrame(estimateAreaOfWritingModeView)
        }
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.backgroundColor = UIColor.clear
        keyboardToolbar.barTintColor = UIColor.darkGray
        
        let flexibleSapce = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(image: UIImage(named:"GiukIcon-Key"), style: .done, target: self, action: #selector(donePressed))
        doneButton.tintColor = .goyaWhite
        
        keyboardToolbar.setItems([flexibleSapce, doneButton], animated: false)
        
        textView.inputAccessoryView = keyboardToolbar
    }
    
    @objc func donePressed() {
        textView.resignFirstResponder()
    }
    //end
    
    //delegates
    func textViewDidChangeSelection(_ textView: UITextView) {
        print("textview did changeselection")
        _ = trackingCursorPosition()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        print("textview did changed")
        _ = trackingCursorPosition()
    }
    
    func trackingCursorPosition() -> CGRect? {
        if let selectedRange = textView.selectedTextRange {
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            if let curpo = textView.position(from: textView.beginningOfDocument, offset: cursorPosition) {
                //position : position of charactor in textView
                let position = textView.caretRect(for: curpo)
                //poC : posotion of charactor in view
                let poC = textView.convert(position, to: self)
                print(position)
                print(poC)
                return position
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    //MARK: keyboard notification
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        print(keyboardHeight)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
    }
    //end
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

}
