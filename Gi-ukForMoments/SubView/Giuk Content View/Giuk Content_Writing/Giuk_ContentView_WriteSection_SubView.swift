//
//  Giuk_ContentView_WriteSection_SubView.swift
//  Gi-ukForMoments
//
//  Created by goya on 28/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class Giuk_ContentView_WriteSection_SubView: UIView, UICollectionViewDelegateFlowLayout {
    
    var photoManager = PhotoModule(.all)
    
    weak var giukContentView: UIView! //mianPhotoControlview
    
    weak var giukTagView: UIView! //hastagView

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension Giuk_ContentView_WriteSection_SubView {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width / 4 - 7.5
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 2.5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
    }
}
