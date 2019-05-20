//
//  StandardVisualLayout.swift
//  linearCollectionViewTest
//
//  Created by goya on 02/01/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

//struct StandardVisualLayoutConstants {
//    struct CellSettings {
//        // The height of the non-featured cell
//        static var standardHeight: CGFloat {
//            return featuredHeight/4
//        }
//        // The height of the first visible cell
//        static var featuredHeight: CGFloat = 300
//    }
//}

class VerticalSpotlightCollectionViewFlowLayout: UICollectionViewLayout {
    
    var cellFeaturedHeight: CGFloat {
        //return StandardVisualLayoutConstants.CellSettings.featuredHeight
        if width < height {
            return width.clearUnderDot
        } else {
            return (height * 0.5).clearUnderDot
        }
    }
    var cellStandardHeight: CGFloat {
        //return StandardVisualLayoutConstants.CellSettings.standardHeight
        return ((cellFeaturedHeight)/3).clearUnderDot
    }
    
    // The amount the user needs to scroll before the featured cell changes
    var dragOffset: CGFloat {
        return  cellFeaturedHeight - cellStandardHeight
    }
    
    var cache: [UICollectionViewLayoutAttributes] = []
    
    // Returns the item index of the currently featured cell
    var focusedItemIndex: Int {
        // Use max to make sure the featureItemIndex is never < 0
        let expectedFocusedItemIndex = Int((collectionView!.contentOffset.y + minMarginForPreventinglayOutIssue) / dragOffset)
        return max(0, expectedFocusedItemIndex)
    }
    
    // Returns a value between 0 and 1 that represents how close the next cell is to becoming the featured cell
    var nextItemPercentageOffset: CGFloat {
        let percentageOffSet = (collectionView!.contentOffset.y / dragOffset) - CGFloat(focusedItemIndex)
        return max(0, percentageOffSet)
    }
    
    // Returns the width of the collection view
    var width: CGFloat {
        return collectionView!.bounds.width
    }
    
    // Returns the height of the collection view
    var height: CGFloat {
        return collectionView!.bounds.height
    }
    
    // Returns the number of items in the collection view
    var numberOfItems: Int {
        return collectionView!.numberOfItems(inSection: 0)
    }
    
    var requestedActionWhenWillfocusedCellUpdated: (() ->Void)?
    
    var willFocusedCell: IndexPath? {
        didSet {
            requestedActionWhenWillfocusedCellUpdated?()
        }
    }
    
    var minMarginForPreventinglayOutIssue: CGFloat {
        return 0
    }
    
}

// MARK: UICollectionViewLayout

extension VerticalSpotlightCollectionViewFlowLayout {
    
    override var collectionViewContentSize : CGSize {
        let contentHeight = (CGFloat(numberOfItems - 1) * dragOffset) + cellFeaturedHeight + (height - cellFeaturedHeight) + minMarginForPreventinglayOutIssue*2
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepare() {
        cache.removeAll(keepingCapacity: false)
        
        let standardHeight = cellStandardHeight
        let featuredHeight = cellFeaturedHeight
        
        var frame = CGRect.zero
        var y: CGFloat = minMarginForPreventinglayOutIssue
        
        print(focusedItemIndex)
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.zIndex = item
            var height = standardHeight
            
            if indexPath.item == focusedItemIndex {
                let yOffset = standardHeight * nextItemPercentageOffset
                let collcectionOffset = collectionView!.contentOffset.y
                if collcectionOffset <= 0 {
                    y = minMarginForPreventinglayOutIssue
                } else {
                    y = collectionView!.contentOffset.y //- yOffset
                    print(yOffset)
                }
                height = featuredHeight - yOffset
                attributes.alpha = 1 - nextItemPercentageOffset
            } else if indexPath.item == (focusedItemIndex + 1)
                && indexPath.item != numberOfItems {
                let maxY = y + standardHeight
                height = standardHeight + max((featuredHeight - standardHeight) * nextItemPercentageOffset, 0)
                let newPosition = maxY - height
                y = newPosition
            }
            
            if indexPath.item < focusedItemIndex {
                height = dragOffset
            }
            
            frame = CGRect(x: 0, y: y, width: width, height: height)
            attributes.frame = frame
            cache.append(attributes)
            y = frame.maxY
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
}
