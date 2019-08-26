//
//  PassCodeView.swift
//  Gi-ukForMoments
//
//  Created by goya on 20/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit



@objc protocol PassCodeViewDelegate {
    @objc optional func passCodeView(_ passcodeView: PassCodeView, mode: PassCodeModule.CodeMode, didUpdateSate state: PassCodeModule.PassCodeState, code: String)
}

class PassCodeView: UIView, NumberPadDelegate, PassCodeModuleDelegate
{
    weak var delegate: PassCodeViewDelegate?
    
    private var module = PassCodeModule() {
        didSet {
            layoutSubviews()
        }
    }
    
    var mode: PassCodeModule.CodeMode {
        get {
            return module.mode
        } set {
            module.mode = newValue
        }
    }
    
    var passCode: String! {
        get {
            return module.passCode
        } set {
            module.passCode = newValue
        }
    }
    
    weak var numberPad : NumberPad!
    
    weak var dotView: HiddenDotView!
    
    weak var noticeLable: UILabel!
    
    var itemColor: UIColor = UIColor.goyaFontColor {
        didSet {
            layoutSubviews()
        }
    }
    
    var itemBackgroundColor: UIColor = .goyaYellowWhite {
        didSet {
            layoutSubviews()
        }
    }
    
    func setNoticeLabel() {
        if noticeLable == nil {
            let newLabel = generateUIView(view: noticeLable, frame: noticeLableFrame)
            newLabel?.numberOfLines = 1
            noticeLable = newLabel
            noticeLable.setLabelAsSDStyleWithSpecificFontSize(type: .semiBold, fontSize: fontSize)
            noticeLable.textAlignment = .center
            noticeLable.textColor = itemColor.withAlphaComponent(0.9)
            addSubview(noticeLable)
        } else {
            noticeLable.setNewFrame(noticeLableFrame)
            noticeLable.setLabelAsSDStyleWithSpecificFontSize(type: .semiBold, fontSize: fontSize)
            noticeLable.textColor = itemColor.withAlphaComponent(0.9)
        }
    }
    
    func updateNoticeLabel(_ text: String) {
        noticeLable.text = text
    }
    
    func checkCurrentStateAndUpdateNoticeLabel(_ state: PassCodeModule.PassCodeState? = nil) {
        if state != .completed || state == nil {
            switch module.mode {
            case .checkingMode:
                updateNoticeLabel(DescribingSources.PasscodeView.passCode_Checking)
            case .inputMode:
                if module.passCode == nil {
                    updateNoticeLabel(DescribingSources.PasscodeView.passCode_NewPasscode)
                } else {
                    updateNoticeLabel(DescribingSources.PasscodeView.passCode_CheckNewPasscode)
                }
            }
        } else {
//            updateNoticeLabel("passcode completed")
        }
    }
    
    func setNumberPad() {
        if numberPad == nil {
            let newPad = generateUIView(view: numberPad, frame: numberPadFrame)
            numberPad = newPad
            numberPad.delegate = self
            numberPad.numberColor = itemColor.withAlphaComponent(0.9)
            addSubview(numberPad)
        } else {
            numberPad.setNewFrame(numberPadFrame)
            numberPad.numberColor = itemColor.withAlphaComponent(0.9)
        }
    }
    
    func setDotView() {
        if dotView == nil {
            let newDotView = generateUIView(view: dotView, frame: dotViewFrame)
            dotView = newDotView
            dotView.numberOfDots = module.requiredPassCodeLength
            dotView.dotColor = itemColor
            dotView.backgroundColor = .clear
            addSubview(dotView)
        } else {
            dotView.setNewFrame(dotViewFrame)
            dotView.dotColor = itemColor
            if dotView.numberOfDots != module.requiredPassCodeLength {
                dotView.numberOfDots = module.requiredPassCodeLength
            }
        }
    }
    
    //MARK: Delegate methods
    
    private var wrotedCode: String = ""
    
    func numberPad(_ numberPad: NumberPad, didUpdateNumberStringAs numberString: String) {
        module.appendNewCode(numberString)
    }
    
    func numberPad(_ numberPad: NumberPad, requestDeletion: Bool) {
        module.removeCodeAtLast()
    }
    
    func passCodeModule_UpdatingPassCode(passCodeModule: PassCodeModule, updatedAs code: String) {
        wrotedCode = code
        dotView.inputtedCount = code.count
    }
    
    func passCodeModule_CheckPassCodeState(passCodeModule: PassCodeModule, updatedAs state: PassCodeModule.PassCodeState) {
        switch state {
        case .completed:
            print("successed!")
            delegate?.passCodeView?(self, mode: module.mode, didUpdateSate: .completed, code: wrotedCode)
        case .failed:
            print("failed")
            delegate?.passCodeView?(self, mode: module.mode, didUpdateSate: .failed, code: wrotedCode)
        case .onGoing:
            print("onGoing")
            delegate?.passCodeView?(self, mode: module.mode, didUpdateSate: .onGoing, code: wrotedCode)
        }
        checkCurrentStateAndUpdateNoticeLabel(state)
    }
    //end
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNumberPad()
        setDotView()
        setNoticeLabel()
        checkCurrentStateAndUpdateNoticeLabel()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .goyaWhite
        setNumberPad()
        setDotView()
        setNoticeLabel()
        module.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .goyaWhite
        setNumberPad()
        setDotView()
        setNoticeLabel()
        module.delegate = self
    }
    
    convenience init(mode: PassCodeModule.CodeMode, passCode: String?) {
        self.init()
        self.mode = mode
        self.passCode = passCode
        if let requestedCode = passCode {
            self.module.requiredPassCodeLength = requestedCode.count
        }
    }
}

extension PassCodeView {
    
    fileprivate var bottomMargin: CGFloat {
        return 16
    }
    
    fileprivate var numberPadFrame: CGRect {
        let size = CGSize(width: bounds.width, height: (bounds.height - bottomMargin) * 0.4)
        let origin = CGPoint(x: 0, y: bounds.height - size.height - bottomMargin)
        return CGRect(origin: origin, size: size)
    }
    
    fileprivate var dotViewFrame: CGRect {
        let sizeWidth = bounds.width * 0.5
        let sizeHeight: CGFloat = 25
        let size = CGSize(width: sizeWidth, height: sizeHeight)
        let originX = (bounds.width - sizeWidth)/2
        let originY = ((bounds.height - numberPadFrame.height) - sizeHeight)/2
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)
    }
    
    fileprivate var fontSize: CGFloat {
        let size = valueBetweenMinAndMax(maxValue: 18, minValue: 12, mutableValue: dotViewFrame.minY * 0.15)
        return size
    }
    
    fileprivate var noticeLableFrame: CGRect {
        let sizeWidth = bounds.width * 0.8
        let sizeHeight: CGFloat = fontSize * 1.3
        let size = CGSize(width: sizeWidth, height: sizeHeight)
        let originX = (bounds.width - sizeWidth)/2
        let originY = (dotViewFrame.minY - sizeHeight)/2
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)
    }
}
