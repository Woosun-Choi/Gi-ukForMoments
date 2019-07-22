//
//  Giuk_ContentView_WriteSection.swift
//  Gi-ukForMoments
//
//  Created by goya on 25/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class FadingButton: UIButton_WithIdentifire {
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                UIView.animate(withDuration: 0.15) {
                    self.imageView?.alpha = 1
                    self.titleLabel?.alpha = 1
                }
            } else {
                UIView.animate(withDuration: 0.15) {
                    self.imageView?.alpha = 0.4
                    self.titleLabel?.alpha = 0.4
                }
            }
        }
    }
}

@objc protocol Giuk_ContentView_WriteSection_Delegate {
    @objc optional func writeSection(_ writeSection : Giuk_ContentView_WriteSection, didEndEditing: Bool, wrotedData: CreatedData)
    @objc optional func writeSection(_ writeSection : Giuk_ContentView_WriteSection, needRepresentedImageData imageData: Data) -> UIImage?
}

extension UIButton_WithIdentifire {
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                tintColor = .goyaFontColor
            } else {
                tintColor = UIColor.goyaFontColor.withAlphaComponent(0.25)
            }
        }
    }
}

class Giuk_ContentView_WriteSection: Giuk_ContentView, GenericMultiButtonViewDataSource, GenericMultiButtonViewDelegate, GiukContentView_WritingDelegate {
    
    weak var dataSource: GiukContentView_WritingDatasource? {
        didSet {
            writingView.dataSource = dataSource
        }
    }
    
    weak var delegate: Giuk_ContentView_WriteSection_Delegate?
    
    //writingstate controls the subviews state.
    var writingState: WritingState {
        get {
            return writingView.writingState
        } set {
            writingView.writingState = newValue
        }
    }
    
    weak var topContainer: UIView!
    
    weak var writingView: Giuk_ContentView_Writing!
    
    weak var bottomContainer: UIView!
    
    weak var topButtonView: GenericMultiButtonView!
    
    weak var leftNavigationButton: FadingButton!
    
    weak var rightNavigationButton: FadingButton!
    
    weak var noticeLabel : UILabel!
    
    var requieredButtonIndexes: (photo: Int?, write: Int?) = (nil,nil)
    
    //MARK: button datasources
    func multiButtonView_ButtonsForPresent(_ buttonView: GenericMultiButtonView) -> [UIButton_WithIdentifire] {
        switch writingState {
        case .choosingPhoto:
            return buttons_ForChoosingPhotoState
        case .writingComment:
            return buttons_ForWriteCommentState
        case .choosingTag:
            return buttons_ForChoosingTagState
        }
    }
    
    private lazy var buttons_ForChoosingPhotoState: [UIButton_WithIdentifire]  = {
        var buttons = [UIButton_WithIdentifire]()
        
        let buttonA = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonA.identifire = "Horizon"
        buttonA.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Aligns_Horizontal)?.withRenderingMode_alwaysTemplate, for: .normal)
        buttons.append(buttonA)
        
        let buttonB = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonB.identifire = "Verti"
        buttonB.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Aligns_Vertical)?.withRenderingMode_alwaysTemplate, for: .normal)
        buttons.append(buttonB)
        
        return buttons
    }()
    
    private lazy var buttons_ForWriteCommentState: [UIButton_WithIdentifire] = {
        var buttons = [UIButton_WithIdentifire]()
        
        let buttonA = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonA.identifire = "left"
        buttonA.imageView?.contentMode = .scaleAspectFit
        buttonA.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Aligns_Left)?.withRenderingMode_alwaysTemplate, for: .normal)
        buttons.append(buttonA)
        
        let buttonB = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonB.identifire = "middle"
        buttonB.imageView?.contentMode = .scaleAspectFit
        buttonB.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Aligns_Center)?.withRenderingMode_alwaysTemplate, for: .normal)
        buttons.append(buttonB)
        
        let buttonC = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonC.imageView?.contentMode = .scaleAspectFit
        buttonC.identifire = "right"
        buttonC.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Aligns_Right)?.withRenderingMode_alwaysTemplate, for: .normal)
        buttons.append(buttonC)
        
        return buttons
    }()
    
    private lazy var buttons_ForChoosingTagState: [UIButton_WithIdentifire] = {
        var buttons = [UIButton_WithIdentifire]()
        
        let buttonA = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonA.identifire = "tag"
        buttonA.setTitle(DescribingSources.choosingTagSection.choosingTagTilte, for: .normal)
        buttons.append(buttonA)
        
        return buttons
    }()
    
    private func initialButtonItemForTopButton(_ fontSize: CGFloat) -> UIButton_WithIdentifire {
        let button = UIButton_WithIdentifire()
        button.titleLabel?.setLabelAsSDStyleWithSpecificFontSize(fontSize: fontSize)
        button.setTitleColor(buttonColor_Selected, for: .selected)
        button.setTitleColor(buttonColor_Deselected, for: .normal)
        button.backgroundColor = buttonBackgroundColor
        return button
    }
    //end
    
    //MARK: button delegate and actions
    func multiButtonView(_ buttonView: GenericMultiButtonView, didPressedButton sender: UIButton_WithIdentifire) {
        switch sender.identifire {
        case "Verti":
            writingView.setImageCropViewOrientationTo(isHorizontal: false)
            updateRequieredButtonIndex(writingState, sender: sender)
        case "Horizon":
            writingView.setImageCropViewOrientationTo(isHorizontal: true)
            updateRequieredButtonIndex(writingState, sender: sender)
        case "left":
            writingView.setTextControllViewTextalignmentTo(.left)
            updateRequieredButtonIndex(writingState, sender: sender)
        case "middle":
            writingView.setTextControllViewTextalignmentTo(.center)
            updateRequieredButtonIndex(writingState, sender: sender)
        case "right":
            writingView.setTextControllViewTextalignmentTo(.right)
            updateRequieredButtonIndex(writingState, sender: sender)
        case "tag":
            updateRequieredButtonIndex(writingState, sender: sender)
        default:
            break
        }
    }
    
    private func updateRequieredButtonIndex(_ state: WritingState, sender: UIButton_WithIdentifire) {
        let buttons = topButtonView.buttons
        switch state {
        case .choosingPhoto:
            for button in buttons {
                if button.identifire == sender.identifire {
                    requieredButtonIndexes.photo = buttons.firstIndex(of: button)
                }
            }
        case .writingComment:
            for button in buttons {
                if button.identifire == sender.identifire {
                    requieredButtonIndexes.write = buttons.firstIndex(of: button)
                }
            }
        default:
            break
        }
    }
    
    private func requestButtonActionForRequieredButtonIndexFor(_ state: WritingState) {
        switch state {
        case .choosingPhoto:
            topButtonView.requieredActionWithButtonIndex(requieredButtonIndexes.photo)
        case .writingComment:
            topButtonView.requieredActionWithButtonIndex(requieredButtonIndexes.write)
        case .choosingTag:
            topButtonView.requieredActionWithButtonIndex(0)
        }
    }
    
    //MARK: needs to be called after button indexes setted
    func refreshViewSettingsBeforePresenting() {
        requestButtonActionForRequieredButtonIndexFor(writingState)
        layoutSubviews()
    }
    
    //MARK: WritingView Delegates
    func writingView(_ writingView: Giuk_ContentView_Writing, didUpdateWrtingStateAs state: WritingState) {
        prepareNavigationButtonsForWritingState(state)
        topButtonView?.reloadButtons{
            [unowned self] in
            self.requestButtonActionForRequieredButtonIndexFor(self.writingState)
        }
    }
    
    func writingView(_ writingView: Giuk_ContentView_Writing, cropView: Giuk_ContentView_SubView_ImageSelectAndCropView, didChangeImageAs image: Data?) {
        check_DataIsPrepared()
    }
    
    func writingView(_ writingView: Giuk_ContentView_Writing, tagEditor: TagGenerator, didUpdateTag: Bool) {
        check_DataIsPrepared()
    }
    
    func writingView(_ writingView: Giuk_ContentView_Writing, needRepresentedImageData imageData: Data) -> UIImage? {
        return delegate?.writeSection?(self, needRepresentedImageData: imageData)
    }
    //end
    
    var noticeTitle: NSMutableAttributedString {
        let fontSize: CGFloat = max(min((bottomNavigationButtonSize.height * 0.5), 16), 12)
        var text: NSMutableAttributedString!
        switch writingState {
        case .choosingPhoto:
            let title = "choose a moment".centeredAttributedString_Mutable(fontSize: fontSize, type: .bold)
            let subtitle = "\nand reposition the photo".centeredAttributedString_Mutable(fontSize: fontSize * 0.85, type: .medium)
            title.append(subtitle)
            text = title
        case .writingComment:
            let title = "".centeredAttributedString_Mutable(fontSize: fontSize, type: .bold)
            let subtitle = "".centeredAttributedString_Mutable(fontSize: fontSize * 0.85, type: .medium)
            title.append(subtitle)
            text = title
        case .choosingTag:
            let title = "add or choose a mark".centeredAttributedString_Mutable(fontSize: fontSize, type: .bold)
            let subtitle = "\nto save, needs at least one mark".centeredAttributedString_Mutable(fontSize: fontSize * 0.85, type: .medium)
            title.append(subtitle)
            text = title
        default:
            let title = "choose".centeredAttributedString_Mutable(fontSize: fontSize, type: .bold)
            let subtitle = "\nand".centeredAttributedString_Mutable(fontSize: fontSize * 0.816, type: .medium)
            title.append(subtitle)
            text = title
        }
        return text
    }
    
    func prepareNavigationButtonsForWritingState(_ state: WritingState) {
        switch state {
        case .choosingPhoto:
            leftNavigationButton.isHidden = true
        case .choosingTag:
            rightNavigationButton.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_Confirm), for: .normal)
        default:
            rightNavigationButton.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_RightArrow), for: .normal)
            leftNavigationButton.isHidden = false
        }
        check_DataIsPrepared()
    }
    
    func check_DataIsPrepared() {
        switch writingState {
        case .choosingPhoto:
            if writingView.photoControlView.isImageSetted {
                rightNavigationButton.isEnabled = true
            } else {
                rightNavigationButton.isEnabled = false
            }
        case .choosingTag:
            if writingView.tagControllView.isTagAdded {
                rightNavigationButton.isEnabled = true
            } else {
                rightNavigationButton.isEnabled = false
            }
        default:
            rightNavigationButton.isEnabled = true
        }
    }
    //end
    
    //MARK: Navigation Button actions
    @objc func navigationButtonPressed(_ sender: UIButton_WithIdentifire) {
        changeWritingState(sender)
    }
    
    func changeWritingState(_ sender: UIButton_WithIdentifire) {
        switch sender.identifire {
        case GiukNavigationButton.leftNavigationButton.rawValue:
            switch writingState {
            case .writingComment : writingState = .choosingPhoto
            case .choosingTag : writingState = .writingComment
            default:
                break
            }
        case GiukNavigationButton.rightNavigationButton.rawValue:
            switch writingState {
            case .choosingPhoto : writingState = .writingComment
            case .writingComment : writingState = .choosingTag
            case .choosingTag :
                if let wroted = writingView.wrotedData {
                    let wrotedData = CreatedData(thumbnailData: wroted.thumbData,croppedData: wroted.cropData, textData: wroted.textData, tagData: wroted.tagData)
                    delegate?.writeSection?(self, didEndEditing: true, wrotedData: wrotedData)
                }
            default:
                break
            }
        default:
            break
        }
    }
    //end
    
    //MARK: inits and update view Layout
    private func setOrRepostionBottomSubViews() {
        setOrRepositionNoticeLabel()
        setOrRepositioningNavigationButtons()
    }
    
    private func setOrRePositionContainers() {
        setOrRepostionTopContainer()
        setOrRepositionContentView()
        setOrRepostionBottomContainer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setOrRePositionContainers()
        setOrRePositionTopButtonView()
        setOrRepostionBottomSubViews()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRePositionContainers()
        setOrRePositionTopButtonView()
        setOrRepostionBottomSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrRePositionContainers()
        setOrRePositionTopButtonView()
        setOrRepostionBottomSubViews()
        prepareNavigationButtonsForWritingState(writingState)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRePositionContainers()
        setOrRePositionTopButtonView()
        setOrRepostionBottomSubViews()
        prepareNavigationButtonsForWritingState(writingState)
    }
    //end
    
}

extension Giuk_ContentView_WriteSection {
    
    //MARK: Frame sources
    var estimateButtonItemFontSize: CGFloat {
        return min(topButtonViewFrame.height/2, 14)
    }
    
    var buttonColor_Selected: UIColor {
        return UIColor.goyaSemiBlackColor
    }
    
    var buttonColor_Deselected: UIColor {
        return UIColor.goyaSemiBlackColor.withAlphaComponent(0.5)
    }
    
    var buttonBackgroundColor: UIColor {
        return UIColor.goyaYellowWhite
    }
    
    var buttonDeselectedBackgroundColor: UIColor {
        return UIColor.init(red: 211/255, green: 210/255, blue: 210/255, alpha: 1)
    }
    
    var estimateFontSizeForNoticeLabel : CGFloat {
        return valueBetweenMinAndMax(maxValue: CGFloat(16), minValue: 15, mutableValue: (bottomNoticeLabelViewFrame_InBottomContainer.size.height/4))
    }
    
    var topButtonViewFrame: CGRect {
        let width = topContainerAreaFrame.width * 0.518
        let height = topContainerAreaFrame.height * 0.618
        let originX = (topContainerAreaFrame.width - width)/2
        let originY = (topContainerAreaFrame.height - height)/2
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    var bottomNoticeLabelViewFrame_InBottomContainer: CGRect {
        let width = ((bottomContainerAreaSize.width * 0.7) - 16).clearUnderDot
        let height = min((bottomContainerAreaSize.height * 0.5), 40)
        let originX = (bottomContainerAreaSize.width - width)/2
        let originY: CGFloat = (bottomContainerAreaSize.height - height)/2
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    var bottomNavigationButtonSize: CGSize {
        let width = (bottomContainerAreaSize.width - 16 - bottomNoticeLabelViewFrame_InBottomContainer.width - (GiukContentFrameFactors.contentMinimumMargin.dX * 2))/2
        let height = width
        return CGSize(width: width, height: height)
    }
    
    var bottomNavigationButtonOrigins: [CGPoint] {
        let leftButtonOriginX = GiukContentFrameFactors.contentMinimumMargin.dX
        let rightButtonOriginX = bottomContainerAreaSize.width - bottomNavigationButtonSize.width - GiukContentFrameFactors.contentMinimumMargin.dX
        let OriginY = (bottomContainerAreaSize.height - bottomNavigationButtonSize.height)/2
        return [CGPoint(x: leftButtonOriginX, y: OriginY), CGPoint(x: rightButtonOriginX, y: OriginY)]
    }
    
    var leftNavigationButtonFrame_InBottomContainer: CGRect {
        return CGRect(origin: bottomNavigationButtonOrigins[0], size: bottomNavigationButtonSize)
    }
    
    var rightNavigationButtonFrame_InBottomContainer: CGRect {
        return CGRect(origin: bottomNavigationButtonOrigins[1], size: bottomNavigationButtonSize)
    }
    
}

extension Giuk_ContentView_WriteSection {
    
    //MARK: Set SubViews
    private func setOrRepostionTopContainer() {
        if topContainer == nil {
            let newContainer = generateUIView(view: topContainer, origin: topContainerAreaFrame.origin, size: topContainerAreaFrame.size)
            topContainer = newContainer
            addSubview(topContainer)
            topContainer.backgroundColor = .clear
        } else {
            topContainer.setNewFrame(topContainerAreaFrame)
        }
    }
    
    private func setOrRepositionContentView() {
        if writingView == nil {
            let newContainer = generateUIView(view: writingView, origin: contentAreaFrame.origin, size: contentAreaFrame.size)
            writingView = newContainer
            writingView.delegate = self
            writingView.backgroundColor = .goyaYellowWhite
            addSubview(writingView)
        } else {
            writingView.setNewFrame(contentAreaFrame)
        }
    }
    
    private func setOrRepostionBottomContainer() {
        if bottomContainer == nil {
            let newContainer = generateUIView(view: bottomContainer, origin: bottomContainerAreaFrame.origin, size: bottomContainerAreaFrame.size)
            bottomContainer = newContainer
            addSubview(bottomContainer)
            bottomContainer.isOpaque = false
            bottomContainer.backgroundColor = .clear
        } else {
            bottomContainer.setNewFrame(bottomContainerAreaFrame)
        }
    }
    
    private func setOrRePositionTopButtonView() {
        if topButtonView == nil {
            let newView = generateUIView(view: topButtonView, origin: topButtonViewFrame.origin, size: topButtonViewFrame.size)
            topButtonView = newView
            topButtonView.requiredMarginInsets = 0
            topButtonView.isSelectable = true
            topButtonView.dataSource = self
            topButtonView.delegate = self
            topContainer.addSubview(topButtonView)
        } else {
            topButtonView.setNewFrame(topButtonViewFrame)
            topButtonView.reloadButtons {
                [unowned self] in
                self.requestButtonActionForRequieredButtonIndexFor(self.writingState)
            }
            
        }
    }
    
    private func setOrRepositionNoticeLabel() {
        if noticeLabel == nil {
            let newLabel = generateUIView(view: noticeLabel, origin: bottomNoticeLabelViewFrame_InBottomContainer.origin, size: bottomNoticeLabelViewFrame_InBottomContainer.size)
            noticeLabel = newLabel
            noticeLabel.numberOfLines = 0
            noticeLabel.textAlignment = .center
            noticeLabel.textColor = .goyaWhite
//            noticeLabel.text = "CREATING A GIUK PAGE"
//            noticeLabel.addBorder(toSide: .top, withColor: UIColor.goyaWhite.cgColor, andThickness: 2)
            bottomContainer.addSubview(noticeLabel)
            noticeLabel.setLabelAsSDStyleWithSpecificFontSize(type: .bold, fontSize: estimateFontSizeForNoticeLabel)
        } else {
            noticeLabel.setNewFrame(bottomNoticeLabelViewFrame_InBottomContainer)
            noticeLabel.setLabelAsSDStyleWithSpecificFontSize(type: .medium, fontSize: estimateFontSizeForNoticeLabel)
//            noticeLabel.layer.sublayers?.forEach {$0.removeFromSuperlayer()}
//            noticeLabel.addBorder(toSide: .top, withColor: UIColor.goyaWhite.cgColor, andThickness: 2)
        }
    }
    
    enum GiukNavigationButton: String {
        case leftNavigationButton
        case rightNavigationButton
    }
    
    private func setOrRepositioningNavigationButtons() {
        if leftNavigationButton == nil {
            let newButton = generateUIView(view: leftNavigationButton, origin: bottomNavigationButtonOrigins[0], size: bottomNavigationButtonSize)
            newButton?.identifire = GiukNavigationButton.leftNavigationButton.rawValue
            newButton?.backgroundColor = .clear
            newButton?.setTitleColor(.goyaWhite, for: .normal)
            newButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_LeftArrow), for: .normal)
            leftNavigationButton = newButton
            leftNavigationButton.addTarget(self, action: #selector(navigationButtonPressed(_:)), for: .touchUpInside)
            bottomContainer.addSubview(leftNavigationButton)
        } else {
            leftNavigationButton.setNewFrame(leftNavigationButtonFrame_InBottomContainer)
        }
        
        if rightNavigationButton == nil {
            let newButton = generateUIView(view: rightNavigationButton, origin: bottomNavigationButtonOrigins[1], size: bottomNavigationButtonSize)
            newButton?.identifire = GiukNavigationButton.rightNavigationButton.rawValue
            newButton?.backgroundColor = .clear
            newButton?.setTitleColor(.goyaWhite, for: .normal)
            newButton?.setImage(UIImage(named: ButtonImageNames.ButtonName_Content_RightArrow), for: .normal)
            rightNavigationButton = newButton
            rightNavigationButton.addTarget(self, action: #selector(navigationButtonPressed(_:)), for: .touchUpInside)
            bottomContainer.addSubview(rightNavigationButton)
        } else {
            rightNavigationButton.setNewFrame(rightNavigationButtonFrame_InBottomContainer)
        }
    }
}
