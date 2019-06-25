//
//  TextViewTestViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 09/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class TextViewTestViewController: UIViewController, Giuk_ContentView_WritingTextViewDelegate {
    
    @IBOutlet weak var textView: Giuk_ContentView_WritingTextView!
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        //textView.textContainer.lineBreakMode = .byTruncatingTail
        // Do any additional setup after loading the view.
        
//        let keyboardToolbar = UIToolbar()
//        keyboardToolbar.sizeToFit()
//        keyboardToolbar.backgroundColor = UIColor.clear
//        keyboardToolbar.barTintColor = UIColor.darkGray
//        
//        let flexibleSapce = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
//        
//        let doneButton = UIBarButtonItem(image: UIImage(named:"GiukIcon-Key"), style: .done, target: self, action: #selector(donePressed))
//        doneButton.tintColor = .goyaWhite
//        
//        keyboardToolbar.setItems([flexibleSapce, doneButton], animated: false)
//        
//        textView.textView.inputAccessoryView = keyboardToolbar
    }
    
    func writingTextView(_ writingView: Giuk_ContentView_WritingTextView, didChangeSelectionAt rect: CGRect, keyBoardHeight boardHeight: CGFloat) {
        let convertedPoint = self.view.convert(rect, from: view)
        print("converted - \(self.view.convert(rect, from: view))")
        print("convertedPoints maxY \(convertedPoint.maxY)")
        if convertedPoint.maxY > (self.view.frame.height - boardHeight) {
            print(true)
        }
    }
    
    @objc func donePressed() {
        textView.textView.resignFirstResponder()
    }

}
