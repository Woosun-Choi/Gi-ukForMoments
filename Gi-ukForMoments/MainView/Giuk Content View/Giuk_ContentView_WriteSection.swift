//
//  Giuk_ContentView_WriteSection.swift
//  Gi-ukForMoments
//
//  Created by goya on 25/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class Giuk_ContentView_WriteSection: Giuk_ContentView, MultiButtonViewDataSource {
    
    enum WritingState {
        case none
        case choosingPhoto
        case writingComment
        case choosingTag
    }
    
    var writingState: WritingState = .writingComment {
        didSet {
            topButtonView?.reloadButtons()
        }
    }
    
    var topContainer: UIView!
    
    var contentContainer: UIView!
    
    var bottomContainer: UIView!
    
    var topButtonView: GenericMultiButtonView!
    
    func multiButtonView_ButtonsForPresent(_ buttonView: GenericMultiButtonView) -> [UIButton_WithIdentifire] {
        switch writingState {
        case .choosingPhoto:
            return buttons_ForChoosingPhotoState()
        case .writingComment:
            return buttons_ForWriteCommentState()
        default:
            return []
        }
    }
    
    func buttons_ForWriteCommentState() -> [UIButton_WithIdentifire] {
        var buttons = [UIButton_WithIdentifire]()
        
        let buttonA = UIButton_WithIdentifire()
        buttonA.identifire = "left"
        buttonA.setTitle("left", for: .normal)
        buttonA.setTitleColor(.white, for: .selected)
        buttonA.setTitleColor(.gray, for: .normal)
        buttonA.backgroundColor = .goyaBlack
        buttonA.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttons.append(buttonA)
        
        let buttonB = UIButton_WithIdentifire()
        buttonB.identifire = "middle"
        buttonB.setTitle("middle", for: .normal)
        buttonB.setTitleColor(.white, for: .selected)
        buttonB.setTitleColor(.gray, for: .normal)
        buttonB.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttonB.backgroundColor = .goyaBlack
        buttons.append(buttonB)
        
        let buttonC = UIButton_WithIdentifire()
        buttonC.identifire = "right"
        buttonC.setTitle("right", for: .normal)
        buttonC.setTitleColor(.white, for: .selected)
        buttonC.setTitleColor(.gray, for: .normal)
        buttonC.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttonC.backgroundColor = .goyaBlack
        buttons.append(buttonC)
        
        return buttons
    }
    
    func buttons_ForChoosingPhotoState() -> [UIButton_WithIdentifire] {
        var buttons = [UIButton_WithIdentifire]()
        
        let buttonA = UIButton_WithIdentifire()
        buttonA.identifire = "A"
        buttonA.setTitle("Verti", for: .normal)
        buttonA.setTitleColor(.white, for: .selected)
        buttonA.setTitleColor(.gray, for: .normal)
        buttonA.backgroundColor = .goyaBlack
        buttonA.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttons.append(buttonA)
        
        let buttonB = UIButton_WithIdentifire()
        buttonB.identifire = "B"
        buttonB.setTitle("Horizon", for: .normal)
        buttonB.setTitleColor(.white, for: .selected)
        buttonB.setTitleColor(.gray, for: .normal)
        buttonB.addTarget(self, action: #selector(actionInTopButtonPressed(_:)), for: .touchUpInside)
        buttonB.backgroundColor = .goyaBlack
        buttons.append(buttonB)
        
        return buttons
    }
    
    @objc func actionInTopButtonPressed(_ button: UIButton_WithIdentifire) {
        switch button.identifire {
        case "A":
            checkButtonStateWithIdentifire("A")
        case "B":
            checkButtonStateWithIdentifire("B")
        case "left":
            checkButtonStateWithIdentifire("left")
        case "middle":
            checkButtonStateWithIdentifire("middle")
        case "right":
            checkButtonStateWithIdentifire("right")
        default:
            break
        }
    }
    
    private func checkButtonStateWithIdentifire(_ identifire: String) {
        for view in topButtonView.buttonContentArea.subviews {
            if let button = view as? UIButton_WithIdentifire {
                if button.identifire == identifire {
                    button.isSelected = true
                } else {
                    button.isSelected = false
                }
            }
        }
    }
    
    private func setOrRepostionTopContainer() {
        if topContainer == nil {
            topContainer = generateUIView(view: topContainer, origin: topContainerAreaFrame.origin, size: topContainerAreaFrame.size)
            addSubview(topContainer)
            topContainer.backgroundColor = .goyaRoseGoldColor
        } else {
            topContainer.setNewFrame(topContainerAreaFrame)
        }
    }
    
    private func setOrRepositionContentView() {
        if contentContainer == nil {
            contentContainer = generateUIView(view: contentContainer, origin: contentAreaFrame.origin, size: contentAreaFrame.size)
            addSubview(contentContainer)
            contentContainer.backgroundColor = .purple
        } else {
            contentContainer.setNewFrame(contentAreaFrame)
        }
    }
    
    private func setOrRepostionBottomContainer() {
        if bottomContainer == nil {
            bottomContainer = generateUIView(view: bottomContainer, origin: bottomContainerAreaFrame.origin, size: bottomContainerAreaFrame.size)
            addSubview(bottomContainer)
            bottomContainer.backgroundColor = .goyaZenColorYellow
        } else {
            bottomContainer.setNewFrame(bottomContainerAreaFrame)
        }
    }
    
    private func setOrRePositionTopButtonView() {
        if topButtonView == nil {
            topButtonView = generateUIView(view: topButtonView, origin: topButtonViewFrame.origin, size: topButtonViewFrame.size)
            topButtonView.dataSource = self
            topButtonView.requiredMarginInsets = 0
            topContainer.addSubview(topButtonView)
        } else {
            topButtonView.setNewFrame(topButtonViewFrame)
            topButtonView.reloadButtons()
            topButtonView.initialAction()
        }
    }
    
    func setOrRePositionContainers() {
        setOrRepostionTopContainer()
        setOrRepositionContentView()
        setOrRepostionBottomContainer()
    }
    
    override func layoutSubviews() {
        setOrRePositionContainers()
        setOrRePositionTopButtonView()
    }
    
    override func draw(_ rect: CGRect) {
        setOrRePositionContainers()
        setOrRePositionTopButtonView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrRePositionContainers()
        setOrRePositionTopButtonView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRePositionContainers()
        setOrRePositionTopButtonView()
    }
}

extension Giuk_ContentView_WriteSection {
    
    var topButtonViewFrame: CGRect {
        let width = topContainerAreaFrame.width * 0.618
        let height = topContainerAreaFrame.height * 0.618
        let originX = (topContainerAreaFrame.width - width)/2
        let originY = (topContainerAreaFrame.height - height)/2
        return CGRect(x: originX, y: originY, width: width, height: height)
    }
}
