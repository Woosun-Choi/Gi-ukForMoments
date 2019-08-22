//
//  GridForSquares.swift
//  Gi-ukForMoments
//
//  Created by goya on 20/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

struct GridSystemForSquares {
    typealias marginInsets = (top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat)
    
    enum GridSystemError: Error {
        case notEnoughSpaceForDraw
    }
    
    static func gridForSquares(targetFrame: CGRect ,numberOFButtonsInHorizon: Int, numberOFButtonsInVertical: Int, minSpace: CGFloat = 5, marginInset: marginInsets = (5,5,5,5)) -> [CGRect]? {
        
        let targetAreaSize = targetFrame.size
        let requieredMinWidth = marginInset.left + marginInset.right + (1*numberOFButtonsInHorizon).cgFloat + (minSpace * (numberOFButtonsInHorizon - 1).cgFloat)
        let requieredMinHeight = marginInset.top + marginInset.bottom + (1*numberOFButtonsInVertical).cgFloat + (minSpace * (numberOFButtonsInVertical - 1).cgFloat)
        let expectedWidth = targetAreaSize.width - (marginInset.left + marginInset.right) - (minSpace * (numberOFButtonsInHorizon - 1).cgFloat)
        let exprectedHeight = targetAreaSize.height - (marginInset.top + marginInset.bottom) - (minSpace * (numberOFButtonsInVertical - 1).cgFloat)
        
        if expectedWidth < requieredMinWidth || exprectedHeight < requieredMinHeight {
            return nil
        } else {
            var rects = [CGRect]()
            
            let requestedButtonsCount = numberOFButtonsInVertical * numberOFButtonsInHorizon
            let expectedButtonSizeWidth = expectedWidth/numberOFButtonsInHorizon.cgFloat
            let expectedButtonSizeHeight = exprectedHeight/numberOFButtonsInVertical.cgFloat
            let expectedButtonSize = CGSize(width: expectedButtonSizeWidth, height: expectedButtonSizeHeight)
            var buttonOrigin = CGPoint(x: marginInset.left, y: marginInset.top)
            
            for _ in 0..<requestedButtonsCount {
                let newRect = CGRect(origin: buttonOrigin, size: expectedButtonSize)
                rects.append(newRect)
                if newRect.maxX + minSpace > expectedWidth {
                    buttonOrigin.x = marginInset.left
                    buttonOrigin.y += (expectedButtonSizeHeight + minSpace)
                } else {
                    buttonOrigin.x = (newRect.maxX + minSpace)
                }
            }
            
            return rects
        }
    }
}
