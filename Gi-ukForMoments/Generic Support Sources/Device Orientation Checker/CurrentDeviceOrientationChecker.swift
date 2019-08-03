//
//  CurrentDeviceRotationChecker.swift
//  ThreeDementionalFocus
//
//  Created by goya on 02/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import CoreMotion

@objc protocol CurrentDeviceRotationCheckerDelegate: class {
    @objc optional func currentDeviceRotationChecker(_ checker: CurrentDeviceOrientationChecker, updateRotation rotation: CurrentDeviceOrientationChecker.RotationState)
}

class CurrentDeviceOrientationChecker: NSObject {
    
    @objc enum RotationState: Int, CustomDebugStringConvertible {
        
        var debugDescription: String {
            switch self {
            case .faceDown:
                return "face down"
            case .faceUp:
                return "face up"
            case .landscapeLeft:
                return "landscapeLeft"
            case .landscapeRight:
                return "landscapeRight"
            case .portrait:
                return "portrait"
            case .reverse:
                return "reverse"
            default:
                return "error"
            }
        }
        
        case portrait
        case landscapeLeft
        case landscapeRight
        case reverse
        case faceUp
        case faceDown
        case error
    }
    
    var delegate: CurrentDeviceRotationCheckerDelegate?
    
    private var motionManager = CMMotionManager()
    
    var isCheckingContinuously: Bool = true
    
    var isCameraOrientationMode: Bool = true
    
    var state : RotationState? {
        didSet {
            if let currentState = state, currentState != oldValue {
                delegate?.currentDeviceRotationChecker?(self, updateRotation: currentState)
                if !isCheckingContinuously {
                    end()
                }
            }
        }
    }
    
    private func checkCurrentRotation(rotationInfo: CMAttitude) -> RotationState {
//        print("pitch : \(rotationInfo.pitch), roll : \(rotationInfo.roll)")
//        print("factor : \((rotationInfo.pitch - rotationInfo.roll.absValue).absValue)")
        
        if rotationInfo.pitch.absValue < 0.3 && rotationInfo.roll.absValue < 0.3 && rotationInfo.yaw.absValue < 0.3 {
            if isCameraOrientationMode {
                return state ?? RotationState.portrait
            } else {
                return RotationState.faceUp
            }
        } else {
            if rotationInfo.pitch < 0.2 && rotationInfo.roll <= -3 {
                if isCameraOrientationMode {
                    return state ?? RotationState.portrait
                } else {
                    return RotationState.faceDown
                }
            } else {
                if (1.5 - rotationInfo.pitch) < 0.4 {
                    return RotationState.portrait
                } else if rotationInfo.pitch < -1 {
                    return .reverse
                } else {
//                    if rotationInfo.roll < -2 || rotationInfo.roll > 2 {
//                        return state ?? RotationState.portrait
//                    } else {
                        let rotationRoll = rotationInfo.roll
                        let rotationPitch = rotationInfo.pitch
                        if rotationPitch < 0.1 {
                            if rotationRoll < 2.2 && rotationRoll > 0.9 {
                                return RotationState.landscapeRight
//                                if let currentSate = state {
//                                    if currentSate != .landscapeLeft {
//                                        return RotationState.landscapeRight
//                                    } else {
//                                        return state ?? RotationState.landscapeRight
//                                    }
//                                } else {
//                                    return RotationState.landscapeRight
//                                }
                            } else if rotationRoll > -2.2 && rotationRoll < -0.9 {
                                return RotationState.landscapeLeft
//                                if let currentSate = state {
//                                    if currentSate != .landscapeRight {
//                                        return RotationState.landscapeLeft
//                                    } else {
//                                        return state ?? RotationState.landscapeLeft
//                                    }
//                                } else {
//                                    return RotationState.landscapeLeft
//                                }
                            } else {
                                return state ?? RotationState.portrait
                            }
                        } else {
                            if rotationPitch > 0.8 && rotationRoll.absValue > 3 {
                                return RotationState.portrait
                            } else {
                                return state ?? RotationState.portrait
                            }
                        }
//                    }
                }
            }
        }
    }
    
    func check() {
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: OperationQueue.current!) { (motion, error) in
            if let rotationInfo = motion?.attitude {
                self.state = self.checkCurrentRotation(rotationInfo: rotationInfo)
            }
        }
    }
    
    func end() {
        motionManager.stopDeviceMotionUpdates()
    }
}
