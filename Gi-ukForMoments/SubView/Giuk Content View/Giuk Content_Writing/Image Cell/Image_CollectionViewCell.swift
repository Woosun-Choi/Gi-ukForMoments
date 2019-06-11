//
//  Image_CollectionViewCell.swift
//  Gi-ukForMoments
//
//  Created by goya on 11/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class Image_CollectionViewCell: UICollectionViewCell {
    
    weak var imageView: UIImageView!
    
    static let reuseIdentifire = String(describing: Image_CollectionViewCell.self)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.alpha = 1
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setOrRepositionImageView()
    }
    
    func setOrRepositionImageView() {
        if imageView == nil {
            let newView = generateUIView(view: imageView, origin: CGPoint.zero, size: frame.size)
            imageView = newView
            addSubview(imageView)
        } else {
            imageView.setNewFrame(CGRect(origin: CGPoint.zero, size: frame.size))
        }
    }
    
}
