//
//  PageCounterLabel.swift
//  Gi-ukForMoments
//
//  Created by goya on 24/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

protocol PageCounterLabelDatasource: class {
    func numberOfPages(_ counterLabel: PageCounterLabel) -> Int?
}

@objc protocol PageCounterLabelDelegate {
    func pageCounterLabel_NeedToUpdatePage(_ counterLabel: PageCounterLabel) -> Int
}

extension Int {
    var string: String {
        return String(self)
    }
}

class PageCounterLabel: UILabel {
    
    weak var dataSource: PageCounterLabelDatasource?
    
    var numberOfPages: Int? {
        return dataSource?.numberOfPages(self)
    }
    
    func updateCounterWithPage(_ page: Int) {
        guard let pages = self.numberOfPages else {
            attributedText = nil
            return
        }
        
        if page <= pages {
            let pageString = page.string
            let seperator = " / "
            let pagesString = pages.string
            let fullString = pageString + seperator + pagesString
            let attrString = fullString.centeredAttributedString(fontSize: fontSize, type: .bold)
            attributedText = attrString
        } else {
            attributedText = noPages
        }
    }
    
    var noPages: NSAttributedString {
        return "nopages".centeredAttributedString(fontSize: fontSize)
    }
    
    var fontSize: CGFloat {
        return min(frame.height * 0.618, 15)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        font = UIFont.appleSDGothicNeo.regular.font(size: fontSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        font = UIFont.appleSDGothicNeo.regular.font(size: fontSize)
        textAlignment = .center
        textColor = .goyaWhite
//        attributedText = noPages
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        font = UIFont.appleSDGothicNeo.regular.font(size: fontSize)
        textAlignment = .center
        textColor = .goyaWhite
//        attributedText = noPages
    }
}
