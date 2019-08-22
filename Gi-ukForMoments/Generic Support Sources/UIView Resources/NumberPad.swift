//
//  NumberPad.swift
//  Gi-ukForMoments
//
//  Created by goya on 20/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol NumberPadDelegate {
    @objc optional func numberPad(_ numberPad: NumberPad, didUpdateNumberStringAs numberString: String)
    @objc optional func numberPad(_ numberPad: NumberPad, requestDeletion: Bool)
}

class NumberPad: UIView {
    
    weak var delegate: NumberPadDelegate?
    
    var numberColor:UIColor = .goyaFontColor {
        didSet {
            setNeedsLayout()
        }
    }
    
    var numberBackgroundColor: UIColor = .clear {
        didSet {
            setNeedsLayout()
        }
    }
    
    var buttonGrid: [CGRect]? {
        return GridSystemForSquares.gridForSquares(targetFrame: bounds, numberOFButtonsInHorizon: 3, numberOFButtonsInVertical: 4)
    }
    
    private let numbers: [String] = [7.string,8.string,9.string,4.string,5.string,6.string,1.string,2.string,3.string,"",0.string,"<"]
    
    private let inputPermisioned = [7.string,8.string,9.string,4.string,5.string,6.string,1.string,2.string,3.string,0.string]
    
    lazy var buttons: [UIButton_WithIdentifire] = {
        var numberButtons = [UIButton_WithIdentifire]()
        for number in self.numbers {
            let newButton = UIButton_WithIdentifire(with: number)
            prepareButton(newButton)
            numberButtons.append(newButton)
            addSubview(newButton)
        }
        return numberButtons
    }()
    
    private func prepareButton(_ button: UIButton_WithIdentifire) {
        if inputPermisioned.contains(button.identifire) {
            let analogView = AnalogNumberView()
            analogView.frame = button.bounds
            analogView.isZeroAvailable = false
            analogView.requiredNumberCount = 1
            analogView.dayNumber = Int(button.identifire)!
            analogView.numberColor = .goyaWhite
            analogView.isUserInteractionEnabled = false
            button.addSubview(analogView)
        } else {
            if button.identifire == "<" {
                button.setTitle("⬅︎", for: .normal)
                button.setTitleColor(numberColor, for: .normal)
            }
        }
        button.addTarget(self, action: #selector(numberButtonPressed(_:)), for: .touchUpInside)
    }
    
    private func relayoutButton(_ button: UIButton_WithIdentifire, newFrame: CGRect) {
        button.setNewFrame(newFrame)
        if inputPermisioned.contains(button.identifire) {
            for subView in button.subviews {
                if let analogView = subView as? AnalogNumberView {
                    let maxWidth = button.bounds.width * 0.6
                    let maxHeight = button.bounds.height * 0.6
                    let originX = (button.bounds.width - maxWidth)/2
                    let originY = (button.bounds.height - maxHeight)/2
                    updateAnalogNumberView(analogView, numberColor: numberColor)
                    analogView.frame = CGRect(x: originX, y: originY, width: maxWidth, height: maxHeight)
                }
            }
        } else {
            if button.identifire == "<" {
                button.setTitleColor(numberColor, for: .normal)
            }
        }
        button.backgroundColor = numberBackgroundColor
    }
    
    private func updateAnalogNumberView(_ view: AnalogNumberView, numberColor: UIColor?) {
        if let numColor = numberColor {
            if view.numberColor != numColor {
                view.numberColor = numColor
            }
        }
    }
    
    @objc func numberButtonPressed(_ sender: UIButton_WithIdentifire) {
        if inputPermisioned.contains(sender.identifire) {
            delegate?.numberPad?(self, didUpdateNumberStringAs: sender.identifire)
        } else {
            if sender.identifire == "<" {
                delegate?.numberPad?(self, requestDeletion: true)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let grid = self.buttonGrid {
            for item in buttons.indices {
                relayoutButton(buttons[item], newFrame: grid[item])
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _ = buttons
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _ = buttons
    }
}
