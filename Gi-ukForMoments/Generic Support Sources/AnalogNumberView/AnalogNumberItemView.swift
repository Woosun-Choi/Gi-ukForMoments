//
//  AnalogNumberView.swift
//  LifeTuner
//
//  Created by goya on 16/12/2018.
//  Copyright © 2018 goya. All rights reserved.
//

import UIKit

@IBDesignable

class AnalogNumberItemView: UIView {
    
    @IBInspectable var number : Int = 0 {
        didSet {
            setColorToLCDItemView()
        }
    }
    
    var isZeroAvailable = true
    
    var isRounded = false {
        didSet {
            for item in items.allItem {
                itemViewArray[item]?.isRounded = self.isRounded
            }
        }
    }
    
    var numberColor : UIColor = UIColor.goyaBlack {
        didSet {
            setColorToLCDItemView()
        }
    }
    
//    private func setViewNumber(drawings: [Int]) {
//        for num in itemViews.indices {
//            if drawings.contains(num) {
//                itemViews[num].itemColor = numberColor
//            } else {
//                itemViews[num].itemColor = numberColor.withAlphaComponent(0.1)
//            }
//        }
//    }
    
    private func _setViewNumber(drawings: Int) {
        for item in items.allItem {
            if let drawingPositions = _numberDrawings[drawings], drawingPositions.contains(item) {
                itemViewArray[item]?.itemColor = numberColor
            } else {
                itemViewArray[item]?.itemColor = numberColor.withAlphaComponent(0.1)
            }
        }
    }
    
    /* - MARK : Seven segments position number
      ===0===
     ||     ||
     3      5
     ||     ||
      ===1===
     ||     ||
     4      6
     ||     ||
      ===2===
     */
    
//    private var numberDrawings : Dictionary<Int,[Int]> =
//        [
//            0:[0,2,3,4,5,6],
//            1:[5,6],
//            2:[0,1,2,4,5],
//            3:[0,5,1,6,2],
//            4:[3,1,5,6],
//            5:[0,3,1,6,2],
//            6:[0,3,1,4,6,2],
//            7:[0,5,6],
//            8:[0,1,2,3,4,5,6],
//            9:[0,3,1,5,6]
//    ]
    
    private var _numberDrawings : Dictionary<Int,[items]> =
        [
            0:[items.HorizontalTop, items.HorizontalBottom, items.VerticalLeftTop , items.VerticalLeftBottom, items.VerticalRightTop, items.VerticalRightBottom],
            1:[items.VerticalRightTop,items.VerticalRightBottom],
            2:[items.HorizontalTop,items.HorizontalMiddle, items.HorizontalBottom, items.VerticalRightTop, items.VerticalLeftBottom],
            3:[items.HorizontalTop,items.VerticalRightTop,items.HorizontalMiddle,items.VerticalRightBottom,items.HorizontalBottom],
            4:[items.VerticalLeftTop,items.HorizontalMiddle,items.VerticalRightTop,items.VerticalRightBottom],
            5:[items.HorizontalTop,items.VerticalLeftTop,items.HorizontalMiddle,items.VerticalRightBottom,items.HorizontalBottom],
            6:[items.HorizontalTop,items.VerticalLeftTop,items.HorizontalMiddle,items.VerticalLeftBottom,items.VerticalRightBottom,items.HorizontalBottom],
            7:[items.HorizontalTop,items.VerticalRightTop,items.VerticalRightBottom],
            8:[items.HorizontalTop,items.HorizontalMiddle,items.HorizontalBottom,items.VerticalLeftTop,items.VerticalLeftBottom,items.VerticalRightTop,items.VerticalRightBottom],
            9:[items.HorizontalTop,items.VerticalLeftTop,items.HorizontalMiddle,items.VerticalRightTop,items.VerticalRightBottom],
            10: []
    ]
    
//    private lazy var itemViews : [AnalogTypeLcdItemView] = {
//        var views = [AnalogTypeLcdItemView]()
//        items.allItem.forEach {
//            var itemView = setItemView($0)
//            itemView.backgroundColor = UIColor.clear
//            itemView.isRounded = self.isRounded
//            views.append(itemView)
//        }
//        return views
//    }()
    
    private func setColorToLCDItemView() {
        let drawingNumber = number.absValue % 10
        (isZeroAvailable) ? (_setViewNumber(drawings: drawingNumber)) :
            ((drawingNumber == 0) ? _setViewNumber(drawings: 10) : _setViewNumber(drawings: drawingNumber))
    }
    
    private lazy var itemViewArray: Dictionary<items,AnalogTypeLcdItemView> =
    {
        var arrayOfItems = [items : AnalogTypeLcdItemView]()
        items.allItem.forEach {
            let itemView = setItemView($0)
            itemView.backgroundColor = UIColor.clear
            itemView.isRounded = self.isRounded
            addSubview(itemView)
            arrayOfItems[$0] = itemView
        }
        return arrayOfItems
    }()
    
    private func reLayoutItemViews() {
        items.allItem.forEach {
            itemViewArray[$0]?.frame = rectForItem($0)
        }
    }
    
    private let drawings : [items] = items.allItem
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reLayoutItemViews()
    }
    
    override func draw(_ rect: CGRect) {
        reLayoutItemViews()
//        subviews.forEach{$0.removeFromSuperview()}
//        itemViews.forEach {addSubview($0)}
    }
    
}

extension AnalogNumberItemView {
    
    //MARK: Design drawing area
    private var verticalMinimumMargin : CGFloat {
        return self.frame.height * 0.10
    }
    
    private var horizontalMinimumMargin : CGFloat {
        return self.frame.width * 0.15
    }
    
    private var verticalLength : CGFloat { return self.frame.height - verticalMinimumMargin }
    
    private var horizontalLength : CGFloat { return self.frame.width - horizontalMinimumMargin }
    
    private var squareRatio: CGFloat { return 1.875 }
    
    private var squareHeight: CGFloat {
        var estimateHeight: CGFloat = verticalLength
        var estimateWidth: CGFloat { return estimateHeight/squareRatio }
        
        if estimateWidth > horizontalLength {
            for _ in 0...horizontalLength.intValue {
                if estimateWidth >= horizontalLength {
                    estimateHeight -= 1
                } else {
                    break
                }
            }
        }
        return estimateHeight
    }
    
    private var estimateSquareSize: CGSize {
        return CGSize(width: squareHeight/squareRatio, height: squareHeight)
    }
    
    private var squareOrigin: CGPoint {
        let dX = (self.frame.width - estimateSquareSize.width)/2
        let dY = (self.frame.height - estimateSquareSize.height)/2
        return CGPoint(x: dX, y: dY)
    }
    
    private var squareAreaRect: CGRect {
        return CGRect(origin: squareOrigin, size: estimateSquareSize)
    }
    // END design area
    
    
    // MARK: Design segment items
    
    private var thickNess : CGFloat {
        return estimateSquareSize.width * 0.15
    }
    
    private var itemMargin :CGFloat {
        return thickNess/2
    }
    
    private var verticalItemSize: CGSize { return CGSize(width: thickNess, height: (estimateSquareSize.height - thickNess) / 2) }
    
    private var horizontalItemSize: CGSize { return CGSize(width: estimateSquareSize.width - (thickNess), height: thickNess) }
    
    enum items: String {
        case HorizontalTop
        case HorizontalMiddle
        case HorizontalBottom
        case VerticalLeftTop
        case VerticalLeftBottom
        case VerticalRightTop
        case VerticalRightBottom
        
        static var allItem : [items] {
            return [items.HorizontalTop,.HorizontalMiddle,.HorizontalBottom,.VerticalLeftTop,.VerticalLeftBottom,.VerticalRightTop,.VerticalRightBottom]
        }
    }
    
    private var itemEdgeOrigins: [CGPoint] {
        let firstPoint = squareOrigin.offSetBy(dX: itemMargin, dY: 0)
        let secondPoint = squareOrigin.offSetBy(dX: 0, dY: itemMargin)
        let thirdPoint = firstPoint.offSetBy(dX: 0, dY: verticalItemSize.height)
        let fourthPoint = secondPoint.offSetBy(dX: 0, dY: verticalItemSize.height)
        let fifthPoint = thirdPoint.offSetBy(dX: 0, dY: verticalItemSize.height)
        let sixthPoint = secondPoint.offSetBy(dX: horizontalItemSize.width, dY: 0)
        let lastPoint = fourthPoint.offSetBy(dX: horizontalItemSize.width, dY: 0)
        let points = [firstPoint,secondPoint,thirdPoint,fourthPoint,fifthPoint,sixthPoint,lastPoint]
        return points
    }
    
    private var itemLoactions : Dictionary<String,CGPoint> {
        let locations = ["HorizontalTop":itemEdgeOrigins[0],
                         "VerticalLeftTop":itemEdgeOrigins[1],
                         "HorizontalMiddle":itemEdgeOrigins[2],
                         "VerticalLeftBottom":itemEdgeOrigins[3],
                         "HorizontalBottom":itemEdgeOrigins[4],
                         "VerticalRightTop":itemEdgeOrigins[5],
                         "VerticalRightBottom":itemEdgeOrigins[6]]
        return locations
    }
    
    private func rectForItem(_ item: items) -> CGRect {
        let itemLocation = item.rawValue
        switch item {
        case .HorizontalTop: return CGRect(origin: itemLoactions[itemLocation]!, size: horizontalItemSize)
        case .HorizontalMiddle: return CGRect(origin: itemLoactions[itemLocation]!, size: horizontalItemSize)
        case .HorizontalBottom:
            return CGRect(origin: itemLoactions[itemLocation]!, size: horizontalItemSize)
        case .VerticalLeftTop:
            return CGRect(origin: itemLoactions[itemLocation]!, size: verticalItemSize)
        case .VerticalLeftBottom:
            return CGRect(origin: itemLoactions[itemLocation]!, size: verticalItemSize)
        case .VerticalRightTop:
            return CGRect(origin: itemLoactions[itemLocation]!, size: verticalItemSize)
        case .VerticalRightBottom:
            return CGRect(origin: itemLoactions[itemLocation]!, size: verticalItemSize)
        }
    }
    
    private func setItemView(_ item: items) -> AnalogTypeLcdItemView {
        
        func setItem(rect: CGRect) -> AnalogTypeLcdItemView {
            let item = AnalogTypeLcdItemView()
            item.backgroundColor = UIColor.clear
            item.isOpaque = false
            item.contentMode = .redraw
            item.frame = rect
            return item
        }
        
        let itemLocation = item.rawValue
        
        switch item {
        case .HorizontalTop: return setItem(rect: CGRect(origin: itemLoactions[itemLocation]!, size: horizontalItemSize))
        case .HorizontalMiddle: return setItem(rect: CGRect(origin: itemLoactions[itemLocation]!, size: horizontalItemSize))
        case .HorizontalBottom:
            return setItem(rect: CGRect(origin: itemLoactions[itemLocation]!, size: horizontalItemSize))
        case .VerticalLeftTop:
            return setItem(rect: CGRect(origin: itemLoactions[itemLocation]!, size: verticalItemSize))
        case .VerticalLeftBottom:
            return setItem(rect: CGRect(origin: itemLoactions[itemLocation]!, size: verticalItemSize))
        case .VerticalRightTop:
            return setItem(rect: CGRect(origin: itemLoactions[itemLocation]!, size: verticalItemSize))
        case .VerticalRightBottom:
            return setItem(rect: CGRect(origin: itemLoactions[itemLocation]!, size: verticalItemSize))
        }
    }
    // END : design segments
}
