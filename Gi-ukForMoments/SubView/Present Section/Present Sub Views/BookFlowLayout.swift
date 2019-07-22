//
//  BookFlowLayout.swift
//  Gi-ukForMoments
//
//  Created by goya on 19/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class BookFlowLayout: UICollectionViewFlowLayout {
    
    var pageHeight: CGFloat {
        return estimateCellSize.height
    }
    
    var pageWidth: CGFloat {
        return estimateCellSize.width
    }
    
    var estimateCellSize: CGSize {
        var cellWidth = width.clearUnderDot
        var cellHeight: CGFloat {return cellWidth/bookRatio_FloatValue}
        while cellHeight > height {
            cellWidth -= 1
        }
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    var width: CGFloat {
        return collectionView!.bounds.width
    }
    
    var height: CGFloat {
        return collectionView!.bounds.height
    }
    
    var bookRatio: (width: CGFloat, height: CGFloat) {
        return (3,4)
    }
    
    var bookRatio_FloatValue: CGFloat {
        return bookRatio.width/bookRatio.height
    }
    
    var numberOfItems: Int = 0
    
    override func prepare() {
        super.prepare()
        collectionView?.decelerationRate = UIScrollView.DecelerationRate.fast
        numberOfItems = collectionView!.numberOfItems(inSection: 0)
        collectionView?.isPagingEnabled = true
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override var collectionViewContentSize: CGSize {
        let size = CGSize(width: (CGFloat(numberOfItems / 2)) * width, height: height)
        return size
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        //1
        var array: [UICollectionViewLayoutAttributes] = []
        
        //2
        for i in 0 ... max(0, numberOfItems - 1) {
            //3
            let indexPath = IndexPath(item: i, section: 0)
            //4
            let attributes = layoutAttributesForItem(at: indexPath)
            if attributes != nil {
                //5
                array += [attributes!]
            }
        }
        //6
        return array
    }
    
    //MARK: - Attribute Logic Helpers
    
    func getFrame(collectionView: UICollectionView) -> CGRect {
        var frame = CGRect()
        let leftOver = (width - pageWidth)/2
        frame.origin.x = leftOver + collectionView.contentOffset.x
        frame.origin.y = (collectionViewContentSize.height - pageHeight) / 2
        frame.size.width = estimateCellSize.width
        frame.size.height = estimateCellSize.height
        
        return frame
    }
    
    func getRatio(collectionView: UICollectionView, indexPath: NSIndexPath) -> CGFloat {
        //1
        let page = CGFloat(indexPath.item - indexPath.item % 2) * 0.5
        
        //2
        var ratio: CGFloat = -0.5 + page - (collectionView.contentOffset.x / collectionView.bounds.width)
        
        //3
        if ratio > 0.5 {
            ratio = 0.5 + 0.05 * (ratio - 0.5)
            
        } else if ratio < -0.5 {
            ratio = -0.5 + 0.05 * (ratio + 0.5)
        }
        
        return ratio
    }
    
    func getAngle(indexPath: NSIndexPath, ratio: CGFloat) -> CGFloat {
        // Set rotation
        var angle: CGFloat = 0
        
        //1
        if indexPath.item % 2 == 0 {
            // The book's spine is on the left of the page
            angle = (1-ratio) * -CGFloat.pi/2
        } else {
            //2
            // The book's spine is on the right of the page
            angle = (1 + ratio) * CGFloat.pi/2
        }
        //3
        // Make sure the odd and even page don't have the exact same angle
        angle += CGFloat(indexPath.row % 2) / 1000
        //4
        return angle
    }
    
    func makePerspectiveTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -2000
        return transform
    }
    
    func getRotation(indexPath: NSIndexPath, ratio: CGFloat) -> CATransform3D {
        var transform = makePerspectiveTransform()
        let angle = getAngle(indexPath: indexPath, ratio: ratio)
        transform = CATransform3DRotate(transform, angle, 0, 1, 0)
        return transform
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //1
        var layoutAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        //2
        var frame = getFrame(collectionView: collectionView!)
        layoutAttributes.frame = frame
        
        //3
        var ratio = getRatio(collectionView: collectionView!, indexPath: indexPath as NSIndexPath)
        
        //4
        if ratio > 0 && indexPath.item % 2 == 1
            || ratio < 0 && indexPath.item % 2 == 0 {
            // Make sure the cover is always visible
            if indexPath.row != 0 {
                return nil
            }
        }
        //5
        var rotation = getRotation(indexPath: indexPath as NSIndexPath, ratio: min(max(ratio, -1), 1))
        layoutAttributes.transform3D = rotation
        
        //6
        if indexPath.row == 0 {
            layoutAttributes.zIndex = Int.max
        }
        
        return layoutAttributes
    }
    
//    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes!) {
//        super.applyLayoutAttributes(layoutAttributes)
//        //1
//        if layoutAttributes.indexPath.item % 2 == 0 {
//            //2
//            layer.anchorPoint = CGPointMake(0, 0.5)
//            isRightPage = true
//        } else { //3
//            //4
//            layer.anchorPoint = CGPointMake(1, 0.5)
//            isRightPage = false
//        }
//        //5
//        self.updateShadowLayer()
//    }


}
