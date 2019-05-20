//
//  AnalogTypeLcdItemView.swift
//  LifeTuner
//
//  Created by goya on 16/12/2018.
//  Copyright © 2018 goya. All rights reserved.
//

import UIKit

//@IBDesignable

class AnalogTypeLcdItemView: UIView {
    
    @IBInspectable var itemColor: UIColor = UIColor.gray { didSet {setNeedsDisplay()} }
    
    var isRounded = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var path: UIBezierPath {
        let _path = UIBezierPath()
        if isRounded {
            var firstArcCenter : CGPoint {
                if isHorizontal { return CGPoint(x: secondPoint.x, y: startingPoint.y) }
                else { return CGPoint(x: startingPoint.x, y: secondPoint.y) }
            }
            var secoundArcCenter : CGPoint {
                if isHorizontal { return CGPoint(x: thirdPoint.x, y: startingPoint.y) }
                else { return CGPoint(x: startingPoint.x, y: thirdPoint.y) }
            }
            if isHorizontal {
                _path.addArc(withCenter: firstArcCenter, radius: thickNess/2, startAngle: CGFloat.pi/2, endAngle: CGFloat.pi*(3/2), clockwise: true)
                _path.addArc(withCenter: secoundArcCenter, radius: thickNess/2, startAngle: CGFloat.pi*(3/2), endAngle: CGFloat.pi/2, clockwise: true)
            } else {
                _path.addArc(withCenter: firstArcCenter, radius: thickNess/2, startAngle: CGFloat.pi, endAngle: CGFloat.pi*2, clockwise: true)
                _path.addArc(withCenter: secoundArcCenter, radius: thickNess/2, startAngle: 0, endAngle: CGFloat.pi, clockwise: true)
            }
        } else {
            _path.move(to: startingPoint)
            _path.addLine(to: secondPoint)
            _path.addLine(to: thirdPoint)
            _path.addLine(to: fourthPoint)
            _path.addLine(to: fifthPoint)
            _path.addLine(to: sixthPoint)
            _path.close()
        }
        return _path
    }
    
    override func draw(_ rect: CGRect) {
        itemColor.setFill()
        path.fill()
    }
    
}

extension AnalogTypeLcdItemView {
    
    private var isHorizontal : Bool {
        return (frame.width/frame.height > 1)
    }
    
    private var thickNess: CGFloat {
        if isHorizontal {
            return self.frame.height
        } else {
            return self.frame.width
        }
    }
    
    private var itemMinimumInsetMargin: CGFloat {
        if isRounded {
            return thickNess/2
        } else {
            return thickNess/5
        }
    }
    
    private var halfOfThickNess: CGFloat {
        return thickNess/2
    }
    
    private var itemLength : CGFloat {
        if isHorizontal {
            return frame.width - (halfOfThickNess + itemMinimumInsetMargin)*2
        } else {
            return frame.height - (halfOfThickNess + itemMinimumInsetMargin)*2
        }
    }
    
    private var startingPoint: CGPoint {
        if isHorizontal {
            return CGPoint(x: itemMinimumInsetMargin, y: halfOfThickNess)
        } else {
            return CGPoint(x: halfOfThickNess, y: itemMinimumInsetMargin)
        }
    }
    
    private var secondPoint: CGPoint {
        if isHorizontal {
            return startingPoint.offSetBy(dX: halfOfThickNess, dY: -halfOfThickNess)
        } else {
            return startingPoint.offSetBy(dX: -halfOfThickNess, dY: halfOfThickNess)
        }
    }
    
    private var thirdPoint: CGPoint {
        if isHorizontal {
            return secondPoint.offSetBy(dX: itemLength, dY: 0)
        } else {
            return secondPoint.offSetBy(dX: 0, dY: itemLength)
        }
    }
    
    private var fourthPoint: CGPoint {
        if isHorizontal {
            return thirdPoint.offSetBy(dX: halfOfThickNess, dY: halfOfThickNess)
        } else {
            return thirdPoint.offSetBy(dX: halfOfThickNess, dY: halfOfThickNess)
        }
    }
    
    private var fifthPoint: CGPoint {
        if isHorizontal {
            return fourthPoint.offSetBy(dX: -(halfOfThickNess), dY: halfOfThickNess)
        } else {
            return fourthPoint.offSetBy(dX: halfOfThickNess, dY: -halfOfThickNess)
        }
    }
    
    private var sixthPoint: CGPoint {
        if isHorizontal {
            return fifthPoint.offSetBy(dX: -itemLength, dY: 0)
        } else {
            return fifthPoint.offSetBy(dX: 0, dY: -itemLength)
        }
    }
}
