//
//  ThumbnailCollectionViewCell.swift
//  Gi-ukForMoments
//
//  Created by goya on 20/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol ThumbnailImageViewDelegate {
    @objc func thumbnailImageViewShouldReturnImageAs(_ thumbnailImageView: ThumbnailImageView, imageData: Data) -> UIImage?
}

class ThumbnailImageView : UIImageView {
    
    weak var delegate: ThumbnailImageViewDelegate?
    
    var imageData: Data? {
        didSet {
            if let data = self.imageData {
                if let delegateImage = delegate?.thumbnailImageViewShouldReturnImageAs(self, imageData: data) {
                    image = delegateImage
                } else {
                    image = UIImage(data: data)
                }
            }
        }
    }
}

class ThumbnailCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String = String(describing: ThumbnailCollectionViewCell.self)
    
    weak var imageView: ThumbnailImageView!
    
    var nowFocused: Bool? {
        didSet {
            if let focused = self.nowFocused {
                if focused {
                    self.imageView.alpha = 1
                } else {
                    self.imageView.alpha = 0.5
                }
            }
        }
    }
    
    var giuk: Giuk? {
        didSet {
            if let settedGiuk = self.giuk {
                if let data = settedGiuk.thumbnail?.thumbnailImageData {
                    let thumbnailInfo = ThumbnailInformation.init(json: data)
                    if let thumbnailData = thumbnailInfo?.thumbnailImageData {
                        imageView.imageData = thumbnailData
                    }
                }
            }
        }
    }
    
    private func setOrRepostionImageView() {
        if imageView == nil {
            let newView = generateUIView(view: imageView, frame: bounds)
            imageView = newView
            imageView.contentMode = .scaleAspectFit
            addSubview(imageView)
        } else {
            imageView.setNewFrame(bounds)
        }
    }
    
    override func prepareForReuse() {
        imageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setOrRepostionImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setOrRepostionImageView()
    }
}
