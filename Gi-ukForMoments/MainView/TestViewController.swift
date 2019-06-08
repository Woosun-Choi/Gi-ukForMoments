//
//  TestViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 30/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class TestViewController: Giuk_OpenFromFrame_ViewController {
    
    weak var contentView: Giuk_ContentView_WriteSection!

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentView()
        setCloseButton()
        // Do any additional setup after loading the view.
    }
    
    func setContentView() {
        if contentView == nil {
            let view = generateUIView(view: contentView, origin: safeAreaRelatedAreaFrame.origin, size: safeAreaRelatedAreaFrame.size)
            contentView = view
            self.view?.addSubview(contentView)
        } else {
            contentView.setNewFrame(safeAreaRelatedAreaFrame)
        }
    }
    
    override func setCloseButton() {
        let originX = GiukContentFrameFactors.contentMinimumMargin.dX
        let originY = (contentView.topContainer.frame.height - closeButtonSize.height)/2
        if closeButton == nil {
            let newButton = generateUIView(view: closeButton, origin: CGPoint(x: originX, y: originY), size: closeButtonSize)
            newButton?.setTitle("-", for: .normal)
            newButton?.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
            newButton?.backgroundColor = .green
            closeButton = newButton
            contentView.topContainer.addSubview(closeButton)
            contentView.topContainer.bringSubviewToFront(closeButton)
        } else {
            closeButton.setNewFrame(CGRect(x: originX, y: originY, width: closeButtonSize.width, height: closeButtonSize.height))
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCloseButton()
        setContentView()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
