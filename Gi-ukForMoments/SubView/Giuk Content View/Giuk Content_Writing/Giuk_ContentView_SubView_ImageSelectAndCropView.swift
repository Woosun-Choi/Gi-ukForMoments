//
//  Giuk_ContentView_SubView_ImageSelectAndCropView.swift
//  Gi-ukForMoments
//
//  Created by goya on 11/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class Giuk_ContentView_SubView_ImageSelectAndCropView: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var photoModule = PhotoModule(.all)
    
    var filterModule = ImageFilterModule()
    
    var isHorizontal: Bool = false {
        didSet {
            updateLayoutsAndReloadData()
        }
    }
    
    var thumbnails : [Thumbnail]? {
        didSet {
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
    }
    
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    
    var isUserSelected: Bool = false
    
    weak var collectionView: UICollectionView!
    
    weak var imageCropView: ImageCroppingView!
    
    //MARK: CollectionView datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Image_CollectionViewCell.reuseIdentifire, for: indexPath) as! Image_CollectionViewCell
        cell.setOrRepositionImageView()
        let filteredImage = filterModule.performImageFilter(.CIPhotoEffectTonal, image: thumbnails?[indexPath.row].image ?? UIImage())
        cell.imageView?.image = filteredImage
        if isUserSelected && indexPath == selectedIndex {
            cell.imageView.alpha = 0.3
        }
        return cell
    }
    //end
    
    //MARK: CollectionView delegates
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let thumbData = thumbnails?[indexPath.row].indexInPhotoLibary {
            if isUserSelected {
                if selectedIndex != indexPath {
                    selectedIndex = indexPath
                    if let originalData = photoModule.getOriginalImageFromFetchResultsArrayIndex(thumbData) {
                        imageCropView.image = originalData
                    }
                } else {
                    return
                }
            } else {
                selectedIndex = indexPath
                isUserSelected = true
                if let originalData = photoModule.getOriginalImageFromFetchResultsArrayIndex(thumbData) {
                    imageCropView.image = originalData
                }
            }
        }
        checkSelectedCell()
    }
    //end
    
    //MARK: CollectionView Controll Methods
    func checkSelectedCell() {
        if isUserSelected {
            for item in 0..<(thumbnails?.count ?? 1) {
                let index = IndexPath(item: item, section: 0)
                if let cell = collectionView.cellForItem(at: index) as? Image_CollectionViewCell {
                    if index == selectedIndex {
                        cell.imageView.alpha = 0.3
                    } else {
                        cell.imageView.alpha = 1
                    }
                }
            }
        }
    }
    //end
    
    //MARK: Layouts
    private func setOrRepositionImageCropView() {
        if imageCropView == nil {
            let newView = generateUIView(view: imageCropView, origin: estimateAreaOfImageCorpView.origin, size: estimateAreaOfImageCorpView.size)
            imageCropView = newView
            imageCropView.filterModule = filterModule
            imageCropView.filterEffect = .CIPhotoEffectTonal
            imageCropView.cropAreaShape = .full
            addSubview(imageCropView)
        } else {
            imageCropView.setNewFrame(estimateAreaOfImageCorpView)
        }
    }
    
    private func setOrRepositionCollectionView() {
        if collectionView == nil {
            let layout = UICollectionViewFlowLayout()
            let newView = UICollectionView(frame: estimateAreaOfCollectionView, collectionViewLayout: layout)
            collectionView = newView
            collectionView.backgroundColor = .goyaYellowWhite
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(Image_CollectionViewCell.self, forCellWithReuseIdentifier: Image_CollectionViewCell.reuseIdentifire)
            addSubview(collectionView)
        } else {
            collectionView.setNewFrame(estimateAreaOfCollectionView)
        }
    }
    
    func updateLayouts() {
        setOrRepositionImageCropView()
        setOrRepositionCollectionView()
    }
    
    func updateLayoutsAndReloadData() {
        updateLayouts()
        collectionView.reloadData()
        if thumbnails != nil {
            collectionView.scrollToItem(at: selectedIndex, at: .centeredVertically, animated: false)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayoutsAndReloadData()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        photoModule.authorizeChecker()
    }
    //end
    
    //MARK: init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateLayouts()
        photoModule.requestedActionWhenAuthorized = {
            [unowned self] in
            self.thumbnails = self.photoModule.getImageArrayWithThumbnails_AsUIImage()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateLayouts()
        photoModule.requestedActionWhenAuthorized = {
            self.thumbnails = self.photoModule.getImageArrayWithThumbnails_AsUIImage()
        }
    }
    //end
    
}

extension Giuk_ContentView_SubView_ImageSelectAndCropView {
    
    var estimateAreaOfImageCorpView: CGRect {
        if isHorizontal {
            let width = frame.width
            let height = width/1.618
            let size = CGSize(width: width, height: height)
            let origin = CGPoint.zero
            return CGRect(origin: origin, size: size)
        } else {
            let height = frame.height
            let width = height/2.589
            let size = CGSize(width: width, height: height)
            let originX = frame.width - width
            let originY : CGFloat = 0
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        }
    }
    
    var estimateMarginForCollectionView: CGFloat {
        return 5
    }
    
    var estimateAreaOfCollectionView: CGRect {
        if isHorizontal {
            let width = frame.width
            let height = frame.height - estimateAreaOfImageCorpView.height - (estimateMarginForCollectionView*2)
            let size = CGSize(width: width, height: height)
            let originX : CGFloat = 0
            let originY = estimateAreaOfImageCorpView.maxY + estimateMarginForCollectionView
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        } else {
            let height = frame.height - (estimateMarginForCollectionView*2)
            let width = frame.width - estimateAreaOfImageCorpView.width
            let size = CGSize(width: width, height: height)
            let origin = CGPoint(x: 0, y: estimateMarginForCollectionView)
            return CGRect(origin: origin, size: size)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isHorizontal {
            let width = collectionView.frame.width / 4 - 7.5
            return CGSize(width: width, height: width)
        } else {
            let width = collectionView.frame.width / 2 - 7.5
            return CGSize(width: width, height: width)
        }
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
