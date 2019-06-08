//
//  ButtonGenerator.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

struct ButtonGridManager {
    
    enum buttonSizeCase {
        case full
        case square
    }
    
    enum AlignmentStyle {
        case positiveAligned
        case negativeAligned
        case edgeAligned
        case centered
    }
    
    var displayingInView: Bool = true
    
    var alignmentStyle: AlignmentStyle = .positiveAligned
    
    var fillStyle: buttonSizeCase = .square
    
    var targetFrame: CGRect = CGRect.zero
    
    var minSpacing: CGFloat = 0
    
    var numberOfButtons: Int = 0
    
    mutating func updateFrameInformation(targetFrame: CGRect, minSpacing: CGFloat, alignment: AlignmentStyle) {
        self.targetFrame = targetFrame
        self.minSpacing = minSpacing
        self.alignmentStyle = alignment
    }
    
    mutating func requestButtonFramesWith(frame: CGRect, minSpace: CGFloat, numberOfButtons: Int) -> [CGRect] {
        self.targetFrame = frame
        self.minSpacing = minSpace
        self.numberOfButtons = numberOfButtons
        return requestButtonFrames()
    }
    
    func requestButtonFrames() -> [CGRect] {
        var frames = [CGRect]()
        switch alignmentStyle {
        case .positiveAligned:
            if isHorizontal {
                var originX: CGFloat = startOriginX
                let originY = (targetFrame.height - requiredButtonSize.height)/2
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originX = newRect.maxX + minSpacing
                }
            } else {
                let originX: CGFloat = (targetFrame.width - requiredButtonSize.width).absValue/2
                var originY: CGFloat = startOriginY
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originY = newRect.maxY + minSpacing
                }
            }
        case .negativeAligned:
            if isHorizontal {
                var originX: CGFloat = targetFrame.width - requiredButtonSize.width
                let originY: CGFloat = (targetFrame.height - requiredButtonSize.height)/2
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originX = newRect.minX - (minSpacing + requiredButtonSize.width)
                }
            } else {
                let originX: CGFloat = (targetFrame.width - requiredButtonSize.width)/2
                var originY: CGFloat = targetFrame.height - (requiredButtonSize.height)
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
                    return (targetFrame.width - (requiredButtonSize.width * CGFloat(numberOfButtons)))/devidingFactor
                } else {
                    return (targetFrame.height - (requiredButtonSize.height * CGFloat(numberOfButtons)))/devidingFactor
                }
            }
            
            if isHorizontal {
                if requiredMarginForEach == 0 {
                    let originX: CGFloat = (targetFrame.width - requiredButtonSize.width)/2
                    let originY: CGFloat = (targetFrame.height - requiredButtonSize.height)/2
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                } else {
                    var originX: CGFloat = startOriginX
                    let originY: CGFloat = (targetFrame.height - requiredButtonSize.height)/2
                    for _ in 0...(numberOfButtons - 1) {
                        let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                        frames.append(newRect)
                        originX = newRect.maxX + requiredMarginForEach
                    }
                }
            } else {
                if requiredMarginForEach == 0 {
                    let originX: CGFloat = (targetFrame.width - requiredButtonSize.width)/2
                    let originY: CGFloat = (targetFrame.height - requiredButtonSize.height)/2
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                } else {
                    let originX: CGFloat = (targetFrame.width - requiredButtonSize.width)/2
                    var originY: CGFloat = startOriginY
                    for _ in 0...(numberOfButtons - 1) {
                        let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                        frames.append(newRect)
                        originY = newRect.maxY + requiredMarginForEach
                    }
                }
            }
            
        case .centered:
            if isHorizontal {
                var originX: CGFloat = (targetFrame.width - actualRequiredAreaSizeFactor)/2
                let originY: CGFloat = (targetFrame.height - requiredButtonSize.height)/2
                for _ in 0...(numberOfButtons - 1) {
                    let newRect = CGRect(origin: CGPoint(x: originX, y: originY), size: requiredButtonSize)
                    frames.append(newRect)
                    originX = newRect.maxX + minSpacing
                }
            } else {
                let originX: CGFloat = (targetFrame.width - requiredButtonSize.width)/2
                var originY: CGFloat = (targetFrame.height - actualRequiredAreaSizeFactor)/2
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

extension ButtonGridManager {
    
    private var startOriginX: CGFloat {
        if displayingInView {
            return 0
        } else {
            return targetFrame.origin.x
        }
    }
    
    private var startOriginY: CGFloat {
        if displayingInView {
            return 0
        } else {
            return targetFrame.origin.y
        }
    }
    
    private var isHorizontal: Bool {
        if targetFrame.width / targetFrame.height > 1 {
            return true
        } else {
            return false
        }
    }
    
    private var expectedSizeFactor: CGFloat {
        if isHorizontal {
            return targetFrame.width - (CGFloat(numberOfButtons - 1) * minSpacing)
        } else {
            return targetFrame.height - (CGFloat(numberOfButtons - 1) * minSpacing)
        }
    }
    
    private var requiredButtonSize: CGSize {
        
        var expectedEachSize = expectedSizeFactor/CGFloat(numberOfButtons)
        var fixedSizeFactor: CGFloat = 0
        
        if isHorizontal {
            if fillStyle == .square {
                while expectedEachSize > targetFrame.height {
                    expectedEachSize -= 0.1
                }
                fixedSizeFactor = expectedEachSize
            } else {
                fixedSizeFactor = targetFrame.height
            }
            return CGSize(width: expectedEachSize, height: fixedSizeFactor)
        } else {
            if fillStyle == .square {
                while expectedEachSize > targetFrame.width {
                    expectedEachSize -= 0.1
                }
                fixedSizeFactor = expectedEachSize
            } else {
                fixedSizeFactor = targetFrame.width
            }
            return CGSize(width: fixedSizeFactor, height: expectedEachSize)
        }
    }
    
    private var actualRequiredAreaSizeFactor: CGFloat {
        if isHorizontal {
            return (requiredButtonSize.width * CGFloat(numberOfButtons)) + (CGFloat(numberOfButtons - 1) * minSpacing)
        } else {
            return (requiredButtonSize.height * CGFloat(numberOfButtons)) + (CGFloat(numberOfButtons - 1) * minSpacing)
        }
    }
}
