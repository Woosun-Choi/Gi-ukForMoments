//
//  InnerShadowUIView.swift
//  Gi-ukForMoments
//
//  Created by goya on 27/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class InnerShadowUIView: UIView {
    
    weak var innerShadowLayer: EdgeShadowLayer!
    
    private var _edgeDirection: EdgeShadowLayer.Edge = .Top {
        didSet {
            setInnerShadowLayer()
        }
    }
    
    var edgeDirection: EdgeShadowLayer.Edge {
        get {
            return self._edgeDirection
        } set {
            if newValue != self._edgeDirection {
                self._edgeDirection = newValue
                setInnerShadowLayer()
            }
        }
    }
    
    var isInnerShadowRequired: Bool = false {
        didSet {
            setInnerShadowLayer()
        }
    }
    
    func setInnerShadowLayer() {
        if isInnerShadowRequired {
            if innerShadowLayer == nil {
                let newLayer = EdgeShadowLayer(forView: self, edge: edgeDirection, shadowRadius: 5, toColor: .clear, fromColor: UIColor.goyaBlack.withAlphaComponent(0.9))
                newLayer.backgroundColor = UIColor.clear.cgColor
                innerShadowLayer = newLayer
                layer.addSublayer(innerShadowLayer)
            } else {
                innerShadowLayer.removeFromSuperlayer()
                let newLayer = EdgeShadowLayer(forView: self, edge: edgeDirection, shadowRadius: 5, toColor: .clear, fromColor: UIColor.goyaBlack.withAlphaComponent(0.9))
                newLayer.backgroundColor = UIColor.clear.cgColor
                innerShadowLayer = newLayer
                layer.addSublayer(innerShadowLayer)
            }
        } else {
            if innerShadowLayer != nil {
                innerShadowLayer.removeFromSuperlayer()
                innerShadowLayer = nil
            }
        }
    }
}
