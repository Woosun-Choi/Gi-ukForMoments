//
//  Giuk_ContentView_WritingTextView.swift
//  Gi-ukForMoments
//
//  Created by goya on 14/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

/*
 Description
 - This View used to take text from user and generate textinforation to save
 
 Major View
 - BakcgroundView : Give a background to textview
 - TextView : A View what user interation occurs
 
 Major Variables
 - textData : {get set} return textInformation from user inputs, set textView text with textInformation
 
 DataSource
 - none
 
 Delegate : Giuk_ContentView_WritingTextViewDelegate
 - didChangeSelectionAt : when user change selection with in sentence.
 - didEndEditing : when the user did end editing.
 - didKeyBoardComesIn : when the keyboard comes in.
*/

import UIKit

//MARK: TextInformation
struct TextInformation: Codable {
    var comment : String
    var alignment : String
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(TextInformation.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    init(comment: String, alignment: String) {
        self.comment = comment
        self.alignment = alignment
    }
}

//MARK: Delegate
@objc protocol Giuk_ContentView_WritingTextViewDelegate: class {
    @objc optional func writingTextView(_ writingView: Giuk_ContentView_WritingTextView, didChangeSelectionAt rect: CGRect, keyBoardHeight: CGFloat)
    @objc optional func writingTextView(_ writingView: Giuk_ContentView_WritingTextView, didEndEditing: Bool)
    @objc optional func writingTextView(_ writingView: Giuk_ContentView_WritingTextView, didKeyBoardComesIn: Bool, keyBoardHeight: CGFloat)
}

//MARK: View Codes
class Giuk_ContentView_WritingTextView: UIView, UITextViewDelegate {
    
    //MARK: Subviews
    
    weak var backgroundView: UIView!

    weak var textView: UITextView!
    
    private weak var placeHolder: UILabel!
    
    //end
    
    //MARK: Variables
    weak var delegate: Giuk_ContentView_WritingTextViewDelegate?
    
    var isEditable: Bool = true {
        didSet {
            textView?.isEditable = self.isEditable
            textView?.isSelectable = self.isEditable
            checkTextAndSetPlaceHolder()
        }
    }
    
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
    
    var textData : TextInformation {
        get {
           return requestTextData()
        } set {
            _textData = newValue
        }
    }
    
    private var _textData: TextInformation? {
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
                checkTextAndSetPlaceHolder()
            }
        }
    }
    
    var keyBoardHeight: CGFloat? {
        didSet {
            delegate?.writingTextView?(self, didKeyBoardComesIn: (self.keyBoardHeight != nil), keyBoardHeight: self.keyBoardHeight ?? 0)
        }
    }
    //end
    
    //Mark: Set and layout subviews
    private func setOrRepositionBackgroundView() {
        if backgroundView == nil {
            let newView = generateUIView(view: backgroundView, frame: estimateArea_BackgroundView)
            backgroundView = newView
            backgroundView.backgroundColor = UIColor.goyaFontColor.withAlphaComponent(0.15)
            backgroundView.layer.cornerRadius = 8
            addSubview(backgroundView)
        } else {
            backgroundView.setNewFrame(estimateArea_BackgroundView)
        }
    }
    
    private func setOrRepositionTextView() {
        if textView == nil {
            let newView = generateUIView(view: textView, frame: estimateArea_TextView)
            textView = newView
            textView.font = UIFont.appleSDGothicNeo.medium.font(size: 16)
            textView.delegate = self
            textView.textColor = .goyaFontColor
            textView.backgroundColor = .clear
            textView.autocorrectionType = .no
            textView.showsVerticalScrollIndicator = false
            textView.showsHorizontalScrollIndicator = false
            textView.isEditable = self.isEditable
            setKeyboardToTextView()
            backgroundView.addSubview(textView)
        } else {
            textView.isEditable = self.isEditable
            textView.setNewFrame(estimateArea_TextView)
            textView.inputAccessoryView?.frame.size.height = toolBarHeight
        }
    }
    
    private func setKeyboardToTextView() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.backgroundColor = UIColor.clear
        keyboardToolbar.barTintColor = UIColor.goyaSemiBlackColor
        keyboardToolbar.frame.size.height = toolBarHeight
        
        let flexibleSapce = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        
        let doneButton = UIBarButtonItem(image: nil, style: .done, target: self, action: #selector(donePressed))
        doneButton.image = UIImage(named: ButtonImageNames.ButtonName_Content_Confirm_Blank)
        doneButton.tintColor = .goyaWhite
        
        keyboardToolbar.setItems([flexibleSapce, doneButton], animated: false)
        
        textView.inputAccessoryView = keyboardToolbar
    }
    
    private func setOrRepositionPlaceHolder() {
        let fontSize = valueBetweenMinAndMax(maxValue: DescribingSources.sectionsFontSize.maxFontSize.cgFloat, minValue: DescribingSources.sectionsFontSize.minFontSize.cgFloat, mutableValue: (frame.height * 0.0618))
        let attributedText = String.generatePlaceHolderMutableAttributedString(fontSize: fontSize, titleText: DescribingSources.textInPutSection.notice_Title, subTitleText: DescribingSources.textInPutSection.notice_SubTiltle)
        
        if placeHolder == nil {
            let newHolder = generateUIView(view: placeHolder, frame: bounds)
            placeHolder = newHolder
            placeHolder.setLabelAsSDStyleWithSpecificFontSize(fontSize: fontSize)
            placeHolder.textColor = .GiukBackgroundColor_depth_1
            placeHolder.numberOfLines = 0
            placeHolder.attributedText = attributedText
            addSubview(placeHolder)
        } else {
            placeHolder.setNewFrame(bounds)
            placeHolder.attributedText = attributedText
        }
    }
    //end
    
    //MARK: AccessoryView Button pressed method
    @objc func donePressed() {
        delegate?.writingTextView?(self, didEndEditing: true)
        textView.resignFirstResponder()
    }
    //end
    
    //MARK: text view delegate methods
    func textViewDidBeginEditing(_ textView: UITextView) {
        placeHolder.isHidden = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if isEditable {
            checkTextAndSetPlaceHolder()
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if let position = trackingCursorPosition(), let boardHeight = keyBoardHeight {
            delegate?.writingTextView?(self, didChangeSelectionAt: position, keyBoardHeight: (boardHeight))
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
    private func requestTextData() -> TextInformation {
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
        return TextInformation(comment: comment, alignment: alignment)
    }
    
    private func checkTextAndSetPlaceHolder() {
        if isEditable {
            if textView.text == "" {
                placeHolder?.isHidden = false
            } else {
                placeHolder?.isHidden = true
            }
        } else {
            placeHolder?.isHidden = true
        }
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
        setOrRepositionBackgroundView()
        setOrRepositionTextView()
        setOrRepositionPlaceHolder()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRepositionBackgroundView()
        setOrRepositionTextView()
        setOrRepositionPlaceHolder()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrRepositionBackgroundView()
        setOrRepositionTextView()
        setOrRepositionPlaceHolder()
        backgroundColor = .goyaYellowWhite
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRepositionTextView()
        setOrRepositionPlaceHolder()
        backgroundColor = .goyaYellowWhite
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    //end

}
//end

//MARK: extentions
extension Giuk_ContentView_WritingTextView {
    var estimateArea_BackgroundView: CGRect {
        let width = bounds.width - (estimateMarginForTextView*2)
        let height = bounds.height - (estimateMarginForTextView*2)
        let size = CGSize(width: width, height: height)
        let originX = (bounds.width - width)/2
        let originY = (bounds.height - height)/2
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)//bounds
    }
    
    var estimateMargin_TextView: CGFloat {
        return 5
    }
    
    var estimateArea_TextView: CGRect {
        let width = estimateArea_BackgroundView.width - (estimateMargin_TextView * 2)
        let height = estimateArea_BackgroundView.height - (estimateMargin_TextView * 2)
        let size = CGSize(width: width, height: height)
        let origin = CGPoint(x: estimateMargin_TextView, y: estimateMargin_TextView)
        return CGRect(origin: origin, size: size)
    }
}
//end

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
