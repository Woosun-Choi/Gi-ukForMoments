//
//  TimeCollectionViewFlowlayout.swift
//  LinearTimeLineViewDemo
//
//  Created by goya on 08/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class CenteredSquareTypeCollectionViewFlowlayout: UICollectionViewFlowLayout {
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    var isHorizontal: Bool {
        return (width > height)
    }
    
    private func numberOfItemsInSection(_ section: Int) -> Int {
        return collectionView!.numberOfItems(inSection: section)
    }
    
    private var numberOfSections: Int {
        return collectionView?.numberOfSections ?? 1
    }
    
    private var width: CGFloat {
        return collectionView!.frame.width.preventNaN
    }
    
    private var height: CGFloat {
        return collectionView!.frame.height.preventNaN
    }
    
    var estimateCellSize: CGSize {
        if isHorizontal {
            let expectedWidth = ((self.width - contentMinimumMargin*2)/numberOfCellsInLine).absValue
            let expectedHeight = expectedWidth//(self.height - (contentMinimumMargin*2)).absValue
            return CGSize(width: expectedWidth, height: expectedHeight)
        } else {
            let expectedHeight = ((self.height - contentMinimumMargin*2)/numberOfCellsInLine).absValue
            let expectedWidth = expectedHeight//(self.width - (contentMinimumMargin*2)).absValue
            return CGSize(width: expectedWidth, height: expectedHeight)
        }
    }
    
    private var expectedCellSizeFactor: CGFloat {
        if isHorizontal {
            return estimateCellSize.width
        } else {
            return estimateCellSize.height
        }
    }
    
    var expectedNumberOfCellsInLine: Int {
        if width > 0 && height > 0 {
            if isHorizontal {
                return Int((width/height).preventNaN)
            } else {
                return Int((height/width).preventNaN)
            }
        } else {
            return 5
        }
    }
    
    private var numberOfCellsInLine: CGFloat {
        if isHorizontal {
            let expectedNumberOfCellsInLine = self.expectedNumberOfCellsInLine
            if (expectedNumberOfCellsInLine % 2) == 1 {
                return CGFloat(expectedNumberOfCellsInLine)
            } else {
                return CGFloat(expectedNumberOfCellsInLine + 1)
            }
        } else {
            let expectedNumberOfCellsInLine = self.expectedNumberOfCellsInLine
            if (expectedNumberOfCellsInLine % 2) == 1 {
                return CGFloat(expectedNumberOfCellsInLine)
            } else {
                return CGFloat(expectedNumberOfCellsInLine + 1)
            }
        }
    }
    
    private var cellMinimumMargin: CGFloat {
        return expectedCellSizeFactor * 0.1618
    }
    
    private var contentMinimumMargin: CGFloat {
        if isHorizontal {
            return height * 0.05
        } else {
            return width * 0.05
        }
    }
    
    private var requiredMarginForMakeCellEndedInCenter: CGFloat {
        if isHorizontal {
            return ((self.width - estimateCellSize.width)/2).absValue
        } else {
            return ((self.height - estimateCellSize.height)/2).absValue
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
    
    var leftOverMargin: CGFloat {
        return contentMinimumMargin + requiredMarginForMakeCellEndedInCenter
    }
    
    func postionOfCellForIndexpath(_ index: IndexPath) -> CGPoint {
        if index.row == 0 {
            return CGPoint(x: 0, y: 0)
        } else {
            if isHorizontal {
                let positionX = cache[index.item].frame.origin.x - leftOverMargin
                //(estimateCellSize.width + cellMinimumMargin)*CGFloat(index.item) + contentMinimumMargin
                return CGPoint(x: positionX, y: 0)
            } else {
                let positionY = cache[index.item].frame.origin.y - leftOverMargin
                //(estimateCellSize.height + cellMinimumMargin)*CGFloat(index.item) + contentMinimumMargin
                return CGPoint(x: 0, y: positionY)
            }
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}

extension CenteredSquareTypeCollectionViewFlowlayout {
    
    override var collectionViewContentSize: CGSize {
        var fixedLegthFactor : CGFloat {
            if isHorizontal {
                return height
            } else {
                return width
            }
        }
        let expectedCellAreaLength: CGFloat = expectedCellSizeFactor + cellMinimumMargin
        var expectedItemAreaLength: CGFloat {
            var expectedValueOfLength: CGFloat = 0
            for section in 0..<numberOfSections {
                expectedValueOfLength += (expectedCellAreaLength * CGFloat(numberOfItemsInSection(section)))
            }
            return expectedValueOfLength
        }
        let expectedFullAreaLength: CGFloat = expectedItemAreaLength + (contentMinimumMargin*2) + (requiredMarginForMakeCellEndedInCenter*2)
        
        if isHorizontal {
            return CGSize(width: expectedFullAreaLength, height: fixedLegthFactor)
        } else {
            return CGSize(width: fixedLegthFactor, height: expectedFullAreaLength)
        }
    }
    
    override func prepare() {
        
        cache.removeAll()
        
        var initailPosition: CGFloat = contentMinimumMargin + requiredMarginForMakeCellEndedInCenter
        
        var fixedPostion : CGFloat {
            if isHorizontal {
                return (self.height - estimateCellSize.height)/2
            } else {
                return (self.width - estimateCellSize.width)/2
            }
        }
        
        var mutablePosition: CGFloat = initailPosition
        
        var frame: CGRect {
            if isHorizontal {
                return CGRect(origin: CGPoint(x: mutablePosition, y: fixedPostion), size: estimateCellSize)
            } else {
                return CGRect(origin: CGPoint(x: fixedPostion, y: mutablePosition), size: estimateCellSize)
            }
        }
        
        func updateMutablePosition(frame: CGRect) {
            if isHorizontal {
                mutablePosition = frame.maxX + cellMinimumMargin
            } else {
                mutablePosition = frame.maxY + cellMinimumMargin
            }
        }
        
        for section in 0..<numberOfSections {
            for item in 0..<numberOfItemsInSection(section) {
                let indexPath = IndexPath(item: item, section: 0)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.zIndex = item
                attributes.frame = frame
                cache.append(attributes)
                updateMutablePosition(frame: frame)
            }
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
