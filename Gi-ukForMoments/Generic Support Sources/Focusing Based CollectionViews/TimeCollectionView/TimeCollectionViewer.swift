//
//  TimeCollectionViewer.swift
//  LinearTimeLineViewDemo
//
//  Created by goya on 09/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class TimeCollectionViewer: UIView, UICollectionViewDataSource, FocusingIndexBasedCollectionViewDelegate {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        generateTimeView()
        requestedDate = Date.currentDate
        clipsToBounds = true
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        generateTimeView()
        requestedDate = Date.currentDate
        clipsToBounds = true
        self.backgroundColor = UIColor.clear
    }
    
    enum CalenderDisplayType {
        case showAll
        case showBeforeCurrentDateOnly
    }
    
    var calenderDisplayType: CalenderDisplayType = .showBeforeCurrentDateOnly {
        didSet {
            nowDate = _nowDate
        }
    }
    
    var timeView: TimeCollectionView!
    
    var expectedMarginForTimeView: CGFloat {
        return self.frame.height * 0.05
    }
    
    var timeViewFrame: CGRect {
        let originX: CGFloat = 0
        let originY: CGFloat = expectedMarginForTimeView
        let height: CGFloat = frame.height - (expectedMarginForTimeView * 2)
        let width: CGFloat = frame.width
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    private var requestedDate: Date?
    
    private var dates = [Date]()
    
    private var _nowDate : Date!
    
    var requestedFunctionWhenNowDateChanged: ((Date) -> Void)?
    
    var requestedFunctionWhenCellDidSelected: ((TimeCollectionView, IndexPath, UICollectionViewCell) -> Void)?
    
    var nowDate: Date {
        get {
            return _nowDate
        } set {
            requestedDate = newValue
            updateTimeViewWithRequestedDate()
        }
    }
    
    private var updateRequested: Bool = false {
        didSet {
            if updateRequested {
                refreshDatesWithOrigin(date: _nowDate)
            }
        }
    }
    
    var timeViewBackGroundColor: UIColor = .clear {
        didSet {
            timeView.backgroundColor = self.timeViewBackGroundColor
        }
    }
    
    private func updateTimeViewWithRequestedDate() {
        if requestedDate != nil {
            _nowDate = requestedDate
            updateRequested = true
            requestedDate = nil
            requestedFunctionWhenNowDateChanged?(nowDate)
        }
    }
    
    private func generateTimeView() {
        if timeView == nil {
            print("timeViewer initialized")
            let nibName = ColorCollectionViewCell.reuseIdentifier
            timeView = TimeCollectionView(frame: timeViewFrame, collectionViewLayout: UICollectionViewLayout())
            timeView.register(UINib(nibName: nibName, bundle: nil), forCellWithReuseIdentifier: nibName)
            timeView.focusingCollectionViewDelegate = self
            timeView.dataSource = self
            timeView.backgroundColor = timeViewBackGroundColor
            addSubview(timeView)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as! ColorCollectionViewCell
        cell.clipsToBounds = true
        cell.date = dates[indexPath.row]
        return cell
    }
    
    private func generateAWeakBothSideFrom(date: Date) {
        dates.removeAll()
        var newDates = [Date]()
        for distance in -7...7 {
            let newDate = date.dateWithDistance(distance: distance)!
            if calenderDisplayType == .showBeforeCurrentDateOnly {
                if newDate <= Date.currentDate {
                    newDates.append(newDate)
                }
            } else {
                newDates.append(newDate)
            }
        }
        newDates.sort {$0 < $1}
        dates = newDates
    }
    
    private func addMoreDateFrom(date: Date) -> Int {
        var addedDateCount = 0
        var aDate = date.dateWithDateComponents
        for distance in 1...7 {
            aDate = date.setNewDateWithDistanceFromDate(direction: .present, from: date, distance: distance)!
            dates.insert(aDate, at: 0)
            addedDateCount += 1
        }
        return addedDateCount
    }
    
    func addDateLinearly(date: Date) {
        // Adding Date linearly - getting longer
        if let checkedDate = dates.firstIndex(of: date) {
            if checkedDate < 5 && updateRequested {
                let expectedDistance = addMoreDateFrom(date: dates[0])
                let checkPoint = dates[checkedDate + expectedDistance]
                guard let checkIndex = dates.firstIndex(of: checkPoint) else { return }
                let targetIndex = IndexPath(item: checkIndex, section: 0)
                timeView.setStartState(with: targetIndex) { [weak self] in
                    self?.updateRequested = false
                    self?.requestedFunctionWhenNowDateChanged?(date)
                }
            }
        }
    }
    
    func refreshDatesWithOrigin(date: Date) {
        // Refresh Dates limitly - short
        generateAWeakBothSideFrom(date: date)
        guard let nowData = dates.firstIndex(of: date) else { return }
        let targetIndex = IndexPath(item: nowData, section: 0)
        timeView.setStartState(with: targetIndex) { [weak self] in
            self?.updateRequested = false
            self?.requestedFunctionWhenNowDateChanged?(date)
        }
    }
    
    func collectionViewDidSelectFocusedIndex(_ collectionView: UICollectionView, focusedIndex: IndexPath, cell: UICollectionViewCell) {
        if let currentColletionView = collectionView as? TimeCollectionView {
            requestedFunctionWhenCellDidSelected?(currentColletionView,focusedIndex,cell)
        }
    }
    
    func collectionViewDidEndScrollToIndex(_ collectionView: UICollectionView, finished: Bool) {
        updateRequested = finished
    }
    
    func collectionViewDidUpdateFocusingIndex(_ collectionView: UICollectionView, with: IndexPath) {
        if let cell = collectionView.cellForItem(at: with) as? ColorCollectionViewCell {
            if _nowDate != cell.date {
                _nowDate = cell.date!
            }
            checkFocusedCell()
        }
    }
    
    private func checkFocusedCell() {
        for i in 0..<timeView.numberOfItems(inSection: 0) {
            let index = IndexPath(item: i, section: 0)
            if let targetCell = timeView.cellForItem(at: index) as? ColorCollectionViewCell {
                if targetCell.date == nowDate {
                    targetCell.layer.cornerRadius = min(timeView.frame.height, timeView.frame.width) * 0.1618
                    if targetCell.date?.weekDay == 1 {
                        targetCell.backgroundColor = .goyaRoseGoldColor
                        targetCell.numberView.numberColor = .goyaBlack
                    } else {
                        targetCell.backgroundColor = .goyaWhite
                        targetCell.numberView.numberColor = .goyaBlack
                    }
                } else {
                    targetCell.backgroundColor = .clear
                    targetCell.layer.cornerRadius = 0
                    if targetCell.date?.weekDay == 1 {
                        targetCell.numberView.numberColor = .goyaRoseGoldColor
                    } else {
                        targetCell.numberView.numberColor = .goyaWhite
                    }
                }
            }
        }
    }
    
    private func reLayoutTimeColletionView() {
        timeView.frame = timeViewFrame
    }
    
    override func layoutSubviews() {
        print("timeViewer - layoutSubviews get called")
        super.layoutSubviews()
        reLayoutTimeColletionView()
        timeView.setNeedsLayout()
    }
    
    override func draw(_ rect: CGRect) {
        print("timeViewer - draw get called")
        reLayoutTimeColletionView()
        updateTimeViewWithRequestedDate()
    }

}
