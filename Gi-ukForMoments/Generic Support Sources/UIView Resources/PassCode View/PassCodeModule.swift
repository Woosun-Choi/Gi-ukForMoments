//
//  PassCodeModule.swift
//  Gi-ukForMoments
//
//  Created by goya on 21/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation

@objc protocol PassCodeModuleDelegate {
    func passCodeModule_UpdatingPassCode(passCodeModule: PassCodeModule, updatedAs code: String)
    func passCodeModule_CheckPassCodeState(passCodeModule: PassCodeModule, updatedAs state: PassCodeModule.PassCodeState)
}

class PassCodeModule: NSObject {
    
    weak var delegate: PassCodeModuleDelegate?
    
    @objc enum CodeMode: Int {
        case inputMode, checkingMode
    }
    
    @objc enum PassCodeState: Int {
        case failed, onGoing, completed
    }
    
    var requiredPassCodeLength = 4
    
    var mode: CodeMode = .inputMode
    
    var passCode: String?
    
    var prepareForCheckingPasscode: String? {
        didSet {
            if let prepared = self.prepareForCheckingPasscode {
                checkCodeMatched(with: prepared)
            }
        }
    }
    
    var userInputtingCode: String = "" {
        didSet {
            delegate?.passCodeModule_UpdatingPassCode(passCodeModule: self, updatedAs: userInputtingCode)
            prepareForCheckingPasscode = userInputtingCode
        }
    }
    
    private func checkCodeMatched(with code: String) {
        if code.count == requiredPassCodeLength {
            let checkResult = matchingSateWithCode(code)
            actionWithMathcingState(checkResult)
        }
    }
    
    private func matchingSateWithCode(_ code: String) -> PassCodeState {
        switch mode {
        case .inputMode:
            if passCode == nil {
                passCode = code
                return .onGoing
            } else {
                if passCode == code {
                    return .completed
                } else {
                    return .failed
                }
            }
        case .checkingMode:
            if passCode! == code {
                return .completed
            } else {
                return .failed
            }
        }
    }
    
    private func actionWithMathcingState(_ state: PassCodeState) {
        switch state {
        case .completed:
            break
        case .failed:
            userInputtingCode = ""
        case .onGoing:
            userInputtingCode = ""
        }
        delegate?.passCodeModule_CheckPassCodeState(passCodeModule: self, updatedAs: state)
    }
    
    func appendNewCode(_ code: String) {
        if userInputtingCode.count < requiredPassCodeLength {
            userInputtingCode += code
        }
    }
    
    func removeCodeAtLast() {
        if userInputtingCode.count > 0 {
            userInputtingCode.removeLast()
        }
    }
}
