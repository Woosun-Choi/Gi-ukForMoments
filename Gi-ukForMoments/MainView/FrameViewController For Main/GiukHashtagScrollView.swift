//
//  GiukHashtagScrollView.swift
//  Gi-ukForMoments
//
//  Created by goya on 22/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class GiukHashtagScrollView: HashTagScrollView {
    
    weak var placeHolder: UILabel!
    
    private func setOrRepositionPlaceHolder() {
        let placeHolerFrame = CGRect(origin: CGPoint.zero, size: frame.size)
        let fontSize = valueBetweenMinAndMax(maxValue: DescribingSources.sectionsFontSize.maxFontSize.cgFloat, minValue: DescribingSources.sectionsFontSize.minFontSize.cgFloat, mutableValue: (frame.height * 0.0618))
        let attributedText = DescribingSources.MainTagView.centeredImageSource()
        attributedText.append(String.generatePlaceHolderMutableAttributedString(fontSize: fontSize, titleText: DescribingSources.MainTagView.notice_Title, subTitleText: DescribingSources.MainTagView.notice_SubTiltle))
        
        if placeHolder == nil {
            let newHolder = generateUIView(view: placeHolder, frame: placeHolerFrame)
            placeHolder = newHolder
            placeHolder.setLabelAsSDStyleWithSpecificFontSize(fontSize: fontSize)
            placeHolder.textColor = .GiukBackgroundColor_depth_1
            placeHolder.numberOfLines = 0
            placeHolder.attributedText = attributedText
            addSubview(placeHolder)
        } else {
            placeHolder.setNewFrame(placeHolerFrame)
            placeHolder.attributedText = attributedText
        }
    }
    
    private func checkPlaceHolderShouldBeExist() {
        if numberOfTags > 0 {
            placeHolder?.isHidden = true
        } else {
            setOrRepositionPlaceHolder()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkPlaceHolderShouldBeExist()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrRepositionPlaceHolder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRepositionPlaceHolder()
    }

}
