//
//  PresentGiukView.swift
//  Gi-ukForMoments
//
//  Created by goya on 16/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class PresentGiukView: UIView, ImageCroppingViewDelegate
{
    weak var imageView: ImageCroppingView!
    
    weak var textView: PresentTextView!
    
    var isHorizontal: Bool = false {
        didSet {
            layoutSubviews()
        }
    }
    
    var imageData: CroppedImageInformation? {
        didSet {
            if let data = imageData {
                isHorizontal = data.cropInformation.isHorizontal
                imageView.croppedImageData = data
            } else {
                imageView.croppedImageData = nil
            }
        }
    }
    
    var textData: TextInformation? {
        didSet {
            if let data = textData {
                textView.textData = data
            } else {
                textView.textView.text = ""
            }
        }
    }
    
    private func setOrRepositionImageView() {
        if imageView == nil {
            let newView = generateUIView(view: imageView, frame: estimateAreaOfImageCorpView)
            imageView = newView
            imageView.backgroundColor = .clear
            imageView.mode = .presentOnly
            addSubview(imageView)
        } else {
            imageView.setNewFrame(estimateAreaOfImageCorpView)
        }
    }
    
    private func setOrRepositionTextView() {
        if textView == nil {
            let newView = generateUIView(view: textView, frame: estimateAreaForWriting)
            textView = newView
//            textView.isEditable = false
            textView.backgroundView.backgroundColor = .clear
            textView.backgroundColor = .clear
            addSubview(textView)
        } else {
            textView?.setNewFrame(estimateAreaForWriting)
        }
    }
    
    func setOrUpdateLayoutSubViews() {
        setOrRepositionImageView()
        setOrRepositionTextView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setOrUpdateLayoutSubViews()
    }
    
    override func draw(_ rect: CGRect) {
        setOrUpdateLayoutSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrUpdateLayoutSubViews()
        backgroundColor = .goyaYellowWhite
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrUpdateLayoutSubViews()
        backgroundColor = .goyaYellowWhite
    }

}

extension PresentGiukView {
    
    var estimateAreaOfImageCorpView: CGRect {
        if isHorizontal {
            let width = bounds.width
            let height = width/1.618
            let size = CGSize(width: width, height: height)
            let origin = CGPoint.zero
            return CGRect(origin: origin, size: size)
        } else {
            let height = bounds.height
            let width = height/2.589
            let size = CGSize(width: width, height: height)
            let originX = bounds.width - width
            let originY : CGFloat = 0
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        }
    }
    
    var estimateAreaForWriting: CGRect {
        if isHorizontal {
            let width = frame.width
            let height = frame.height - estimateAreaOfImageCorpView.height
            let size = CGSize(width: width, height: height)
            let originX : CGFloat = 0
            let originY = estimateAreaOfImageCorpView.maxY
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        } else {
            let height = frame.height
            let width = frame.width - estimateAreaOfImageCorpView.width
            let size = CGSize(width: width, height: height)
            let origin = CGPoint(x: 0, y: 0)
            return CGRect(origin: origin, size: size)
        }
    }
    
}
