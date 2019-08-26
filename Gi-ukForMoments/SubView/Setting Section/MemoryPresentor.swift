//
//  MemoryPresentor.swift
//  Gi-ukForMoments
//
//  Created by goya on 26/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
extension CGRect {
    typealias MarginInset = (top: CGFloat, bottom: CGFloat, left: CGFloat, right: CGFloat)
    func insetAs(_ inset: MarginInset) -> CGRect {
        let newWith = self.width - inset.left - inset.right
        let newHeight = self.height - inset.top - inset.bottom
        let newSize = CGSize(width: newWith, height: newHeight)
        let newOrigin = self.origin.offSetBy(dX: inset.left, dY: inset.top)
        return CGRect(origin: newOrigin, size: newSize)
    }
}

class MemoryPresentor: UIView {
    
    func setImagesToImageView(_ images: [UIImage]) {
        for index in images.indices {
            if index < 3 {
                allImageViews[index].image = images[index]
            }
        }
    }
    
    weak var imageSection_First : UIImageView!
    weak var imageSection_Second : UIImageView!
    weak var imageSection_Third : UIImageView!
    
    private var allImageViews: [UIImageView] {
        return [imageSection_First, imageSection_Second, imageSection_Third]
    }
    
    private func setImageViews() {
        let gridInfo = memoryGrider()
        
        if imageSection_First == nil {
            let newImageView = generateUIView(view: imageSection_First, frame: gridInfo[0])
            imageSection_First = newImageView
            imageSection_First.contentMode = .scaleAspectFill
            imageSection_First.backgroundColor = .goyaYellowWhite
            imageSection_First.clipsToBounds = true
            imageSection_First.alpha = 0.7
            addSubview(imageSection_First)
        } else {
            imageSection_First.setNewFrame(gridInfo[0])
        }
        
        if imageSection_Second == nil {
            let newImageView = generateUIView(view: imageSection_Second, frame: gridInfo[1])
            imageSection_Second = newImageView
            imageSection_Second.contentMode = .scaleAspectFill
            imageSection_Second.backgroundColor = .goyaYellowWhite
            imageSection_Second.clipsToBounds = true
            addSubview(imageSection_Second)
        } else {
            imageSection_Second.setNewFrame(gridInfo[1])
        }
        
        if imageSection_Third == nil {
            let newImageView = generateUIView(view: imageSection_Third, frame: gridInfo[2])
            imageSection_Third = newImageView
            imageSection_Third.contentMode = .scaleAspectFill
            imageSection_Third.backgroundColor = .goyaYellowWhite
            imageSection_Third.clipsToBounds = true
            imageSection_Third.alpha = 0.7
            addSubview(imageSection_Third)
        } else {
            imageSection_Third.setNewFrame(gridInfo[2])
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setImageViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setImageViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setImageViews()
    }

}

extension MemoryPresentor {
    
    fileprivate func memoryFrameGrider() -> CGRect  {
        var frameRatio: CGFloat = 3/4
        var isHorizontal: Bool {
            return bounds.width/bounds.height > 1
        }
        
        var anchorSize: CGFloat {
            if isHorizontal {
                return bounds.width
            } else {
                return bounds.height
            }
        }
        
        var mutableSizeFactorX: CGFloat = anchorSize
        var mutableSizeFactorY: CGFloat {
            if isHorizontal {
                return mutableSizeFactorX / frameRatio
            } else {
                return mutableSizeFactorX * frameRatio
            }
        }
        
        if isHorizontal {
            while mutableSizeFactorY > bounds.height {
                mutableSizeFactorX -= 0.1
            }
        } else {
            while mutableSizeFactorY > bounds.width {
                mutableSizeFactorX -= 0.1
            }
        }
        
        let factorX = mutableSizeFactorX.clearUnderDot
        let factorY = mutableSizeFactorY.clearUnderDot
        
        var origin: CGPoint {
            if isHorizontal {
                let originX = (bounds.width - factorX)/2
                let originY = (bounds.height - factorY)/2
                return CGPoint(x: originX, y: originY)
            } else {
                let originX = (bounds.width - factorY)/2
                let originY = (bounds.height - factorX)/2
                return CGPoint(x: originX, y: originY)
            }
        }
        
        var size: CGSize {
            if isHorizontal {
                return CGSize(width: factorX, height: factorY)
            } else {
                return CGSize(width: factorY, height: factorX)
            }
        }
        return CGRect(origin: origin, size: size)
    }
    
    fileprivate func memoryGrider(minSpacing: CGFloat = 5, marginInset: CGRect.MarginInset = (0,0,0,0)) -> [CGRect] {
        let anchorRect = memoryFrameGrider().insetAs(marginInset)
        let anchorSize = anchorRect.size
        let anchorOrigin = anchorRect.origin
        let devidingFactor_height = anchorSize.width/1.618
        let devidingFactor_width = anchorSize.height/2.589
        
        var firstArea: CGRect {
            let width = anchorSize.width - devidingFactor_width - (minSpacing/2)
            let height = devidingFactor_height - (minSpacing/2)
            let size = CGSize(width: width, height: height)
            let origin = anchorOrigin
            return CGRect(origin: origin, size: size)
        }
        
        var secondArea: CGRect {
            let width = devidingFactor_width - (minSpacing/2)
            let height = devidingFactor_height - (minSpacing/2)
            let size = CGSize(width: width, height: height)
            let originX = anchorOrigin.x + (anchorSize.width - devidingFactor_width + (minSpacing/2))
            let originY = anchorOrigin.y
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        }
        
        var thirdArea: CGRect {
            let width = devidingFactor_width - (minSpacing/2)
            let height = anchorSize.height - devidingFactor_height - (minSpacing/2)
            let size = CGSize(width: width, height: height)
            let originX = anchorOrigin.x + (anchorSize.width - devidingFactor_width + (minSpacing/2))
            let originY = anchorOrigin.y + devidingFactor_height + (minSpacing/2)
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        }
        
        return [firstArea,secondArea,thirdArea]
    }
}
