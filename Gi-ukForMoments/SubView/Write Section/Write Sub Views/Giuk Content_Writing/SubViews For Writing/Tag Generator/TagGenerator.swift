//
//  TagGenerator.swift
//  Gi-ukForMoments
//
//  Created by goya on 27/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol TagGeneratorDelegate {
    //@objc optional func tagGenerator_DidEndEditNewTag(_ tagGenerator: TagGenerator, senderTextField: UITextField ,text: String?)
    @objc optional func tagGenerator(_ tagGenerator: TagGenerator, needsToCheckAddedItems needed: Bool)
}

class TagGenerator: UIView, TextFieldWithContainerDelegate, HashTagScrollViewDataSource, HashTagScrollViewDelegate {
    
    //MARK: subViews
    weak var delegate : TagGeneratorDelegate?
    
    weak var tagInputTextField: TextFieldWithContainer!
    
    weak var textFieldCover: UIButton_WithIdentifire!
    
    weak var labelContainer: LabelWithContainer!
    
    weak var hashtagView_selected: HashTagScrollView!
    
    weak var hashtagView_library: HashTagScrollView!
    
    weak var placeHolder: UILabel!
    
    weak var libraryButton: UIButton_WithIdentifire!
    //end
    
    //MARK: variables
    var tagManager = TagInformation() {
        didSet {
            checkAndContolPlaceHoldersState()
        }
    }
    
    var isTagAdded: Bool {
        return ((hashtagView_selected?.numberOfTags ?? 0) > 0)
    }
    
    var libraryCollapsed: Bool = true {
        didSet {
            if self.libraryCollapsed {
                libraryButton.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Doted), for: .normal)
            } else {
                libraryButton.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Collaps_Down), for: .normal)
            }
        }
    }
    
    var animating: Bool = false {
        didSet {
            isUserInteractionEnabled = !animating
        }
    }
    //end
    
    private func setOrRepositionTextField() {
        if tagInputTextField == nil {
            let newField = generateUIView(view: tagInputTextField, frame: textInputViewGrid)
            tagInputTextField = newField
            tagInputTextField.backgroundColor = .goyaFontColor
            tagInputTextField.delegate = self
            addSubview(tagInputTextField)
        } else {
            tagInputTextField.setNewFrame(textInputViewGrid)
        }
    }
    
    private func setOrRepositionSelectedHashtagView() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(coverViewTouched(_:)))
        gesture.numberOfTapsRequired = 1
        if hashtagView_selected == nil {
            let newTagView = generateUIView(view: hashtagView_selected, frame: hashtagView_Selceted_Grid)
            hashtagView_selected = newTagView
            hashtagView_selected.tagItemCornerRadius_Percent = 20
            hashtagView_selected.itemMinSize = SizeSources.tagItemMinimumSize
            hashtagView_selected.dataSource = self
            hashtagView_selected.hashTagScrollViewDelegate = self
            hashtagView_selected.backgroundColor = .goyaYellowWhite
            hashtagView_selected.addGestureRecognizer(gesture)
            addSubview(hashtagView_selected)
        } else {
            hashtagView_selected.setNewFrame(hashtagView_Selceted_Grid)
        }
    }
    
    private func setOrRepositionBottomLabel() {
        if labelContainer == nil {
            let newLabelView = generateUIView(view: labelContainer, frame: labelContainer_Grid)
            labelContainer = newLabelView
            labelContainer.text = "LIBRARY"
            labelContainer.textColor = .goyaWhite
            labelContainer.backgroundColor = .goyaFontColor
            addSubview(labelContainer)
        } else {
            labelContainer.setNewFrame(labelContainer_Grid)
        }
    }
    
    private func setOrRepositionLibraryButton() {
        var buttonFrame: CGRect {
            let width = labelContainer_EstimateSize.height * 0.9
            let height = labelContainer_EstimateSize.height * 0.9
            let originX = labelContainer_Grid.width - width - 16
            let originY = (labelContainer_Grid.height - height)/2
            let size = CGSize(width: width, height: height)
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        }
        if libraryButton == nil {
            let newButton = UIButton_WithIdentifire()
            newButton.frame = buttonFrame
            newButton.identifire = "libraryButton"
            newButton.addTarget(self, action: #selector(libraryButtonPressed(_:)), for: .touchUpInside)
            newButton.imageView?.contentMode = .scaleAspectFit
            newButton.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Doted), for: .normal)
            newButton.backgroundColor = .clear
            newButton.setTitleColor(.goyaWhite, for: .normal)
            newButton.titleLabel?.font.withSize(max(buttonFrame.height * 0.618, 10))
            libraryButton = newButton
            labelContainer.addSubview(libraryButton)
        } else {
            libraryButton.setNewFrame(buttonFrame)
            libraryButton.titleLabel?.font.withSize(max(buttonFrame.height * 0.618, 10))
        }
    }
    
    @objc func libraryButtonPressed(_ sender: UIButton_WithIdentifire) {
        animating = true
        libraryCollapsed = !libraryCollapsed
        UIView.animate(withDuration: 0.35, animations: {
            self.layoutSubviews()
        }) { (finished) in
            self.animating = false
        }
    }
    
    private func setOrRepositionLibararyHashTagView() {
        if hashtagView_library == nil {
            let newTagView = generateUIView(view: hashtagView_library, frame: hashtagView_Library_Grid)
            hashtagView_library = newTagView
            hashtagView_library.tagItemCornerRadius_Percent = 20
            hashtagView_library.itemMinSize = SizeSources.tagItemMinimumSize
            hashtagView_library.dataSource = self
            hashtagView_library.hashTagScrollViewDelegate = self
            hashtagView_library.layer.backgroundColor = UIColor.goyaBlack.cgColor
//            hashtagView_library.backgroundColor = .goyaBlack
            addSubview(hashtagView_library)
        } else {
            hashtagView_library.setNewFrame(hashtagView_Library_Grid)
        }
    }
    
    private func setOrRepositionPlaceHolder() {
        // calculate fontsize with devices view height?
//        let maxValue = ((UIScreen.main.bounds.height / 100) * 2.5).absValue.clearUnderDot
//        let minValue = ((UIScreen.main.bounds.height / 100) * 2).absValue.clearUnderDot
//        print("screen height = \(UIScreen.main.bounds.height)")
        
        let fontSize = valueBetweenMinAndMax(maxValue:DescribingSources.sectionsFontSize.maxFontSize.cgFloat, minValue:DescribingSources.sectionsFontSize.minFontSize.cgFloat, mutableValue: (frame.height * 0.0618))
        
        let attributedText = String.generatePlaceHolderMutableAttributedString(fontSize: fontSize, titleText: DescribingSources.choosingTagSection.notice_Title, subTitleText: DescribingSources.choosingTagSection.notice_SubTiltle)
        
        if placeHolder == nil {
            let newHolder = generateUIView(view: placeHolder, frame: hashtagView_selected.frame)
            placeHolder = newHolder
            placeHolder.backgroundColor = .clear
            placeHolder.textColor = .GiukBackgroundColor_depth_1
            placeHolder.numberOfLines = 0
            placeHolder.attributedText = attributedText
            placeHolder.isUserInteractionEnabled = false
            addSubview(placeHolder)
        } else {
            placeHolder.setNewFrame(hashtagView_selected.frame)
            placeHolder.attributedText = attributedText
        }
    }
    
    private func setOrRepositionTextFieldCover() {
        if textFieldCover == nil {
            let coverView = generateUIView(view: textFieldCover, frame: textInputViewGrid)
            textFieldCover = coverView
            textFieldCover.addTarget(self, action: #selector(coverViewTouched(_:)), for: .touchUpInside)
            textFieldCover.imageView?.contentMode = .scaleAspectFit
            textFieldCover.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_TagAdd)?.withRenderingMode_alwaysTemplate, for: .normal)
            textFieldCover.tintColor = .goyaWhite
            textFieldCover.backgroundColor = .goyaFontColor
            addSubview(textFieldCover)
        } else {
            textFieldCover.setNewFrame(textInputViewGrid)
        }
    }
    
    @objc func coverViewTouched(_ sender: UIView) {
        if !textFieldCover.isHidden {
            textFieldCover.isHidden = true
            tagInputTextField.textField.becomeFirstResponder()
        } else {
            return
        }
    }
    
    
    func checkAndContolPlaceHoldersState() {
        if isTagAdded {
            if placeHolder.isHidden == false {
                placeHolder.isHidden = true
            }
        } else {
            if placeHolder.isHidden == true {
                placeHolder.isHidden = false
            }
        }
    }
    
    //MARK: TextInputView delegate
    func textFieldWithContainer_DidEndEditing(_ textFieldInContainer: UITextField, text: String?, expectedEndEditingState: Bool) {
        if let inputText = text {
            tagManager.addTags(tag: inputText)
        } else {
            textFieldInContainer.endEditing(expectedEndEditingState)
            textFieldCover?.isHidden = false
        }
        
        if expectedEndEditingState {
            textFieldInContainer.endEditing(expectedEndEditingState)
            textFieldCover?.isHidden = false
        }
        
        textFieldInContainer.text = ""
        hashtagView_selected.reloadData()
        checkAndContolPlaceHoldersState()
//        delegate?.tagGenerator_DidEndEditNewTag?(self, senderTextField: textFieldInContainer, text: text)
        delegate?.tagGenerator?(self, needsToCheckAddedItems: true)
    }
    //end
    
    //MARK: HashtagScrollView datasource
    func hashTagScrollView_tagItems(_ hashTagScrollView: HashTagScrollView) -> [String]? {
        if hashTagScrollView == hashtagView_selected {
            return tagManager.addedTags
        } else {
            return tagManager.library
        }
    }
    //end
    
    //MARK: HashTagScrollView delegate
    func hashTagScrollView(_ hashTagScrollView: HashTagScrollView, didSelectItemAt item: Int, tag: String) {
        if hashTagScrollView == hashtagView_selected {
            tagManager.removeTags(tag: tag)
            hashTagScrollView.removeHashItem(at: item)
            checkAndContolPlaceHoldersState()
            delegate?.tagGenerator?(self, needsToCheckAddedItems: true)
        } else {
            tagManager.addTags(tag: tag)
            reloadData()
            checkAndContolPlaceHoldersState()
            delegate?.tagGenerator?(self, needsToCheckAddedItems: true)
        }
    }
    //end
    
    func reloadData() {
        hashtagView_selected.reloadData()
        hashtagView_library.reloadData()
        checkAndContolPlaceHoldersState()
    }
    
    private func setOrRepostionAllViews() {
        setOrRepositionTextField()
        setOrRepositionTextFieldCover()
        setOrRepositionSelectedHashtagView()
        setOrRepositionBottomLabel()
        setOrRepositionLibraryButton()
        setOrRepositionLibararyHashTagView()
        setOrRepositionPlaceHolder()
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

}

extension TagGenerator {
    //MARK: Grid Information
    
    // - sizes
    var textInputView_EstimateSize: CGSize {
        let width = bounds.width
        let height = max((bounds.height * 0.0618).clearUnderDot, 40)
        let size = CGSize(width: width, height: height)
        return size
    }
    
    var labelContainer_EstimateSize: CGSize {
        let width = bounds.width
        let height = max((bounds.height * 0.0618).clearUnderDot, 35)
        let size = CGSize(width: width, height: height)
        return size
    }
    
    var leftOverHeight: CGFloat {
        return bounds.height - (textInputView_EstimateSize.height + labelContainer_EstimateSize.height)
    }
    
    var hashtagView_EstimateSize: CGSize {
        let width = bounds.width
        let height = leftOverHeight/2
        return CGSize(width: width, height: height)
    }
    
    var hashTagView_Selected_Size_LibraryCollapsed: CGSize {
        let width = bounds.width
        let height = bounds.height - textInputView_EstimateSize.height - labelContainer_EstimateSize.height
        return CGSize(width: width, height: height)
    }
    //
    
    
    // - rects
    var _hashTagView_Selected_Size_LibraryCollapsed: CGSize {
        let width = bounds.width
        let height = bounds.height - (textInputView_EstimateSize.height + labelContainer_EstimateSize.height)
        return CGSize(width: width, height: height)
    }
    
    var _hashtagView_Selected_Grid_LibraryCollapsed: CGRect {
        let origin = CGPoint(x: 0, y: textInputViewGrid.maxY)
        return CGRect(origin: origin, size: hashTagView_Selected_Size_LibraryCollapsed)
    }
    
    var _hashtagView_Selceted_Grid_LibraryExtened: CGRect {
        let origin = CGPoint(x: 0, y: textInputViewGrid.maxY)
        return CGRect(origin: origin, size: hashtagView_EstimateSize)
    }
    
    var hashtagView_Selceted_Grid: CGRect {
        if libraryCollapsed {
            return _hashtagView_Selected_Grid_LibraryCollapsed
        } else {
            return _hashtagView_Selceted_Grid_LibraryExtened
        }
    }
    
    var textInputViewGrid: CGRect {
        let originY : CGFloat = 0//bounds.height - textInputView_EstimateSize.height
        let origin = CGPoint(x: 0, y: originY)
        return CGRect(origin: origin, size: textInputView_EstimateSize)
    }
    
    var labelContainer_Grid: CGRect {
        let origin = CGPoint(x: 0, y: hashtagView_Selceted_Grid.maxY)
        return CGRect(origin: origin, size: labelContainer_EstimateSize)
    }
    
    var hashtagView_Library_Grid: CGRect {
        if libraryCollapsed {
            return _hashtagView_Library_Grid_LibraryCollapsed
        } else {
            return _hashtagView_Library_Grid_LibraryExtended
        }
    }
    
    var _hashtagView_Library_Grid_LibraryCollapsed: CGRect {
        let origin = CGPoint(x: 0, y: labelContainer_Grid.maxY)
        return CGRect(origin: origin, size: CGSize(width: bounds.width, height: 0))
    }
    
    var _hashtagView_Library_Grid_LibraryExtended: CGRect {
        let origin = CGPoint(x: 0, y: bounds.height - hashtagView_EstimateSize.height)
        return CGRect(origin: origin, size: hashtagView_EstimateSize)
    }
    //
    //end
}
