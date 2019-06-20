//
//  Giuk_ContentView_WriteSection.swift
//  Gi-ukForMoments
//
//  Created by goya on 25/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

struct WillSaveContent {
    static var image: Data?
    static var comment: String?
    static var giuks: [String]?
    
    static func resetWillSaveData() {
        image = nil
        comment = nil
        giuks = nil
    }
}

class FadingButton: UIButton_WithIdentifire {
    override var isEnabled: Bool {
        didSet {
            if isEnabled {
                UIView.animate(withDuration: 0.25) {
                    self.imageView?.alpha = 1
                    self.titleLabel?.alpha = 1
                }
            } else {
                UIView.animate(withDuration: 0.25) {
                    self.imageView?.alpha = 0.4
                    self.titleLabel?.alpha = 0.4
                }
            }
        }
    }
}

class Giuk_ContentView_WriteSection: Giuk_ContentView, GenericMultiButtonViewDataSource {
    
    enum WritingState {
        case choosingPhoto
        case writingComment
        case choosingTag
    }
    
    var writingState: WritingState = .choosingPhoto {
        didSet {
            checkWritingState()
            topButtonView?.reloadButtons{
                [unowned self] in
                self.requestButtonActionForRequieredButtonIndexFor(self.writingState)
            }
        }
    }
    
    weak var topContainer: UIView!
    
    weak var contentContainer: NonAutomaticScrollView!
    
    weak var bottomContainer: UIView!
    
    weak var topButtonView: GenericMultiButtonView!
    
    weak var leftNavigationButton: FadingButton!
    
    weak var rightNavigationButton: FadingButton!
    
    weak var noticeLabel : UILabel!
    
    var requieredButtonIndexs: (photo: Int?, write: Int?) = (nil,nil)
    
    weak var photoControlView: Giuk_ContentView_SubView_ImageSelectAndCropView!
    
    //MARK: button datasources
    func multiButtonView_ButtonsForPresent(_ buttonView: GenericMultiButtonView) -> [UIButton_WithIdentifire] {
        switch writingState {
        case .choosingPhoto:
            return buttons_ForChoosingPhotoState()
        case .writingComment:
            return buttons_ForWriteCommentState()
        case .choosingTag:
            return buttons_ForChoosingTagState()
        }
    }
    
    func buttons_ForWriteCommentState() -> [UIButton_WithIdentifire] {
        var buttons = [UIButton_WithIdentifire]()
        
        let buttonA = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonA.identifire = "left"
        buttonA.setTitle("left", for: .normal)
        buttonA.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttons.append(buttonA)
        
        let buttonB = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonB.identifire = "middle"
        buttonB.setTitle("middle", for: .normal)
        buttonB.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttons.append(buttonB)
        
        let buttonC = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonC.identifire = "right"
        buttonC.setTitle("right", for: .normal)
        buttonC.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttons.append(buttonC)
        
        return buttons
    }
    
    func buttons_ForChoosingPhotoState() -> [UIButton_WithIdentifire] {
        var buttons = [UIButton_WithIdentifire]()
        
        let buttonA = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonA.identifire = "Verti"
        buttonA.setTitle("Verti", for: .normal)
        buttonA.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttons.append(buttonA)
        
        let buttonB = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonB.identifire = "Horizon"
        buttonB.setTitle("Horizon", for: .normal)
        buttonB.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttons.append(buttonB)
        
        return buttons
    }
    
    func buttons_ForChoosingTagState() -> [UIButton_WithIdentifire] {
        var buttons = [UIButton_WithIdentifire]()
        
        let buttonA = initialButtonItemForTopButton(estimateButtonItemFontSize)
        buttonA.identifire = "tag"
        buttonA.setTitle("BOOKMARK", for: .normal)
        buttonA.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttons.append(buttonA)
        
        return buttons
    }
    
    func initialButtonItemForTopButton(_ fontSize: CGFloat) -> UIButton_WithIdentifire {
        let button = UIButton_WithIdentifire()
        button.titleLabel?.setLabelAsSDStyleWithSpecificFontSize(fontSize: fontSize)
        button.setTitleColor(buttonColor_Selected, for: .selected)
        button.setTitleColor(buttonColor_Deselected, for: .normal)
        button.backgroundColor = buttonBackgroundColor
        return button
    }
    //end
    
    //MARK: button actions
    func buttonActions(_ sender: UIButton_WithIdentifire) {
        checkButtonStateWithIdentifire(sender.identifire)
        switch sender.identifire {
        case "Verti":
            if photoControlView.isHorizontal != true {
                photoControlView.imageCropView.cropInformation = nil
                photoControlView.isHorizontal = true
                //photoControlView.imageCropView.resetCropInformationAndRefrechImage()
            }
            checkImageExist()
            updateRequieredButtonIndex(writingState, sender: sender)
        case "Horizon":
            if photoControlView.isHorizontal == true {
                photoControlView.imageCropView.cropInformation = nil
                photoControlView.isHorizontal = false
                //photoControlView.imageCropView.resetCropInformationAndRefrechImage()
            }
            checkImageExist()
            updateRequieredButtonIndex(writingState, sender: sender)
        case "left":
            updateRequieredButtonIndex(writingState, sender: sender)
        case "middle":
            updateRequieredButtonIndex(writingState, sender: sender)
        case "right":
            updateRequieredButtonIndex(writingState, sender: sender)
        default:
            break
        }
        print(requieredButtonIndexs)
    }
    
    func updateRequieredButtonIndex(_ state: WritingState, sender: UIButton_WithIdentifire) {
        let buttons = topButtonView.buttons
        switch state {
        case .choosingPhoto:
            for button in buttons {
                if button.identifire == sender.identifire {
                    requieredButtonIndexs.photo = buttons.firstIndex(of: button)
                }
            }
        case .writingComment:
            for button in buttons {
                if button.identifire == sender.identifire {
                    requieredButtonIndexs.write = buttons.firstIndex(of: button)
                }
            }
        default:
            break
        }
    }
    
    func requestButtonActionForRequieredButtonIndexFor(_ state: WritingState) {
        switch state {
        case .choosingPhoto:
            topButtonView.requieredActionWithButtonIndex(requieredButtonIndexs.photo)
        case .writingComment:
            topButtonView.requieredActionWithButtonIndex(requieredButtonIndexs.write)
        default:
            break
        }
    }
    
    func checkWritingState() {
        switch writingState {
        case .choosingPhoto:
            photoControlView.imageCropView.mode = .cropable
            photoControlView.layoutSubviews()
//            contentContainer.scrollToPosition(CGPoint.zero, animated: true)
        default:
//            contentContainer.scrollToPosition(CGPoint(x: -contentContainer.frame.width, y: 0), animated: true)
            photoControlView.imageCropView.mode = .presentOnly
            leftNavigationButton.isHidden = false
            rightNavigationButton.isHidden = false
            leftNavigationButton.isEnabled = true
            rightNavigationButton.isEnabled = true
        }
    }
    
    func checkImageExist() {
        if photoControlView.imageCropView.image == nil {
            leftNavigationButton.isHidden = true
            rightNavigationButton.isEnabled = false
        } else {
            leftNavigationButton.isHidden = true
            rightNavigationButton.isEnabled = true
        }
    }
    
    @objc func actionInTopButtonPressed(_ sender: UIButton_WithIdentifire) {
        buttonActions(sender)
    }
    
    private func checkButtonStateWithIdentifire(_ identifire: String) {
        for view in topButtonView.buttonContentArea.subviews {
            if let button = view as? UIButton_WithIdentifire {
                if button.identifire == identifire {
                    button.isSelected = true
                    button.backgroundColor = buttonBackgroundColor
                } else {
                    button.isSelected = false
                    button.backgroundColor = buttonDeselectedBackgroundColor
                }
            }
        }
    }
    
    @objc func navigationButtonPressed(_ sender: UIButton_WithIdentifire) {
        updateWritingState(sender)
    }
    
    func updateWritingState(_ sender: UIButton_WithIdentifire) {
        switch sender.identifire {
        case GiukNavigationButton.leftNavigationButton.rawValue:
            if writingState == .writingComment {
                writingState = .choosingPhoto
            }
        case GiukNavigationButton.rightNavigationButton.rawValue:
            if writingState == .choosingPhoto {
                writingState = .writingComment
            }
        default:
            break
        }
    }
    
    //end
    
    
    //MARK: layout triggers
    func setOrRepostionBottomSubViews() {
        setOrRepositionNoticeLabel()
        setOrRepositioningNavigationButtons()
    }
    
    func setOrRePositionContainers() {
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRePositionContainers()
        setOrRePositionTopButtonView()
        setOrRepostionBottomSubViews()
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
        return min(bottomNoticeLabelViewFrame_InBottomContainer.size.height/4, 16)
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
        let height = bottomContainerAreaSize.height - 6
        let originX = (bottomContainerAreaSize.width - width)/2
        let originY: CGFloat = 3
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
        if contentContainer == nil {
            let newContainer = generateUIView(view: contentContainer, origin: contentAreaFrame.origin, size: contentAreaFrame.size)
            contentContainer = newContainer
            contentContainer.backgroundColor = .goyaYellowWhite
            addSubview(contentContainer)
            setOrRepostionPhotoControlView()
        } else {
            contentContainer.setNewFrame(contentAreaFrame)
            setOrRepostionPhotoControlView()
        }
    }
    
    private func setOrRepostionPhotoControlView() {
        if photoControlView == nil {
            let newView = generateUIView(view: photoControlView, origin: CGPoint.zero, size: contentContainer.bounds.size)
            photoControlView = newView
            contentContainer.addSubview(photoControlView)
        } else {
            photoControlView.setNewFrame(contentContainer.bounds)
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
            topButtonView.dataSource = self
            topButtonView.requiredMarginInsets = 0
            topContainer.addSubview(topButtonView)
        } else {
            topButtonView.setNewFrame(topButtonViewFrame)
            topButtonView.reloadButtons {
                [unowned self] in
                self.topButtonView.requieredActionWithButtonIndex(nil)
            }
            
        }
    }
    
    private func setOrRepositionNoticeLabel() {
        if noticeLabel == nil {
            let newLabel = generateUIView(view: noticeLabel, origin: bottomNoticeLabelViewFrame_InBottomContainer.origin, size: bottomNoticeLabelViewFrame_InBottomContainer.size)
            newLabel?.textAlignment = .center
            newLabel?.textColor = .white
            noticeLabel = newLabel
            bottomContainer.addSubview(noticeLabel)
            noticeLabel.setLabelAsSDStyleWithSpecificFontSize(type: .medium, fontSize: estimateFontSizeForNoticeLabel)
        } else {
            noticeLabel.setLabelAsSDStyleWithSpecificFontSize(type: .medium, fontSize: estimateFontSizeForNoticeLabel)
            noticeLabel.setNewFrame(bottomNoticeLabelViewFrame_InBottomContainer)
            noticeLabel.layer.sublayers?.forEach {$0.removeFromSuperlayer()}
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
            newButton?.setTitle("◀︎", for: .normal)
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
            newButton?.setTitle("▶︎", for: .normal)
            rightNavigationButton = newButton
            rightNavigationButton.addTarget(self, action: #selector(navigationButtonPressed(_:)), for: .touchUpInside)
            bottomContainer.addSubview(rightNavigationButton)
        } else {
            rightNavigationButton.setNewFrame(rightNavigationButtonFrame_InBottomContainer)
        }
    }
}
