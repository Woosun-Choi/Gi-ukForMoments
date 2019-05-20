//
//  HashTagScrollView.swift
//  infinitePageViewTest
//
//  Created by goya on 14/11/2018.
//  Copyright © 2018 goya. All rights reserved.
//

import UIKit

class HashTagScrollView: UIScrollView {
    
    enum hashTagScrollViewCase {
        case addingType
        case categoryType
    }
    
    var viewType : hashTagScrollViewCase = .addingType
    
    var labelView : UILabel!
    
    var hashTagView : HashTagView!
    
    private var viewHeight: CGFloat {
        if hashTagView != nil && labelView != nil {
            return labelView.frame.height + hashTagView.frame.height + (generalSettings.topAndBottomMargins * 2)
        } else if labelView != nil && hashTagView == nil {
            return labelView.frame.height + (generalSettings.topAndBottomMargins * 2)
        } else if labelView == nil && hashTagView != nil {
            return hashTagView.frame.height + (generalSettings.topAndBottomMargins * 2)
        } else {
            return 0
        }
    }
    
    private var viewSize : CGSize {
        if hashTagView != nil {
            return CGSize(width: self.frame.width, height: viewHeight)
        } else {
            return CGSize(width: self.frame.width, height: viewHeight)
        }
    }
    
    private var inSetMargin : CGPoint = generalSettings.defaultInSetMargin
    
    private var expectedInViewsWidth : CGFloat {
        return self.frame.width - (generalSettings.leftAndRightMargins * 2)
    }
    
    private func createLabelView() -> UILabel {
        let label = UILabel()
        label.frame.origin = inSetMargin
        label.numberOfLines = 0
        label.frame.size.width = expectedInViewsWidth
        addSubview(label)
        labelView = label
        return label
    }
    
    private lazy var _textLabel : UILabel = {
        let label = UILabel()
        label.setLabelAsSDStyle(type: .body)
        label.frame.origin = inSetMargin
        label.numberOfLines = 0
        label.frame.size.width = expectedInViewsWidth
        addSubview(label)
        labelView = label
        return label
    }()
    
    func configureLabel(comment: String) {
        _textLabel.text = comment
        labelView.sizeToFit()
    }
    
    private func createHashTagView() -> HashTagView {
        let view = HashTagView()
        view.backgroundColor = UIColor.clear
        view.frame.origin = inSetMargin
        view.frame.size.width = expectedInViewsWidth
        addSubview(view)
        hashTagView = view
        return view
    }
    
    func configureHashTagView(tag : [String]) {
        createHashTagView().tags = nil
        var requestType: HashTagItemView.requestedHashTagManagement!
        (viewType == .categoryType) ? (requestType = .addToSavingContent) : (requestType = .removeFromSavingContent)
        hashTagView.tags = (tag, requestType)
    }
    
    private func updateLayouts() {
        labelView?.frame.size.width = expectedInViewsWidth
        if labelView != nil {
            inSetMargin = inSetMargin.offSetBy(dX: 0, dY: labelView!.frame.height + (generalSettings.topAndBottomMargins/2))
        }
        hashTagView?.frame.origin = inSetMargin
        hashTagView?.frame.size.width = expectedInViewsWidth
        contentSize = viewSize
        inSetMargin = generalSettings.defaultInSetMargin
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if self.subviews.count > 0 {
            updateLayouts()
        }
    }
    
    override func draw(_ rect: CGRect) {
    }
}

extension HashTagScrollView {
    
    struct generalSettings {
        static var leftAndRightMargins : CGFloat = 8
        static var topAndBottomMargins : CGFloat = 8
        static var defaultInSetMargin : CGPoint {
            return CGPoint(x: leftAndRightMargins, y: topAndBottomMargins)
        }
    }
    
    convenience init(viewType: hashTagScrollViewCase) {
        self.init()
        self.viewType = viewType
    }
}
