//
//  Giuk_OpenFromFrame_ViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 08/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class Giuk_OpenFromFrame_ViewController: ContentUIViewController, FrameTransitionDataSource {

    weak var closeButton: UIButton_WithIdentifire!
    
    var closingFunction: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCloseButton()
        view.backgroundColor = .goyaFontColor
    }
    
    func setCloseButton() {
        let originX = GiukContentFrameFactors.contentMinimumMargin.dX
        let originY:CGFloat = topContainerAreaFrame.minY + ((topContainerAreaSize.height - closeButtonSize.height)/2)
        if closeButton == nil {
            let newButton = generateUIView(view: closeButton, origin: CGPoint(x: originX, y: originY), size: closeButtonSize)
            newButton?.imageView?.contentMode = .scaleAspectFit
            newButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Close)?.withRenderingMode_alwaysTemplate, for: .normal)
            newButton?.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
            newButton?.backgroundColor = .clear
            newButton?.tintColor = .goyaYellowWhite
            closeButton = newButton
            view.addSubview(closeButton)
        } else {
            closeButton.setNewFrame(CGRect(x: originX, y: originY, width: closeButtonSize.width, height: closeButtonSize.height))
            view.bringSubviewToFront(closeButton)
        }
    }
    
    @objc func closeButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.subviews.forEach { $0.alpha = 0}
        }) { (finished) in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: dismiss animation setting - frametransition datasource
    func initialAction_FromViewController(_ viewController: UIViewController) {
        closeButton.alpha = 0
    }
    
    func finalAction_ToViewController(_ viewController: UIViewController) {
        closingFunction?()
    }
    //end
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCloseButton()
    }
    
    deinit {
        closingFunction = nil
        print("content frame controller has gone")
    }
}

extension Giuk_OpenFromFrame_ViewController {
    var requiredRatio: CGFloat {
        let width: CGFloat = 3
        let height: CGFloat = 4
        return width/height
    }
    
    var requierAreaSizeForPresentingContent: CGSize {
        let width = safeAreaRelatedAreaFrame.width
        let height = width/requiredRatio
        return CGSize(width: width, height: height)
    }
    
    var topContainerAreaSize: CGSize {
        let width = safeAreaRelatedAreaFrame.width
        let height: CGFloat = view.frame.width*0.08 + (GiukContentFrameFactors.contentMinimumMargin.dY*2)
        return CGSize(width: width, height: height)
    }
    
    var bottomContainerAreaSize: CGSize {
        let width = view.frame.width
        let height = safeAreaRelatedAreaFrame.height - requierAreaSizeForPresentingContent.height - topContainerAreaSize.height
        return CGSize(width: width, height: height)
    }
    
    var topContainerAreaFrame: CGRect {
        let originX: CGFloat = 0
        let originY: CGFloat = safeAreaRelatedAreaFrame.minY
        return CGRect(origin: CGPoint(x: originX, y: originY), size: topContainerAreaSize)
    }
    
    var fullContentFrame: CGRect {
        let width = view.bounds.width
        let height = safeAreaRelatedAreaFrame.height - topContainerAreaSize.height
        let size = CGSize(width: width, height: height)
        let originX: CGFloat = 0
        let originY = topContainerAreaFrame.maxY
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)
    }
    
    var contentAreaFrame: CGRect {
        let originX: CGFloat = 0
        let originY: CGFloat = topContainerAreaFrame.maxY
        return CGRect(origin: CGPoint(x: originX, y: originY), size: requierAreaSizeForPresentingContent)
    }
    
    var bottomContainerAreaFrame: CGRect {
        let originX: CGFloat = 0
        let originY: CGFloat = contentAreaFrame.maxY
        return CGRect(origin: CGPoint(x: originX, y: originY), size: bottomContainerAreaSize)
    }
    
    var fullContentHeight: CGFloat {
        return safeAreaRelatedAreaFrame.maxY - safeAreaRelatedAreaFrame.minY
    }
    
    var fullContentOrigin: CGPoint {
        return CGPoint(x: 0, y: safeAreaRelatedAreaFrame.minY)
    }
    
    var closeButtonSize: CGSize {
        let width = (view.frame.width * 0.08).clearUnderDot
        let height = width
        return CGSize(width: width, height: height)
    }
}
