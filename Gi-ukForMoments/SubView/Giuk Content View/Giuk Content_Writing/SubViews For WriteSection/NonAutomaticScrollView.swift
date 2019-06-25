//
//  NonAutoMaticScrollView.swift
//  Gi-ukForMoments
//
//  Created by goya on 28/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class NonAutomaticScrollView_Skelleton: UIView {
    
    weak var contentView: UIView!
    
    var contentOffSet: CGPoint {
        return contentView.frame.origin
    }
    
    func scrollToPosition(_ position: CGPoint, animated: Bool, completion: (()->Void)? = nil) {
        if animated {
            isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.25, animations: {
                [unowned self] in
                self.contentView.frame.origin = position
            }) { [unowned self] (finished) in
                self.isUserInteractionEnabled = true
                completion?()
            }
        } else {
            contentView.frame.origin = position
        }
    }
    
    private func setContentView() {
        let view = UIView()
        view.frame = CGRect.zero
        contentView = view
        addSubview(contentView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setContentView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setContentView()
    }
}

class NonAutomaticScrollView: NonAutomaticScrollView_Skelleton {
    
    var scrollAvailable: Bool = true
    
    var maximumScrollAvailableAmountToTop: CGFloat = 0
    
    var maximumScrollAvailableAmountToBottom: CGFloat = 0
    
    func resetScollControlState() {
        scrollAvailable = false
        maximumScrollAvailableAmountToTop = 0
        maximumScrollAvailableAmountToBottom = 0
    }
    
    @objc func scrollActive(_ recognizer: UIPanGestureRecognizer) {
        if scrollAvailable {
            let transition = recognizer.translation(in: self)
            let positionY = (transition.y)/10
            print(positionY)
            let targetPosition = contentOffSet.offSetBy(dX: 0, dY: (positionY))
            if targetPosition.y < maximumScrollAvailableAmountToTop && targetPosition.y > maximumScrollAvailableAmountToBottom {
            scrollToPosition(contentOffSet.offSetBy(dX: 0, dY: (positionY)), animated: false)
            }
        }
    }
    
    weak var scrollRegcognizer: UIPanGestureRecognizer!
    
    func setRecognizer() {
        if scrollRegcognizer == nil {
            let recognizer = UIPanGestureRecognizer(target: self, action: #selector(scrollActive(_:)))
            recognizer.maximumNumberOfTouches = 1
            recognizer.minimumNumberOfTouches = 1
            scrollRegcognizer = recognizer
            self.addGestureRecognizer(scrollRegcognizer)
        }
    }
    
    override func addSubview(_ view: UIView) {
        if view != contentView {
            contentView.addSubview(view)
        } else {
            super.addSubview(view)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame.size = calculatedContentSize()
    }
    
    func calculatedContentSize() -> CGSize {
        if contentView.subviews.count > 0 {
            var calculatedWidth: CGFloat = 0
            var calculatedHeight: CGFloat = 0
            contentView.subviews.forEach {
                if $0.frame.maxX > calculatedWidth {
                    calculatedWidth = $0.frame.maxX
                }
                if $0.frame.maxY > calculatedHeight {
                    calculatedHeight = $0.frame.maxY
                }
            }
            return CGSize(width: calculatedWidth, height: calculatedHeight)
        } else {
            return CGSize.zero
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        setRecognizer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        clipsToBounds = true
        setRecognizer()
    }

}
