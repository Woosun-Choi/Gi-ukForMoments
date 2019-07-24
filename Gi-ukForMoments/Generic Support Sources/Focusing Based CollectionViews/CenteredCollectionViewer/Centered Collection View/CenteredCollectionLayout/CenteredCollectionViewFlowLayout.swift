//
//  CenteredCollectionViewFlowLayout.swift
//  linearCollectionViewTest
//
//  Created by goya on 23/03/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class CenteredCollectionViewFlowLayout: UICollectionViewLayout {
    
    convenience init(isFullscreen: Bool, isHorizontal: Bool, cellMinimumMargin: CGFloat ,estimateCellSize: CGSize?) {
        self.init()
        self.estimateCellSize = estimateCellSize
        self.isFullscreen = isFullscreen
        self.isHorizontal = isHorizontal
        self.minimumMargin = cellMinimumMargin
    }
    
    var estimateCellSize: CGSize?
    
    var isFullscreen: Bool = true
    
    var isHorizontal: Bool = true
    
    var minimumMargin: CGFloat = 0
    
    func positionOfCellForIndexpath(_ index: IndexPath) -> CGPoint {
        if isHorizontal {
            if index.row == 0 {
                return CGPoint(x: 0, y: 0)
            } else {
                let positionX = cache[index.item].frame.origin.x - requiredEdgeMarginForAlignCellsToCenter
                //((requiredEdgeMarginForAlignCellsToCenter) + (expectedCellSizeFactor))*CGFloat(index.item)
                //let positionX = (width*CGFloat(index.item))
                return CGPoint(x: positionX, y: 0)
            }
        } else {
            if index.row == 0 {
                return CGPoint(x: 0, y: 0)
            } else {
                let positionY = cache[index.item].frame.origin.y - requiredEdgeMarginForAlignCellsToCenter
                //((requiredEdgeMarginForAlignCellsToCenter) + (expectedCellSizeFactor))*CGFloat(index.item)
                return CGPoint(x: 0, y: positionY)
            }
        }
    }
    
    var draggingOffSet: CGFloat {
        if isHorizontal {
            return width/2
        } else {
            return height/2
        }
    }
    
    var cellDraggingOffSet: CGFloat {
        return expectedCellSizeFactor * 0.3
    }
    
    private var requiredEdgeMarginForAlignCellsToCenter: CGFloat {
        if isHorizontal {
            return ((width - expectedCellSizeFactor)/2).absValue
        } else {
            return ((height - expectedCellSizeFactor)/2).absValue
        }
    }
    
    private var expectedCellSizeFactor: CGFloat {
        if isHorizontal {
            return expectedCellSize.width
        } else {
            return expectedCellSize.height
        }
    }
    
    var expectedCellSize: CGSize {
        if estimateCellSize != nil {
            return recalculateEstimateCellSize()
        } else {
            if isFullscreen {
                let width = (self.width - (minimumMargin*2))
                let height = (self.height - (minimumMargin*2))
                return CGSize(width: width, height: height)
            } else {
                let fixedFactor = (min(width, height) - (minimumMargin*2))
                return CGSize(width: fixedFactor, height: fixedFactor)
            }
        }
    }
    
    private func recalculateEstimateCellSize() -> CGSize {
        guard let estimateSize = estimateCellSize else { return CGSize.zero }
        if estimateSize.width + (minimumMargin*2) > width {
            let ratio = estimateSize.width/estimateSize.height
            let newWidth = (self.width - (minimumMargin*2)).absValue
            let newHeight = (newWidth/ratio).absValue
            return CGSize(width: newWidth, height: newHeight)
        } else if estimateSize.height + (minimumMargin*2) > height {
            let ratio = estimateSize.width/estimateSize.height
            let newHeight = (self.height - (minimumMargin*2)).absValue
            let newWidth = (newHeight*ratio).absValue
            return CGSize(width: newWidth, height: newHeight)
        } else {
            return estimateSize
        }
    }
    
    var cache: [UICollectionViewLayoutAttributes] = []
    
    var width: CGFloat {
        return collectionView?.frame.width ?? 0
    }
    
    var height: CGFloat {
        return collectionView?.frame.height ?? 0
    }
    
    var maxIndex: Int {
        if numberOfItemsInSection(0) > 0 {
            return numberOfItemsInSection(0) - 1
        } else {
            return 0
        }
    }
    
    // Returns the number of items in the collection view
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return collectionView!.numberOfItems(inSection: section)
    }
    
    private var numberOfSections: Int {
        return collectionView?.numberOfSections ?? 1
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
}

extension CenteredCollectionViewFlowLayout {
    
    override var collectionViewContentSize : CGSize {
        let forEdgeMargins = requiredEdgeMarginForAlignCellsToCenter
        let expectedLengthForOneCell = expectedCellSizeFactor
        let expectedCellAreaLength = forEdgeMargins + expectedLengthForOneCell
        
        var expectedItemAreaLength: CGFloat {
            var expectedValueOfLength: CGFloat = 0
            for section in 0..<numberOfSections {
                expectedValueOfLength += (expectedCellAreaLength * CGFloat(numberOfItemsInSection(section)))
            }
            return expectedValueOfLength
        }
        
        let expectedLength = expectedItemAreaLength + (requiredEdgeMarginForAlignCellsToCenter*2)
        
        if isHorizontal {
            return CGSize(width: expectedLength, height: height)
        } else {
            return CGSize(width: width, height: expectedLength)
        }
    }
    
    override func prepare() {
        cache.removeAll(keepingCapacity: false)
        
        let cellSize = expectedCellSize
        
        var fixedPositionAchor: CGFloat {
            if isHorizontal {
                return (height - cellSize.height)/2
            } else {
                return (width - cellSize.width)/2
            }
        }
        
        var positionAnchor: CGFloat = requiredEdgeMarginForAlignCellsToCenter
        
        var cellOrigin: CGPoint {
            if isHorizontal {
                return CGPoint(x: positionAnchor, y: 0)
            } else {
                return CGPoint(x: 0, y: positionAnchor)
            }
        }
        
        var expectedPositionOfCell: CGPoint {
            if isHorizontal {
                return CGPoint(x: positionAnchor, y: fixedPositionAchor)
            } else {
                return CGPoint(x: fixedPositionAchor, y: positionAnchor)
            }
        }
        
        var frame : CGRect {
            return CGRect(origin: expectedPositionOfCell, size: cellSize)
        }
        
//        if cache.count != numberOfItemsInSection(0) {
        
            for section in 0..<numberOfSections {
                for item in 0..<numberOfItemsInSection(section) {
                    let indexPath = IndexPath(item: item, section: 0)
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    attributes.zIndex = item
                    attributes.frame = frame
                    cache.append(attributes)
                    if isHorizontal {
                        positionAnchor = frame.maxX + requiredEdgeMarginForAlignCellsToCenter
                    } else {
                        positionAnchor = frame.maxY + requiredEdgeMarginForAlignCellsToCenter
                    }
                }
            }
//        }
        
//        cache.removeAll(keepingCapacity: false)
//
//        for section in 0..<numberOfSections {
//            for item in 0..<numberOfItemsInSection(section) {
//                let indexPath = IndexPath(item: item, section: 0)
//                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
//                attributes.zIndex = item
//                attributes.frame = frame
//                cache.append(attributes)
//                if isHorizontal {
//                    positionAnchor = frame.maxX + requiredEdgeMarginForAlignCellsToCenter
//                } else {
//                    positionAnchor = frame.maxY + requiredEdgeMarginForAlignCellsToCenter
//                }
//            }
//        }
        
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
