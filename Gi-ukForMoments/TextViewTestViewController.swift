//
//  TextViewTestViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 09/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class TextViewTestViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        textView.textContainer.maximumNumberOfLines = 4
        textView.textContainer.lineBreakMode = .byTruncatingTail
        // Do any additional setup after loading the view.
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
//        let newLines = text.components(separatedBy: CharacterSet.newlines)
//        let linesAfterChange = existingLines.count + newLines.count - 1
//        print("existingLines = \(existingLines)")
//        print("newLines = \(newLines)")
//        if(text == "\n") {
//            return linesAfterChange <= textView.textContainer.maximumNumberOfLines
//        }
        
        //?? not sure
        let endposition: UITextPosition = textView.endOfDocument
        let position = textView.caretRect(for: endposition)

        if position.maxX > textView.bounds.maxX {
            print("false")
            return false
        }
        //end
        
        if let cursorposition = trackingCursorPosition() {
            
            if marginForText == nil && marginForTextLine == nil {
                marginForText = cursorposition.origin.x
                marginForTextLine = cursorposition.origin.y
            }
            
            if let marginForLine = marginForTextLine, lineBreakSize == nil, cursorposition.origin.y > marginForLine {
                lineBreakSize = cursorposition.origin.y - marginForLine
            }
            
            print(lineBreakSize)
            if let breakSize = lineBreakSize, let textMargin = marginForText {
                if cursorposition.origin.y >= ((breakSize * CGFloat(textView.textContainer.maximumNumberOfLines - 1) + textMargin)) {
                    if text == ("\n") {
                        return false
                    }
                }
            }
        }
        
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        return numberOfChars <= 100 // 30 characters limit
    }
    
    var marginForText: CGFloat?
    var marginForTextLine: CGFloat?
    var lineBreakSize: CGFloat?
    
    func trackingCursorPosition() -> CGRect? {
        if let selectedRange = textView.selectedTextRange {
            let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
            if let curpo = textView.position(from: textView.beginningOfDocument, offset: cursorPosition) {
                //position : position of charactor in textView
                let position = textView.caretRect(for: curpo)
                //poC : posotion of charactor in view
                let poC = textView.convert(position, to: view)
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

}
