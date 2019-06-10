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
        textView.textContainer.maximumNumberOfLines = 6
        textView.textContainer.lineBreakMode = .byTruncatingTail
        // Do any additional setup after loading the view.
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        
        if(text == "\n") {
            return linesAfterChange <= textView.textContainer.maximumNumberOfLines
        }
        
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        
        return numberOfChars <= 100 // 30 characters limit
    }

}
