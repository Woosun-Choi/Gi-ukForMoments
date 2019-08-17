//
//  WoosunAlertController.swift
//  Gi-ukForMoments
//
//  Created by goya on 17/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

struct WoosunAlertControllerItem {
    enum ItemStyle {
        case normal
        case destructive
        case cancel
    }
    var itemStlye: ItemStyle
    var title: String?
    var completion: (() -> Void)?
    
    init(style: ItemStyle, title: String? = "", completion: (() -> Void)?) {
        self.itemStlye = style
        self.title = title
        self.completion = completion
    }
}

class WoosunAlertController: ContentUIViewController {
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    enum AlertStyle {
        case center
        case bottom
    }
    
    var transitionDelegate = FadeInTransitioningDelegate()
    
    private weak var titleLabel: UILabel!
    private weak var messageLabel: UILabel!
    private weak var effectView: UIVisualEffectView!
    
    private var backgroundColor = UIColor.black.withAlphaComponent(0.85)
    private var titleComment: String?
    private var message: String?
    private var style: AlertStyle?
    private var actions = [WoosunAlertControllerItem]()
    private var requsetedCompletion: (() -> Void)?
    
    var titleFontSize: CGFloat = 25
    var messageFontSize: CGFloat = 16
    
    private lazy var actionButtons : [UIButton_WithIdentifire] = {
        let buttons = configureRequiredButtons()
        return buttons
    }()
    
    func setButtons() {
        for item in actions.indices {
             actionButtons[item].frame = buttonsFrames[item]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGesture(view)
//        self.transitioningDelegate = transitionDelegate
        self.view.backgroundColor = backgroundColor
        setEffectView()
        setTitleLable()
        setMessageLable()
        setButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setEffectView()
        setTitleLable()
        setMessageLable()
        setButtons()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setEffectView()
        setTitleLable()
        setMessageLable()
        setButtons()
    }
    
    func setTitleLable() {
        if titleLabel == nil {
            let newLabel = generateUIView(view: titleLabel, frame: titleContainerRect)
            newLabel?.numberOfLines = 0
            titleLabel = newLabel
            titleLabel.textColor = .goyaWhite
            view.addSubview(titleLabel)
            setTitleInTitleLabel()
            layoutTitleLabel()
        } else {
            setTitleInTitleLabel()
            layoutTitleLabel()
        }
    }
    
    func setMessageLable() {
        if messageLabel == nil {
            let newLabel = generateUIView(view: messageLabel, frame: messageContainerRect)
            newLabel?.numberOfLines = 0
            messageLabel = newLabel
            messageLabel.textColor = .goyaWhite
            view.addSubview(messageLabel)
            setMessageInMessageLabel()
            layoutMessageLabel()
        } else {
            setMessageInMessageLabel()
            layoutMessageLabel()
        }
    }
    
    private func setTitleInTitleLabel() {
        guard let currentTitle = self.titleComment else { return }
        let content = currentTitle.centeredAttributedString(fontSize: titleFontSize, type: .bold)
        titleLabel?.attributedText = content
        titleLabel?.sizeToFit()
    }
    
    private func setMessageInMessageLabel() {
        guard let currentMessage = self.message else { return }
        let content = currentMessage.centeredAttributedString(fontSize: messageFontSize, type: .regular)
        messageLabel?.attributedText = content
        messageLabel?.sizeToFit()
    }
    
    private func layoutTitleLabel() {
        let titleSize = titleLabel.frame.size
        let originX = (titleContainerRect.width - titleSize.width)/2
        let originY = (titleContainerRect.height - titleSize.height)/2
        let prefferedOrigin = titleContainerRect.origin.offSetBy(dX: originX, dY: originY)
        titleLabel.frame.origin = prefferedOrigin
    }
    
    private func layoutMessageLabel() {
        let titleSize = messageLabel.frame.size
        let originX = (messageContainerRect.width - titleSize.width)/2
        let originY = (messageContainerRect.height - titleSize.height)/2
        let prefferedOrigin = messageContainerRect.origin.offSetBy(dX: originX, dY: originY)
        messageLabel.frame.origin = prefferedOrigin
    }
    
    func setEffectView() {
        if effectView == nil {
            let effect = UIBlurEffect.init(style: .light)
            let newView = UIVisualEffectView(effect: effect)
            effectView = newView
            effectView.frame = view.bounds
            effectView.alpha = 0.3
            view.addSubview(effectView)
            setGesture(effectView)
        } else {
            effectView.setNewFrame(view.bounds)
        }
    }
    
    private func setGesture(_ view: UIView) {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeAction))
        gesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(gesture)
    }
    
    @objc func closeAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func addAction(_ actionItem: WoosunAlertControllerItem) {
        self.actions.append(actionItem)
    }
    
    private func configureRequiredButtons() -> [UIButton_WithIdentifire] {
        var buttons = [UIButton_WithIdentifire]()
        for action in actions {
            guard let button = createButton(action) else { return [] }
            view.addSubview(button)
            buttons.append(button)
        }
        return buttons
    }
    
    private func createButton(_ actionItem: WoosunAlertControllerItem) -> UIButton_WithIdentifire? {
        guard let currentTitle = actionItem.title else { return nil }
        
        var isRedContent: Bool {
            if actionItem.itemStlye == .destructive {
                return true
            } else {
                return false
            }
        }
        
        let button = UIButton_WithIdentifire(with: currentTitle)
        button.setTitle(currentTitle, for: .normal)
        button.layer.cornerRadius = 6
        if actionItem.itemStlye == .cancel {
            button.layer.borderWidth = 2
            button.layer.borderColor = UIColor.goyaWhite.withAlphaComponent(0.85).cgColor
        } else {
            button.backgroundColor = UIColor.goyaWhite.withAlphaComponent(0.85)
        }
        
        if !isRedContent {
            if actionItem.itemStlye == .cancel {
                button.setTitleColor(UIColor.goyaWhite, for: .normal)
            } else {
                button.setTitleColor(UIColor.goyaFontColor, for: .normal)
            }
        } else {
            button.setTitleColor(UIColor.red, for: .normal)
        }
        
        button.addTarget(self, action: #selector(performRequestedAction(_:)), for: .touchUpInside)
        return button
    }
    
    @objc private func performRequestedAction(_ sender: UIButton_WithIdentifire) {
        let identifire = sender.identifire
        if let target = (actions.filter { $0.title == identifire }).first {
            prepareForDismiss(target)
            performAction()
        }
    }
    
    private func prepareForDismiss(_ actionItem: WoosunAlertControllerItem) {
        self.requsetedCompletion = actionItem.completion
    }
    
    private func performAction() {
//        self.modalPresentationStyle = .currentContext
        self.dismiss(animated: true, completion: requsetedCompletion)
    }
    
    convenience init(title: String, message: String, style: AlertStyle) {
        self.init()
        self.titleComment = title
        self.message = message
        self.style = style
        
        self.transitioningDelegate = transitionDelegate
        self.modalPresentationStyle = .overCurrentContext
    }
}

extension WoosunAlertController {
    
    fileprivate var heightGrid: (title: CGFloat, message: CGFloat, buttons: CGFloat) {
        return (0.1,0.1,0.8)
    }
    
    fileprivate var prefferedContainerHeights: (title: CGFloat, message: CGFloat, buttons: CGFloat) {
        return (
            safeAreaRelatedAreaFrame.height * heightGrid.title,
            safeAreaRelatedAreaFrame.height * heightGrid.message,
            safeAreaRelatedAreaFrame.height * heightGrid.buttons
        )
    }
    
    fileprivate var titleContainerRect : CGRect {
        let size = CGSize(width: safeAreaRelatedAreaFrame.width, height: prefferedContainerHeights.title)
        let origin = CGPoint(x: 0, y: safeAreaRelatedAreaFrame.origin.y)
        return CGRect(origin: origin, size: size)
    }
    
    fileprivate var messageContainerRect : CGRect {
        let size = CGSize(width: safeAreaRelatedAreaFrame.width, height: prefferedContainerHeights.message)
        let origin = CGPoint(x: 0, y: titleContainerRect.maxY)
        return CGRect(origin: origin, size: size)
    }
    
    fileprivate var buttonContainerRect : CGRect {
        let size = CGSize(width: safeAreaRelatedAreaFrame.width, height: prefferedContainerHeights.buttons)
        let origin = CGPoint(x: 0, y: messageContainerRect.maxY)
        return CGRect(origin: origin, size: size)
    }
    
    fileprivate var buttonMargin: CGFloat {
        return 12
    }
    
    fileprivate var prefferedButtonSize: CGSize {
        let width = buttonContainerRect.width * 0.815
        let minMargin:CGFloat = buttonMargin * (actions.count - 1).cgFloat
        let maxHeight = (buttonContainerRect.height - 16 - minMargin)/(actions.count.cgFloat)
        let height = min(maxHeight, 45)
        return CGSize(width: width, height: height)
    }
    
    fileprivate var buttonsFrames: [CGRect] {
        let initialButtonOriginX = buttonContainerRect.origin.x + ((buttonContainerRect.width - prefferedButtonSize.width)/2)
        var initialButtonOriginY = buttonContainerRect.maxY - 16 - prefferedButtonSize.height
        var expectedOrigin: CGPoint {
            return CGPoint(x: initialButtonOriginX, y: initialButtonOriginY)
        }
        var btnFrames = [CGRect]()
        for _ in 0..<actions.count {
            let newFrame = CGRect(origin: expectedOrigin, size: prefferedButtonSize)
            btnFrames.append(newFrame)
            initialButtonOriginY -= (prefferedButtonSize.height + buttonMargin)
        }
        return btnFrames
    }
}
