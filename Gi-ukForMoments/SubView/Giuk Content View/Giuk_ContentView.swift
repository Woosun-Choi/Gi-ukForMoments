//
//  GiukWriteNewPageView.swift
//  Gi-ukForMoments
//
//  Created by goya on 25/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

struct GiukContentFrameFactors {
    static var contentMinimumMargin: (dX: CGFloat, dY: CGFloat) {
        return (16,8)
    }
}

class Giuk_ContentView: UIView {
    
}

extension Giuk_ContentView {
    var requiredRatio: CGFloat {
        let width: CGFloat = 3
        let height: CGFloat = 4
        return width/height
    }
    
    var requierAreaSizeForPresentingContent: CGSize {
        let width = frame.width
        let height = width/requiredRatio
        return CGSize(width: width, height: height)
    }
    
    var topContainerAreaSize: CGSize {
        let width = frame.width
        let height: CGFloat = frame.width*0.08 + (GiukContentFrameFactors.contentMinimumMargin.dY*2)
//        let height = max((frame.height - requierAreaSizeForPresentingContent.height)*0.384, 45)
        return CGSize(width: width, height: height)
    }
    
    var bottomContainerAreaSize: CGSize {
        let width = frame.width
        let height = frame.height - requierAreaSizeForPresentingContent.height - topContainerAreaSize.height
        return CGSize(width: width, height: height)
    }
    
    var topContainerAreaFrame: CGRect {
        let originX: CGFloat = 0
        let originY: CGFloat = 0
        return CGRect(origin: CGPoint(x: originX, y: originY), size: topContainerAreaSize)
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
    
    
}
