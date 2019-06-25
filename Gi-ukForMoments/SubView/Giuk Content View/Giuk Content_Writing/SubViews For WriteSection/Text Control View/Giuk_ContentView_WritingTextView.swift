//
//  Giuk_ContentView_WritingTextView.swift
//  Gi-ukForMoments
//
//  Created by goya on 14/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

struct TextDataForGiuk: Codable {
    var comment : String
    var alignment : String
    
    init(comment: String, alignment: String) {
        self.comment = comment
        self.alignment = alignment
    }
}

@objc protocol Giuk_ContentView_WritingTextViewDelegate: class {
    @objc optional func writingTextView(_ writingView: Giuk_ContentView_WritingTextView, didChangeSelectionAt rect: CGRect, keyBoardHeight: CGFloat)
    @objc optional func writingTextView(_ writingView: Giuk_ContentView_WritingTextView, didEndEditing: Bool)
}

class Giuk_ContentView_WritingTextView: UIView, UITextViewDelegate {
    
    weak var delegate: Giuk_ContentView_WritingTextViewDelegate?

    weak var textView: UITextView!
    
    var keyBoardHeight: CGFloat?
    
    var limitNumberOfCharactors: Int?
    
    var estimateMarginForTextView: CGFloat = 10 {
        didSet {
            layoutSubviews()
        }
    }
    
    var toolBarHeight: CGFloat = 35 {
        didSet {
            layoutSubviews()
        }
    }
    
    var textData : TextDataForGiuk {
        get {
           return requestTextData()
        } set {
            _textData = newValue
        }
    }
    
    private var _textData: TextDataForGiuk? {
        didSet {
            if let data = _textData {
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
            }
        }
    }
    
    //setView
    private func setOrRepositionTextView() {
        if textView == nil {
            let newView = generateUIView(view: textView, frame: estimateAreaOfWritingModeView)
            textView = newView
            textView.font = UIFont.appleSDGothicNeo.medium.font(size: 16)
            textView.delegate = self
            textView.textColor = .goyaFontColor
            textView.backgroundColor = UIColor.goyaFontColor.withAlphaComponent(0.15)
            textView.layer.cornerRadius = 8
            textView.autocorrectionType = .no
            textView.showsVerticalScrollIndicator = false
            textView.showsHorizontalScrollIndicator = false
            addSubview(textView)
        } else {
            textView.setNewFrame(estimateAreaOfWritingModeView)
            textView.inputAccessoryView?.frame.size.height = toolBarHeight
        }
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.backgroundColor = UIColor.clear
        keyboardToolbar.barTintColor = UIColor.darkGray
        keyboardToolbar.frame.size.height = toolBarHeight
        
        let flexibleSapce = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(image: UIImage(named:"GiukIcon-Key"), style: .done, target: self, action: #selector(donePressed))
        doneButton.tintColor = .goyaWhite
        
        keyboardToolbar.setItems([flexibleSapce, doneButton], animated: false)
        
        textView.inputAccessoryView = keyboardToolbar
    }
    //end
    
    //MARK: AccessoryView Button pressed method
    @objc func donePressed() {
        delegate?.writingTextView?(self, didEndEditing: true)
        textView.resignFirstResponder()
    }
    //end
    
    //MARK: text view delegate methods
    func textViewDidChangeSelection(_ textView: UITextView) {
        if let position = trackingCursorPosition(), let boardHeight = keyBoardHeight {
            delegate?.writingTextView?(self, didChangeSelectionAt: position, keyBoardHeight: (boardHeight))
        }
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            textView.backgroundColor = .goyaYellowWhite
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let limit = limitNumberOfCharactors {
            let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
            let numberOfChars = newText.count
            return numberOfChars <= limit
        } else {
            return true
        }
    }
    
    func trackingCursorPosition() -> CGRect? {
        if let selectedRange = textView.selectedTextRange {
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            if let curpo = textView.position(from: textView.beginningOfDocument, offset: cursorPosition) {
                //position : position of charactor in textView
                let position = textView.caretRect(for: curpo)
                //poC : posotion of charactor in viewv
                let poC = textView.convert(position, to: self)
                return poC
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    //end
    
    //MARK: Manipulate textData
    private func requestTextData() -> TextDataForGiuk {
        let comment = textView.text ?? ""
        var alignment = ""
        switch textView.textAlignment {
        case .left:
            alignment = "left"
        case .center:
            alignment = "center"
        case .right:
            alignment = "right"
        default:
            break
        }
        return TextDataForGiuk(comment: comment, alignment: alignment)
    }
    //end
    
    //MARK: keyboard notification
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame: NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        keyBoardHeight = keyboardHeight
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyBoardHeight = nil
    }
    //end
    
    
    //MARK: inits and updateView layout
    override func layoutSubviews() {
        super.layoutSubviews()
        setOrRepositionTextView()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRepositionTextView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrRepositionTextView()
        backgroundColor = .goyaYellowWhite
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRepositionTextView()
        backgroundColor = .goyaYellowWhite
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //end

}

extension Giuk_ContentView_WritingTextView {
    var estimateAreaOfWritingModeView: CGRect {
        let width = bounds.width - (estimateMarginForTextView*2)
        let height = bounds.height - (estimateMarginForTextView*2)
        let size = CGSize(width: width, height: height)
        let originX = (bounds.width - width)/2
        let originY = (bounds.height - height)/2
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)//bounds
    }
}

//func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//    //        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
//    //        let newLines = text.components(separatedBy: CharacterSet.newlines)
//    //        let linesAfterChange = existingLines.count + newLines.count - 1
//    //        print("existingLines = \(existingLines)")
//    //        print("newLines = \(newLines)")
//    //        if(text == "\n") {
//    //            return linesAfterChange <= textView.textContainer.maximumNumberOfLines
//    //        }
//
//    //?? not sure
//    let endposition: UITextPosition = textView.endOfDocument
//    let position = textView.caretRect(for: endposition)
//
//    if position.maxX > textView.bounds.maxX {
//        print("false")
//        return false
//    }
//    //end
//
//    if let cursorposition = trackingCursorPosition() {
//
//        if marginForText == nil && marginForTextLine == nil {
//            marginForText = cursorposition.origin.x
//            marginForTextLine = cursorposition.origin.y
//        }
//
//        if let marginForLine = marginForTextLine, lineBreakSize == nil, cursorposition.origin.y > marginForLine {
//            lineBreakSize = cursorposition.origin.y - marginForLine
//        }
//
//        print(lineBreakSize)
//        if let breakSize = lineBreakSize, let textMargin = marginForText {
//            if cursorposition.origin.y >= ((breakSize * CGFloat(textView.textContainer.maximumNumberOfLines - 1) + textMargin)) {
//                if text == ("\n") {
//                    return false
//                }
//            }
//        }
//    }
//
//
//    let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
//    let numberOfChars = newText.count
//
//    return numberOfChars <= 100 // 30 characters limit
//}
