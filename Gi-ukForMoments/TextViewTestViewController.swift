//
//  TextViewTestViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 09/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class TextViewTestViewController: UIViewController, TagGeneratorDelegate {
    
    @IBOutlet weak var tagGenerator: TagGenerator!
    
    var strings = ["apple","board","comment","deny","elevator","fortune","garden","happyness","orange","purple","apple","board","comment","deny","elevator","fortune","garden","happyness","orange","purple","apple","board","comment","deny","elevator","fortune","garden","happyness","orange","purple","apple","board","comment","deny","elevator","fortune","garden","happyness","orange","purple"]
    
    var strings2 = ["a","b","c","d"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagGenerator.delegate = self
        tagGenerator.tagManager = TagInformation(alreadyAdded: strings2, library: strings)
        tagGenerator.reloadData()
    }
    
    func tagGenerator_DidEndEditNewTag(_ tagGenerator: TagGenerator, senderTextField: UITextField, text: String?) {
        print(text)
    }

}
