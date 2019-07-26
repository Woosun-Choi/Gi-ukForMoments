//
//  Giuk_ThumbnailCollectionView.swift
//  Gi-ukForMoments
//
//  Created by goya on 26/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol ThumbnailCollectionViewDelegate {
    @objc optional func collectionView(_ collectionView: Giuk_ThumbnailCollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
}

class Giuk_ThumbnailCollectionView: TimeCollectionView {
    
    weak var thumbnailCollectionViewDelegate: ThumbnailCollectionViewDelegate?
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.dragInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dragInteractionEnabled = true
    }
    
}
