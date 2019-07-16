//
//  RadiantLayer.swift
//  Gi-ukForMoments
//
//  Created by goya on 11/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class RadialGradientLayer: CALayer {
    
    override init(){
        super.init()
        needsDisplayOnBoundsChange = true
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init()
        needsDisplayOnBoundsChange = true
    }
    
    init(colors:[UIColor]){
        self.colors = colors
        
        super.init()
        
    }
    
    var center:CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    var radius:CGFloat {
        return sqrt((center.x * center.x) + (center.y * center.y))
    }
    
    var cgColors: [CGColor] {
        return colors.map({ (color) -> CGColor in
            return color.cgColor
        })
    }
    
    var options : CGGradientDrawingOptions = CGGradientDrawingOptions(arrayLiteral: .drawsAfterEndLocation)
    var colors:[UIColor] = [UIColor.goyaYellowWhite, UIColor.goyaSemiBlackColor.withAlphaComponent(0.15)]
    
    override func draw(in ctx: CGContext) {
        ctx.saveGState()
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let locations:[CGFloat] = [0.5, 1]
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: cgColors as CFArray, locations: locations) else {
            return
        }
        
        ctx.drawRadialGradient(gradient, startCenter: center, startRadius: 0.0, endCenter: center, endRadius: radius, options: options)
    }
    
}
