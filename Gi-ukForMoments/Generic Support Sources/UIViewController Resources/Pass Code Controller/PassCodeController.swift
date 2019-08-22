//
//  PassCodeController.swift
//  Gi-ukForMoments
//
//  Created by goya on 21/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class PassCodeController: Giuk_OpenFromFrame_ViewController, PassCodeViewDelegate {
    
    weak var passCodeView: PassCodeView!
    
    private var transitionDelegate = FadeInTransitioningDelegate()
    
    private(set) var mode: PassCodeModule.CodeMode!
    
    private(set) var code: String!
    
    private var _passCodeViewFrame : CGRect {
        if let targetFrame = passCodeViewFrame {
            return targetFrame
        } else {
            return safeAreaRelatedAreaFrame
        }
    }
    
    var isSelfDestructive: Bool = false
    
    var passCodeViewFrame : CGRect? {
        didSet {
            viewDidLayoutSubviews()
        }
    }
    
    var itemColor: UIColor? {
        get {
            return passCodeView?.itemColor
        } set {
            if let newColor = newValue {
                passCodeView?.itemColor = newColor
                viewDidLayoutSubviews()
            }
        }
    }
    
    var itemBackgroundColor: UIColor? {
        get {
            return passCodeView?.itemBackgroundColor
        } set {
            if let newColor = newValue {
                passCodeView?.itemBackgroundColor = newColor
                viewDidLayoutSubviews()
            }
        }
    }
    
    private var completeAction: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPassCodeView(mode: mode, code: code)
        view.backgroundColor = itemBackgroundColor
        passCodeView.backgroundColor = itemBackgroundColor
        if !isSelfDestructive {
            closeButton.isHidden = true
        } else {
            closeButton.tintColor = itemColor
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setPassCodeView(mode: mode, code: code)
    }
    
    private func setPassCodeView(mode: PassCodeModule.CodeMode, code: String?) {
        if passCodeView == nil {
            let newCodeView = PassCodeView(mode: mode, passCode: code)
            newCodeView.frame = _passCodeViewFrame
            passCodeView = newCodeView
            passCodeView.delegate = self
            view.addSubview(passCodeView)
        } else {
            passCodeView.setNewFrame(_passCodeViewFrame)
        }
    }
    
    func passCodeView(_ passcodeView: PassCodeView, mode: PassCodeModule.CodeMode, didUpdateSate state: PassCodeModule.PassCodeState, code: String) {
        if state == .completed {
            UIView.animate(withDuration: 0.25, delay: 0.2, options: [], animations: {
                self.view.subviews.forEach { $0.alpha = 0}
            }) { (finished) in
                self.dismiss(animated: true) {
                    [unowned self] in
                    if let completion = self.completeAction {
                        completion(code)
                    }
                }
            }
        }
    }
    
    func addCompleteAction(_ action: @escaping ((String) -> Void)) {
        self.completeAction = action
    }
    
    convenience init(mode: PassCodeModule.CodeMode, passcode: String = "") {
        self.init()
        self.mode = mode
        if mode == .checkingMode {
            self.code = passcode
        }
        self.transitioningDelegate = transitionDelegate
        self.modalPresentationStyle = .overCurrentContext
    }
}
