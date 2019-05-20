//
//  DayNumberView.swift
//  LifeTuner
//
//  Created by goya on 13/12/2018.
//  Copyright © 2018 goya. All rights reserved.
//

import UIKit

@IBDesignable

class AnalogNumberView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    @IBInspectable var isRoundedStyle : Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var dayNumber : Int = 0 {
        didSet {
            setNewNumbers()
        }
    }
    
    @IBInspectable var requiredNumberCount: Int = 3
    
    @IBInspectable var isZeroAvailable : Bool = true {
        didSet {
            setNewNumbers()
        }
    }
    
    private func checkZeroAvailable() {
        if !isZeroAvailable {
            guard let views = numberViews else {return}
            let howManyNumbersIn = String(dayNumber).count
            for item in views.indices {
                if item < ( requiredNumberCount - howManyNumbersIn ) {
                    views[item].isZeroAvailable = false
                }
            }
        }
    }
    
    @IBInspectable var numberColor: UIColor = UIColor.goyaBlack {
        didSet {
            guard let views = numberViews else {return}
            views.forEach{$0.numberColor = numberColor}
        }
    }
    
    private var numberViews : [AnalogNumberItemView]? {
        didSet {
            setNewNumbers()
            for sequence in 0..<requiredNumberCount {
                addSubview(numberViews![sequence])
            }
        }
    }
    
    private func setNewNumbers() {
        checkZeroAvailable()
        let numbers = setNumbers(requiredNumberCount)
        for sequence in 0..<requiredNumberCount {
            numberViews?[sequence].number = numbers[sequence]
        }
    }
    
    private func generateNumberView(rect: CGRect) -> AnalogNumberItemView {
        let view = AnalogNumberItemView()
        view.numberColor = numberColor
        view.backgroundColor = UIColor.clear
        view.isOpaque = false
        view.frame = rect
        return view
    }
    
    private var numberViewRects: [CGRect] {
        var rects = [CGRect]()
        let estimateNumberViewSizeWidth = frame.width / CGFloat(requiredNumberCount)
        let estimateNumberViewSizeHeight = min(self.frame.height, estimateNumberViewSizeWidth * 1.618)
        let estimateOriginY : CGFloat = (bounds.height - estimateNumberViewSizeHeight)/2
        let requiredNumberViewSize = CGSize(width: estimateNumberViewSizeWidth, height: estimateNumberViewSizeHeight)
        var nowOrigin = CGPoint(x: 0, y: estimateOriginY)
        for _ in 0..<requiredNumberCount {
            rects.append(CGRect(origin: nowOrigin, size: requiredNumberViewSize))
            nowOrigin = nowOrigin.offSetBy(dX: estimateNumberViewSizeWidth, dY: 0)
        }
        return rects
    }
    
    private func setViews() {
        subviews.forEach{$0.removeFromSuperview()}
        var views = [AnalogNumberItemView]()
        for itemView in 0..<requiredNumberCount {
            let view = generateNumberView(rect: numberViewRects[itemView])
            view.isRounded = isRoundedStyle
            views.append(view)
        }
        numberViews = views
    }
    
    private func relayoutNumberViews() {
        if let views = numberViews, views.count > 0 {
            for view in views {
                if let index = views.firstIndex(of: view) {
                    view.frame = numberViewRects[index]
                    view.setNeedsDisplay()
                }
            }
        }
    }
    
    private var maximumNumberLevel : Int {
        if requiredNumberCount > 1 {
            var ten = 10
            for _ in 0..<(requiredNumberCount - 2) {
                ten = ten * 10
            }
            return ten
        } else {
            return 1
        }
    }
    
    private func setNumbers(_ numberViewCount: Int) -> [Int] {
        var numbers = [Int]()
        var maximumLevel = maximumNumberLevel
        for _ in 0..<requiredNumberCount {
            if maximumLevel > 1 {
                if dayNumber.absValue/maximumLevel >= 1 {
                    numbers.append(dayNumber.absValue/maximumLevel)
                    maximumLevel = maximumLevel/10
                } else {
                    numbers.append(0)
                    maximumLevel = maximumLevel/10
                }
            } else {
                numbers.append(dayNumber.absValue % 10)
            }
        }
        return numbers
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        relayoutNumberViews()
        checkZeroAvailable()
    }
    
    override func draw(_ rect: CGRect) {
        setViews()
        self.backgroundColor = .clear
        for sequence in 0..<requiredNumberCount {
            addSubview(numberViews![sequence])
        }
    }
}
