//
//  TagGenerator.swift
//  Gi-ukForMoments
//
//  Created by goya on 27/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol TagGeneratorDelegate {
    @objc optional func tagGenerator_DidEndEditNewTag(_ tagGenerator: TagGenerator, senderTextField: UITextField ,text: String)
}

class TagGenerator: UIView, TextFieldWithContainerDelegate, HashTagScrollViewDataSource, HashTagScrollViewDelegate {
    
    var tagManager = TagInformation()
    
    weak var delegate : TagGeneratorDelegate?
    
    weak var tagInputTextField: TextFieldWithContainer!
    
    weak var labelContainer_Top: LabelWithContainer!
    
    weak var labelContainer_Bottom: LabelWithContainer!
    
    weak var hashtagView_selected: HashTagScrollView!
    
    weak var hashtagView_library: HashTagScrollView!
    
    
    private func setOrRepositionTextField() {
        if tagInputTextField == nil {
            let newField = generateUIView(view: tagInputTextField, frame: topContainerGrid)
            tagInputTextField = newField
            tagInputTextField.backgroundColor = .goyaFontColor
            tagInputTextField.delegate = self
            addSubview(tagInputTextField)
        } else {
            tagInputTextField.setNewFrame(topContainerGrid)
        }
    }
    
    private func setOrRepositionTopLabel() {
        if labelContainer_Top == nil {
            let newLabelView = generateUIView(view: labelContainer_Top, frame: labelContainer_Top_Grid)
            labelContainer_Top = newLabelView
            labelContainer_Top.text = "ADDED"
            labelContainer_Top.textColor = .goyaWhite
            labelContainer_Top.backgroundColor = .goyaFontColor
            addSubview(labelContainer_Top)
        } else {
            labelContainer_Top.setNewFrame(labelContainer_Top_Grid)
        }
    }
    
    private func setOrRepositionSelectedHashtagView() {
        if hashtagView_selected == nil {
            let newTagView = generateUIView(view: hashtagView_selected, frame: hashtagView_selected_Grid)
            hashtagView_selected = newTagView
            hashtagView_selected.dataSource = self
            hashtagView_selected.hashTagScrollViewDelegate = self
            hashtagView_selected.backgroundColor = .goyaYellowWhite
            addSubview(hashtagView_selected)
        } else {
            hashtagView_selected.setNewFrame(hashtagView_selected_Grid)
        }
    }
    
    private func setOrRepositionBottomLabel() {
        if labelContainer_Bottom == nil {
            let newLabelView = generateUIView(view: labelContainer_Bottom, frame: labelContainer_Bottom_Grid)
            labelContainer_Bottom = newLabelView
            labelContainer_Bottom.text = "LIBRARY"
            labelContainer_Bottom.textColor = .goyaWhite
            labelContainer_Bottom.backgroundColor = .goyaFontColor
            addSubview(labelContainer_Bottom)
        } else {
            labelContainer_Bottom.setNewFrame(labelContainer_Bottom_Grid)
        }
    }
    
    private func setOrRepositionLibararyHashTagView() {
        if hashtagView_library == nil {
            let newTagView = generateUIView(view: hashtagView_library, frame: hashtagView_library_Grid)
            hashtagView_library = newTagView
            hashtagView_library.dataSource = self
            hashtagView_library.hashTagScrollViewDelegate = self
            hashtagView_library.backgroundColor = .goyaYellowWhite
            addSubview(hashtagView_library)
        } else {
            hashtagView_library.setNewFrame(hashtagView_library_Grid)
        }
    }
    
    func textFieldWithContainer_DidEndEditing(_ textFieldInContainer: UITextField, text: String, expectedEndEditingState: Bool) {
        tagManager.addTags(tag: text)
        if expectedEndEditingState {
            textFieldInContainer.endEditing(expectedEndEditingState)
        }
        textFieldInContainer.text = ""
        hashtagView_selected.reloadData()
    }
    
    func hashTagScrollView_tagItems(_ hashTagScrollView: HashTagScrollView) -> [String]? {
        if hashTagScrollView == hashtagView_selected {
            return tagManager.addedTags
        } else {
            return tagManager.library
        }
    }
    
    func hashTagScrollView(_ hashTagScrollView: HashTagScrollView, didSelectItemAt item: Int, tag: String) {
        if hashTagScrollView == hashtagView_selected {
            tagManager.removeTags(tag: tag)
            hashTagScrollView.removeHashItem(at: item)
        } else {
            tagManager.addTags(tag: tag)
            reloadData()
        }
    }
    
    func reloadData() {
        hashtagView_selected.reloadData()
        hashtagView_library.reloadData()
    }
    
    private func setOrRepostionAllViews() {
        setOrRepositionTextField()
        setOrRepositionTopLabel()
        setOrRepositionSelectedHashtagView()
        setOrRepositionBottomLabel()
        setOrRepositionLibararyHashTagView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setOrRepostionAllViews()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRepostionAllViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrRepostionAllViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRepostionAllViews()
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var topContainer_EstimateSize: CGSize {
        let width = bounds.width
        let height = max((bounds.height * 0.0618).clearUnderDot, 40)
        let size = CGSize(width: width, height: height)
        return size
    }
    
    var topContainerGrid: CGRect {
        let origin = CGPoint.zero
        return CGRect(origin: origin, size: topContainer_EstimateSize)
    }
    
    var labelContainer_EstimateSize: CGSize {
        let width = bounds.width
        let height = max((bounds.height * 0.0618).clearUnderDot, 35)
        let size = CGSize(width: width, height: height)
        return size
    }
    
    var labelContainer_Top_Grid: CGRect {
        let origin = CGPoint(x: 0, y: topContainerGrid.maxY)
        return CGRect(origin: origin, size: labelContainer_EstimateSize)
    }
    
    var labelContainer_Bottom_Grid: CGRect {
        let origin = CGPoint(x: 0, y: hashtagView_selected_Grid.maxY)
        return CGRect(origin: origin, size: labelContainer_EstimateSize)
    }
    
    var leftOverHeight: CGFloat {
        return bounds.height - (topContainerGrid.height + (labelContainer_EstimateSize.height * 2))
    }
    
    var hashtagView_EstimateSize: CGSize {
        let width = bounds.width
        let height = leftOverHeight/2
        return CGSize(width: width, height: height)
    }
    
    var hashtagView_selected_Grid: CGRect {
        let origin = CGPoint(x: 0, y: labelContainer_Top_Grid.maxY)
        return CGRect(origin: origin, size: hashtagView_EstimateSize)
    }
    
    var hashtagView_library_Grid: CGRect {
        let origin = CGPoint(x: 0, y: labelContainer_Bottom_Grid.maxY)
        return CGRect(origin: origin, size: hashtagView_EstimateSize)
    }

}
