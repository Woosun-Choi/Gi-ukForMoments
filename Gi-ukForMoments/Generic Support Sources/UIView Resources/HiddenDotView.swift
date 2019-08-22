//
//  DotView.swift
//  Gi-ukForMoments
//
//  Created by goya on 20/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class HiddenDotView: UIView {
    
    var dotColor: UIColor = .goyaFontColor {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var inputtedCount: Int = 0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var numberOfDots: Int = 4
    
    var DotGrid: [CGRect]? {
        return try? ButtonGridCalculator.requestButtonFrames(inFrame: bounds, numberOfButtons: numberOfDots, buttonType: .square, alignmentStyle: .edgeAligned)
    }
    
    var paths: [UIBezierPath] {
        if let grids = DotGrid {
            var pathArray = [UIBezierPath]()
            for grid in grids {
                let path = UIBezierPath(ovalIn: grid)
                pathArray.append(path)
            }
            return pathArray
        } else {
            return []
        }
    }
    
    override func draw(_ rect: CGRect) {
        for path in paths {
            if let pathIndex = paths.firstIndex(of: path) {
                if pathIndex <= (inputtedCount - 1) {
                    dotColor.setFill()
                    path.fill()
                } else {
                    dotColor.withAlphaComponent(0.4).setFill()
                    path.fill()
                }
            }
        }
    }
}
