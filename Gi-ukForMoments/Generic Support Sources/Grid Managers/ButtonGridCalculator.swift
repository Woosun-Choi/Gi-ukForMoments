//
//  ButtonGridCalculator.swift
//  Gi-ukForMoments
//
//  Created by goya on 19/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

struct ButtonGridCalculator {
    
    enum buttonSizeType {
        case full
        case square
    }
    
    enum AlignmentStyle {
        case positiveAligned
        case negativeAligned
        case edgeAligned
        case centered
    }
    
    typealias ButtonMarginInset = (top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat)
    
    enum ButtonGridError: Error {
        case notEnoughSpaceForDrawing
    }
    
    static func requestButtonFrames(inView: UIView, numberOfButtons: Int, buttonType: buttonSizeType, alignmentStyle: AlignmentStyle, minSpacing: CGFloat = 5, marginInset: ButtonMarginInset = (5,5,5,5)) throws -> [CGRect] {
        
        do {
            if let result = try? requestButtonFrames(inFrame: inView.frame, numberOfButtons: numberOfButtons, buttonType: buttonType, alignmentStyle: alignmentStyle, minSpacing: minSpacing, marginInset: marginInset) {
                return result
            } else {
                throw ButtonGridError.notEnoughSpaceForDrawing
            }
        } catch let error {
            throw error
        }
    }
    
    static func requestButtonFrames(inFrame: CGRect, numberOfButtons: Int, buttonType: buttonSizeType, alignmentStyle: AlignmentStyle, minSpacing: CGFloat = 5, marginInset: ButtonMarginInset = (5,5,5,5)) throws -> [CGRect] {
        
        var frames = [CGRect]()
        
        let ownerFrame = inFrame
        
        var isHorizontal: Bool {
            return (ownerFrame.width / ownerFrame.height > 1) ? true : false
        }
        
        var prefferAreaSizeWidth: CGFloat {
            let expectedSizeWidth = ownerFrame.width - marginInset.left - marginInset.right
            if isHorizontal {
                return (expectedSizeWidth > (1*numberOfButtons).cgFloat + (CGFloat(numberOfButtons - 1) * minSpacing)) ? expectedSizeWidth : 0
            } else {
                return (expectedSizeWidth > (1*numberOfButtons).cgFloat) ? expectedSizeWidth : 0
            }
        }
        
        var prefferAreaSizeHeight: CGFloat {
            let expectedSizeHeight = ownerFrame.height - marginInset.top - marginInset.bottom
            if isHorizontal {
                return (expectedSizeHeight > (1*numberOfButtons).cgFloat) ? expectedSizeHeight : 0
            } else {
                return (expectedSizeHeight > (1*numberOfButtons).cgFloat + (CGFloat(numberOfButtons - 1) * minSpacing)) ? expectedSizeHeight : 0
            }
        }
        
        let prefferedAreaSize = CGSize(width: prefferAreaSizeWidth, height: prefferAreaSizeHeight)
        
        if prefferedAreaSize.width == 0 || prefferedAreaSize.height == 0 {
            throw ButtonGridError.notEnoughSpaceForDrawing
        }
        
        var expectedSizeFactor: CGFloat {
            if isHorizontal {
                return prefferedAreaSize.width - (CGFloat(numberOfButtons - 1) * minSpacing)
            } else {
                return prefferedAreaSize.height - (CGFloat(numberOfButtons - 1) * minSpacing)
            }
        }
        
        var requiredButtonSize: CGSize {
            
            var expectedEachSize = expectedSizeFactor/CGFloat(numberOfButtons)
            var fixedSizeFactor: CGFloat = 0
            
            if isHorizontal {
                if buttonType == .square {
                    while expectedEachSize > prefferedAreaSize.height {
                        expectedEachSize -= 0.1
                    }
                    fixedSizeFactor = expectedEachSize
                } else {
                    fixedSizeFactor = prefferedAreaSize.height
                }
                return CGSize(width: expectedEachSize, height: fixedSizeFactor)
            } else {
                if buttonType == .square {
                    while expectedEachSize > prefferedAreaSize.width {
                        expectedEachSize -= 0.1
                    }
                    fixedSizeFactor = expectedEachSize
                } else {
                    fixedSizeFactor = prefferedAreaSize.width
                }
                return CGSize(width: fixedSizeFactor, height: expectedEachSize)
            }
        }
        
        let startOrigin = CGPoint(x: marginInset.left, y: marginInset.top)
        
        switch alignmentStyle {
        case .positiveAligned:
            if isHorizontal {
                var originX: CGFloat = startOrigin.x
                let originY = (prefferedAreaSize.height - requiredButtonSize.height)/2 + marginInset.top
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originX = newRect.maxX + minSpacing
                }
            } else {
                let originX: CGFloat = (prefferedAreaSize.width - requiredButtonSize.width).absValue/2 + marginInset.left
                var originY: CGFloat = startOrigin.y
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originY = newRect.maxY + minSpacing
                }
            }
        case .negativeAligned:
            if isHorizontal {
                var originX: CGFloat = prefferedAreaSize.width - requiredButtonSize.width + marginInset.left
                let originY: CGFloat = (prefferedAreaSize.height - requiredButtonSize.height)/2 + marginInset.top
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originX = newRect.minX - (minSpacing + requiredButtonSize.width)
                }
            } else {
                let originX: CGFloat = (prefferedAreaSize.width - requiredButtonSize.width)/2 + marginInset.left
                var originY: CGFloat = prefferedAreaSize.height - (requiredButtonSize.height) + marginInset.top
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originY = newRect.minY - (minSpacing + requiredButtonSize.height)
                }
            }
        case .edgeAligned:
            
            var devidingFactor: CGFloat {
                if (numberOfButtons - 1) > 0 {
                    return CGFloat(numberOfButtons - 1)
                } else {
                    return 1
                }
            }
            
            var requiredMarginForEach: CGFloat {
                if isHorizontal {
                    return (prefferedAreaSize.width - (requiredButtonSize.width * CGFloat(numberOfButtons)))/devidingFactor
                } else {
                    return (prefferedAreaSize.height - (requiredButtonSize.height * CGFloat(numberOfButtons)))/devidingFactor
                }
            }
            
            if isHorizontal {
                if requiredMarginForEach == 0 {
                    let originX: CGFloat = (prefferedAreaSize.width - requiredButtonSize.width)/2 + marginInset.left
                    let originY: CGFloat = (prefferedAreaSize.height - requiredButtonSize.height)/2 + marginInset.top
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                } else {
                    var originX: CGFloat = startOrigin.x
                    let originY: CGFloat = (prefferedAreaSize.height - requiredButtonSize.height)/2 + marginInset.top
                    for _ in 0...(numberOfButtons - 1) {
                        let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                        frames.append(newRect)
                        originX = newRect.maxX + requiredMarginForEach
                    }
                }
            } else {
                if requiredMarginForEach == 0 {
                    let originX: CGFloat = (prefferedAreaSize.width - requiredButtonSize.width)/2 + marginInset.left
                    let originY: CGFloat = (prefferedAreaSize.height - requiredButtonSize.height)/2 + marginInset.top
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                } else {
                    let originX: CGFloat = (prefferedAreaSize.width - requiredButtonSize.width)/2
                    var originY: CGFloat = startOrigin.y
                    for _ in 0...(numberOfButtons - 1) {
                        let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                        frames.append(newRect)
                        originY = newRect.maxY + requiredMarginForEach
                    }
                }
            }
            
        case .centered:
            var actualRequiredAreaSizeFactor: CGFloat {
                if isHorizontal {
                    return (requiredButtonSize.width * CGFloat(numberOfButtons)) + (CGFloat(numberOfButtons - 1) * minSpacing)
                } else {
                    return (requiredButtonSize.height * CGFloat(numberOfButtons)) + (CGFloat(numberOfButtons - 1) * minSpacing)
                }
            }
            
            if isHorizontal {
                var originX: CGFloat = (prefferedAreaSize.width - actualRequiredAreaSizeFactor)/2 + marginInset.left
                let originY: CGFloat = (prefferedAreaSize.height - requiredButtonSize.height)/2 + marginInset.top
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originX = newRect.maxX + minSpacing
                }
            } else {
                let originX: CGFloat = (prefferedAreaSize.width - requiredButtonSize.width)/2 + marginInset.left
                var originY: CGFloat = (prefferedAreaSize.height - actualRequiredAreaSizeFactor)/2 + marginInset.top
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originY = newRect.maxY + minSpacing
                }
            }
        }
        
        return frames
    }
    
}
