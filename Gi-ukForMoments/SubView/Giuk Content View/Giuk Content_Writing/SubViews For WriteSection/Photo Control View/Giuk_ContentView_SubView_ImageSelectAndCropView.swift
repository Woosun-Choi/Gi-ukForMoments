//
//  Giuk_ContentView_SubView_ImageSelectAndCropView.swift
//  Gi-ukForMoments
//
//  Created by goya on 11/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol ImageSelectAndCropViewDataSource {
    func imageSelectAndCropView(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, numberOfItemsInSection section: Int) -> Int
    func imageSelectAndCropView(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, imageForItemAt indexPath: IndexPath) -> UIImage?
    func imageSelectAndCropView(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, didSelectImageDataAt indexPath: IndexPath) -> Data?
    func imageSelectAndCropView_ShouldPerformActionAfter(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, didSelectImageDataAt indexPath: IndexPath) -> (()->Void)?
}

class Giuk_ContentView_SubView_ImageSelectAndCropView: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    weak var dataSource: ImageSelectAndCropViewDataSource?
    
    var croppedImageData: CroppedImageData? {
        get {
            return imageCropView.croppedImageData
        } set {
            imageCropView.croppedImageData = newValue
        }
    }
    
    var filterModule = ImageFilterModule()
    
    var filterEffect : ImageFilterModule.CIFilterName = .CIPhotoEffectTonal
    
    var isUserSelected: Bool = false
    
    var isHorizontal: Bool = false {
        didSet {
            updateLayoutsAndReloadData()
        }
    }
    
    var image: Data? {
        get {
            return imageCropView.image
        } set {
            imageCropView.image = newValue
        }
    }
    
    func checkAndPresentWritingMode() {
        setOrRepositionCollectionView()
    }
    
    var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    
    weak var collectionView: UICollectionView!
    
    weak var imageCropView: ImageCroppingView!
    
    //MARK: Layouts
    private func setOrRepositionImageCropView() {
        if imageCropView == nil {
            let newView = generateUIView(view: imageCropView, origin: estimateAreaOfImageCorpView.origin, size: estimateAreaOfImageCorpView.size)
            imageCropView = newView
            imageCropView.backgroundColor = .clear
            imageCropView.filterModule = filterModule
            imageCropView.filterEffect = filterEffect
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
            collectionView.backgroundColor = .clear
            collectionView.showsVerticalScrollIndicator = false
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.alwaysBounceVertical = true
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
        if collectionView != nil {
            collectionView.reloadData()
            if collectionView.numberOfItems(inSection: 0) > 0 {
                collectionView.scrollToItem(at: selectedIndex, at: .centeredVertically, animated: false)
            }
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayoutsAndReloadData()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    //end
    
    //MARK: collectionView datasources
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.imageSelectAndCropView(self, numberOfItemsInSection: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Image_CollectionViewCell.reuseIdentifire, for: indexPath) as! Image_CollectionViewCell
        let filteredImage = filterModule.performImageFilter(.CIPhotoEffectTonal, image: dataSource?.imageSelectAndCropView(self, imageForItemAt: indexPath) ?? UIImage())
        cell.imageView?.image = filteredImage
        if isUserSelected && indexPath == selectedIndex {
            cell.didSelected = true
        }
        return cell
    }
    //end
    
    //MARK: collectionView delegate sources
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isUserSelected {
            if selectedIndex != indexPath {
                imageCropView.spinner.isHidden = false
                imageCropView.spinner.startAnimating()
            }
        } else {
            imageCropView.spinner.isHidden = false
            imageCropView.spinner.startAnimating()
        }
        DispatchQueue.global(qos: .userInitiated).async {
            [unowned self] in
            if let originalData = self.dataSource?.imageSelectAndCropView(self, didSelectImageDataAt: indexPath) {
                DispatchQueue.main.async {
                    if self.isUserSelected {
                        if self.selectedIndex != indexPath {
                            self.imageCropView.image = originalData
                            self.selectedIndex = indexPath
                        } else {
                            return
                        }
                    } else {
                        self.imageCropView.image = originalData
                        self.selectedIndex = indexPath
                        self.isUserSelected = true
                    }
                    collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
                    self.checkSelectedCell()
                    self.dataSource?.imageSelectAndCropView_ShouldPerformActionAfter(self, didSelectImageDataAt: indexPath)?()
                    self.imageCropView.spinner.isHidden = true
                    self.imageCropView.spinner.stopAnimating()
                }
            }
        }
    }
    
    func checkSelectedCell() {
        if isUserSelected {
            for item in 0..<(dataSource?.imageSelectAndCropView(self, numberOfItemsInSection: 0) ?? 1) {
                let index = IndexPath(item: item, section: 0)
                if let cell = collectionView.cellForItem(at: index) as? Image_CollectionViewCell {
                    if index == selectedIndex {
                        cell.didSelected = true
                    } else {
                        cell.didSelected = false
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if ((collectionView.frame.width/collectionView.frame.height) > 1) {
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
    //end
    
    //MARK: init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateLayouts()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateLayouts()
    }
    //end
    
    func clearAllContent() {
        imageCropView.image = nil
        collectionView?.reloadData()
    }
    
}

extension Giuk_ContentView_SubView_ImageSelectAndCropView {
    
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
    
    var estimateMarginForCollectionView: CGFloat {
        return 5
    }
    
    var estimateAreaOfCollectionView: CGRect {
        if isHorizontal {
            let width = frame.width - (estimateMarginForCollectionView*2)
            let height = frame.height - estimateAreaOfImageCorpView.height - (estimateMarginForCollectionView*2)
            let size = CGSize(width: width, height: height)
            let originX : CGFloat = estimateMarginForCollectionView
            let originY = estimateAreaOfImageCorpView.maxY + estimateMarginForCollectionView
            let origin = CGPoint(x: originX, y: originY)
            return CGRect(origin: origin, size: size)
        } else {
            let height = frame.height - (estimateMarginForCollectionView*2)
            let width = frame.width - estimateAreaOfImageCorpView.width - (estimateMarginForCollectionView*2)
            let size = CGSize(width: width, height: height)
            let origin = CGPoint(x: estimateMarginForCollectionView, y: estimateMarginForCollectionView)
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
