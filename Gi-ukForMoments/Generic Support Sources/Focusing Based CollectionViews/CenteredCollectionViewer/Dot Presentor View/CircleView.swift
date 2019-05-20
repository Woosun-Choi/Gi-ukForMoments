//
//  CircleView.swift
//  DontPanic
//
//  Created by goya on 17/03/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class CircleView: UIView {
    
    enum presentCase {
        case enable
        case close
        case far
    }
    
    var path: UIBezierPath!
    
    var dotColor: UIColor = UIColor.black
    
    var state : presentCase = .enable {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .redraw
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentMode = .redraw
        self.backgroundColor = .clear
        fatalError("init(coder:) has not been implemented")
    }
    
    private var expectedSize: CGFloat {
        switch state {
        case .enable: return min(self.bounds.width, self.bounds.height) * 0.718
        case .close: return min(self.bounds.width, self.bounds.height) * 0.618
        case .far: return min(self.bounds.width, self.bounds.height) * 0.518
        }
    }
    
    private var dotCenter: CGPoint {
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private var expectedOrigin: CGPoint {
        let dX = (self.bounds.width - expectedSize)/2
        let dY = (self.bounds.height - expectedSize)/2
        return CGPoint(x: dX, y: dY)
    }
    
    private var dotPath: UIBezierPath {
        return UIBezierPath(ovalIn: CGRect(origin: expectedOrigin, size: CGSize(width: expectedSize, height: expectedSize)))
    }
    
    private func drawDotInPath(_ path: UIBezierPath) {
        switch state {
        case .enable: dotColor.setFill()
        default:
            dotColor.withAlphaComponent(0.5).setFill()
        }
        UIColor.goyaWhite.withAlphaComponent(1).setStroke()
        path.lineWidth = 0.2
        path.fill()
        path.stroke()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func draw(_ rect: CGRect) {
        path = dotPath
        drawDotInPath(path)
    }

}
