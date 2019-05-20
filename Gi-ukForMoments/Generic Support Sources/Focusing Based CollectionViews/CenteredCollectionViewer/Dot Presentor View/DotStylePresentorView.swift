//
//  DotStylePresentorView.swift
//  DontPanic
//
//  Created by goya on 17/03/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

protocol DotStylePresentorViewDatasource: class {
    func numberOfItemsForDotPresentor() -> Int
}

class DotStylePresentorView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = .clear
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(frame: CGRect, dotColor: UIColor) {
        self.init(frame: frame)
        self.dotColor = dotColor
    }
    
    weak var datasource : DotStylePresentorViewDatasource?
    
    private var dotViews : [CircleView]?
    
    private var nowIndex = 0 {
        didSet {
            updateDotsLayOut()
        }
    }
    
    private var dotColor: UIColor = .gray {
        didSet {
            reloadData()
        }
    }
    
    var dotAnimationAllowed = false
    
    private var numberOfDots: Int {
        if let source = datasource {
            return source.numberOfItemsForDotPresentor()
        } else {
            return 0
        }
    }
    
    private var disPlayedDots: Int {
        if numberOfDots < 5 {
            return numberOfDots
        } else {
            return 5
        }
    }
    
    private var maxIndex: Int {
        if numberOfDots > 1 {
            return numberOfDots - 1
        } else {
            return 0
        }
    }
    
    var minSpacing: CGFloat?
    
    var dotSize: CGFloat = 15
    
    private func standardDotOrigins() -> [CGPoint] {
        let expectedArea = requiredArea
        let firstOriginX = (bounds.width - expectedArea.width)/2
        let firstOriginY = (bounds.height - expectedArea.height)/2
        var nowOrigin = CGPoint(x: firstOriginX, y: firstOriginY)
        var origins = [nowOrigin]
        if numberOfDots > 1 {
            for _ in 1...(numberOfDots - 1) {
                let expectedMargin = dotSize + expectedMinSpacing
                nowOrigin = nowOrigin.offSetBy(dX: expectedMargin, dY: 0)
                origins.append(nowOrigin)
            }
        }
        return origins
    }
    
    private func centerLimitiedDotOrigin() -> [CGPoint]? {
        if numberOfDots > 5 {
            let expectedArea = requiredArea
            let firstOriginX = (bounds.width - expectedArea.width)/2
            let firstOriginY = (bounds.height - expectedArea.height)/2
            var nowOrigin = CGPoint(x: firstOriginX, y: firstOriginY)
            var origins = [nowOrigin]
            for _ in 1...4 {
                let expectedMargin = dotSize + expectedMinSpacing
                nowOrigin = nowOrigin.offSetBy(dX: expectedMargin, dY: 0)
                origins.append(nowOrigin)
            }
            return origins
        } else {
            return nil
        }
    }
    
    private func setDots() {
        if dotViews == nil || numberOfDots != dotViews?.count {
            self.subviews.forEach { $0.removeFromSuperview() }
            dotViews = nil
            if numberOfDots > 0 {
                for _ in 1...(numberOfDots) {
                    let dotView = CircleView()
                    dotView.dotColor = dotColor
                    (dotViews == nil) ? (dotViews = [dotView]) : dotViews?.append(dotView)
                    addSubview(dotView)
                }
            }
        }
    }
    
    private func centerLimitiedLayoutDots() {
        guard let positions = centerLimitiedDotOrigin(), let dots = dotViews else { return }
        let startPosition = positions[0]
        let startingPosition = startPosition.offSetBy(dX: -dotSize/2, dY: dotSize/2)
        let expectedMargin = dotSize + expectedMinSpacing
        let endPosition = positions.last?.offSetBy(dX: expectedMargin, dY: 0)
        let endingPostion = endPosition?.offSetBy(dX: dotSize/2, dY: dotSize/2)
        let normalSize = CGSize(width: dotSize, height: dotSize)
        let minSize = CGSize(width: 0, height: dotSize)
        let zeroSize = CGSize.zero
        
        var isMiddleOfRange: Bool {
            if nowIndex > 2 && nowIndex < (maxIndex - 2) {
                return true
            } else {
                return false
            }
        }
        
        if isMiddleOfRange {
            for dotItem in dots {
                if let dotIndex = dots.firstIndex(of: dotItem) {
                    let expectedPositionIndex = dotIndex - nowIndex + 2
                    if expectedPositionIndex < 0 {
                        dotItem.frame = CGRect(origin: startingPosition, size: zeroSize)
                    } else if expectedPositionIndex > 4 {
                        dotItem.frame = CGRect(origin: endingPostion!, size: zeroSize)
                    } else {
                        dotItem.frame = CGRect(origin: positions[expectedPositionIndex], size: normalSize)
                    }
                }
            }
        } else {
            if nowIndex <= 2 {
                for dotItem in dots {
                    if let dotIndex = dots.firstIndex(of: dotItem) {
                        if dotIndex < 5 {
                            dotItem.frame = CGRect(origin: positions[dotIndex], size: normalSize)
                        } else {
                            dotItem.frame = CGRect(origin: endingPostion!, size: zeroSize)
                        }
                    }
                }
            } else if nowIndex >= (maxIndex - 2) {
                for dotItem in dots {
                    if let dotIndex = dots.firstIndex(of: dotItem) {
                        if dotIndex <= (maxIndex) - 5 {
                            dotItem.frame = CGRect(origin: startingPosition, size: zeroSize)
                        } else {
                            let expectedPositionIndex = ((maxIndex) - dotIndex - 4).absValue
                            dotItem.frame = CGRect(origin: positions[expectedPositionIndex], size: normalSize)
                        }
                    }
                }
            }
        }
        
        updateDotIndex()
    }
    
    private func layOutDots() {
        let positions = standardDotOrigins()
        if let dots = dotViews {
            if numberOfDots > 0 {
                for item in dots.indices {
                    dots[item].frame = CGRect(origin: positions[item], size: CGSize(width: dotSize, height: dotSize))
                }
            }
        }
        updateDotIndex()
    }
    
    private func updateDotIndex() {
        if nowIndex < numberOfDots {
            if let dotSection = dotViews {
                dotSection.forEach { $0.state = checkDistanceFromNowIdex(dotIndex: $0)}
            }
        }
    }
    
    private func checkDistanceFromNowIdex(dotIndex : CircleView) -> CircleView.presentCase {
        guard let dotsIndex = dotViews?.firstIndex(of: dotIndex) else {return .enable}
        let distance = (nowIndex - dotsIndex).absValue
        if distance > 1 {
            return .far
        } else if distance == 1 {
            return .close
        } else {
            return .enable
        }
    }
    
    private func updateDotsLayOut() {
        if (numberOfDots > 5) {
            (dotAnimationAllowed) ?
                (UIView.animate(withDuration: 0.3) {
                    [unowned self] in
                    self.centerLimitiedLayoutDots() })
                : centerLimitiedLayoutDots()
        } else {
            layOutDots()
        }
    }
    
    override func layoutSubviews() {
        updateDotsLayOut()
    }

    override func draw(_ rect: CGRect) {
        setDots()
    }
    
    
    //MARK: Calling functions
    func updateDotIndexWith(indexItem: Int) {
        self.nowIndex = indexItem
    }
    
    func requestDotColorChangeWith(color: UIColor) {
        self.dotColor = color
    }
    
    func reloadData() {
        setDots()
        updateDotsLayOut()
    }
    
}

extension DotStylePresentorView {
    
    private var expectedMinSpacing: CGFloat {
        return (minSpacing == nil) ? (dotSize/3) : minSpacing!
    }
    
    private var expectedFullWidth: CGFloat {
        return (dotSize * CGFloat(disPlayedDots)) + (expectedMinSpacing * CGFloat(disPlayedDots - 1))
    }
    
    private var widthLimit: CGFloat {
        return self.bounds.width - (expectedMinSpacing * 2)
    }
    
    private var heightLimit: CGFloat {
        return self.bounds.height - (expectedMinSpacing * 2)
    }
    
    private var requiredArea: CGSize {
        if expectedFullWidth > widthLimit || dotSize + (expectedMinSpacing * 2) > heightLimit {
            return resizeDotAndRecalculateArea()
        } else {
            return CGSize(width: expectedFullWidth, height: dotSize + (expectedMinSpacing * 2))
        }
    }
    
    private func resizeDotAndRecalculateArea() -> CGSize {
        if expectedFullWidth > widthLimit {
            while expectedFullWidth > widthLimit {
                dotSize -= 0.1
            }
            return CGSize(width: expectedFullWidth, height: dotSize + (expectedMinSpacing * 2))
        } else {
            while dotSize > heightLimit * (3/5) {
                dotSize -= 0.1
            }
            minSpacing = dotSize/3
            return CGSize(width: expectedFullWidth, height: dotSize + (expectedMinSpacing * 2))
        }
    }
    
    private var requiredSize: CGFloat {
        let fullWidth = bounds.width - (expectedMinSpacing * CGFloat(disPlayedDots + 2))
        return fullWidth/CGFloat(disPlayedDots)
    }
}
