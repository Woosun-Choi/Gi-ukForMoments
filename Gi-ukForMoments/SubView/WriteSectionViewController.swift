//
//  TestViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 30/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class WriteSectionViewController: Giuk_OpenFromFrame_ViewController, ImageSelectAndCropViewDataSource {
    
    weak var contentView: Giuk_ContentView_WriteSection!
    
    //MARK: CollectionView RelatedVariables
    var photoModule = PhotoModule(.all)
    
    var thumbnails : [Thumbnail]? {
        didSet {
            DispatchQueue.main.async {
                self.contentView.photoControlView.collectionView?.reloadData()
            }
        }
    }
    
    var selectedIndex: IndexPath {
        get {
            return photoControlView.selectedIndex
        } set {
            photoControlView.selectedIndex = newValue
        }
    }
    
    var isUserSelected: Bool = false
    
    var photoControlView: Giuk_ContentView_SubView_ImageSelectAndCropView! {
        return contentView.photoControlView
    }
    //end

    //MARK: Controller Lifecyle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .GiukBackgroundColor_depth_1
        setContentView()
        photoModule.requestedActionWhenAuthorized = {
            [unowned self] in
            self.thumbnails = self.photoModule.getImageArrayWithThumbnails_AsUIImage()
        }
        photoControlView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setCloseButton()
        setContentView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photoModule.authorizeChecker()
    }
    //end
    
    override func closeButtonAction(_ sender: UIButton) {
        thumbnails = nil
        photoControlView.resetAllContent()
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Set subviews & Layouts
    func setContentView() {
        if contentView == nil {
            let view = generateUIView(view: contentView, origin: safeAreaRelatedAreaFrame.origin, size: safeAreaRelatedAreaFrame.size)
            contentView = view
            self.view?.addSubview(contentView)
        } else {
            contentView.setNewFrame(safeAreaRelatedAreaFrame)
        }
    }
    
    //end
    
}

extension WriteSectionViewController {
    
    //MARK: PhoroControlview datasource
    func imageSelectAndCropView(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails?.count ?? 0
    }
    
    func imageSelectAndCropView(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, imageForItemAt indexPath: IndexPath) -> UIImage {
        return thumbnails?[indexPath.row].image ?? UIImage()
    }
    
    func imageSelectAndCropView(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, didSelectImageDataAt indexPath: IndexPath) -> Data? {
        if let thumbIndex = thumbnails?[indexPath.row].createdDate {
            print(thumbIndex)
            let data = photoModule.getOriginalImageFromDate_AsSize(thumbIndex, size: 600)
            return data
        } else {
            return nil
        }
    }
    
    func imageSelectAndCropView_ShouldPerformActionAfter(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, didSelectImageDataAt indexPath: IndexPath) -> (() -> Void)? {
        return {
            self.contentView.checkImageExist()
        }
    }
    //end
}

extension WriteSectionViewController {
    
    //MARK: Frmae sources
    var topBackgroundFrame: CGRect {
        let width = view.frame.width
        let heigth = bottomContainerAreaFrame.minY
        let size = CGSize(width: width, height: heigth)
        let origin = CGPoint.zero
        return CGRect(origin: origin, size: size)
    }
    
    var bottomBackgroundFrame: CGRect {
        let width = view.frame.width
        let height = view.frame.height - bottomContainerAreaFrame.minY
        let size = CGSize(width: width, height: height)
        let originX: CGFloat = 0
        let originY = bottomContainerAreaFrame.minY
        let origin = CGPoint(x: originX, y: originY)
        return CGRect(origin: origin, size: size)
    }
    
    var topBackgroundPath: UIBezierPath {
        let width = view.frame.width
        let heigth = bottomContainerAreaFrame.minY
        let size = CGSize(width: width, height: heigth)
        let origin = CGPoint.zero
        return UIBezierPath(rect: CGRect(origin: origin, size: size))
    }
    
    var bottomBackgroundPath: UIBezierPath {
        let width = view.frame.width
        let height = view.frame.height - bottomContainerAreaFrame.minY
        let size = CGSize(width: width, height: height)
        let originX: CGFloat = 0
        let originY = bottomContainerAreaFrame.minY
        let origin = CGPoint(x: originX, y: originY)
        return UIBezierPath(rect: CGRect(origin: origin, size: size))
    }
    
}

//func setOrRepostionBackgroundView() {
//    if backgroundView == nil {
//        let newView = generateUIView(view: backgroundView, origin: CGPoint.zero, size: view.bounds.size)
//        backgroundView = newView
//        backgroundView.isOpaque = false
//        backgroundView.backgroundColor = UIColor.init(red: 105/255, green: 106/255, blue: 106/255, alpha: 1)
//        view.addSubview(backgroundView)
//    } else {
//        backgroundView.setNewFrame(view.bounds)
//    }
//}
//
//func setSubLayer() {
//    if (view.layer.sublayers?.count ?? 0) > 0 {
//        let topBackgroundLayer = CALayer()
//        topBackgroundLayer.frame = topBackgroundFrame
//        topBackgroundLayer.backgroundColor = UIColor.goyaSemiBlackColor.withAlphaComponent(0.7).cgColor
//        let bottomBackgroundLayer = CALayer()
//        bottomBackgroundLayer.frame = bottomBackgroundFrame
//        bottomBackgroundLayer.isOpaque = false
//        bottomBackgroundLayer.backgroundColor = UIColor.goyaSemiBlackColor.withAlphaComponent(0.7).cgColor
//        view.layer.addSublayer(topBackgroundLayer)
//        view.layer.addSublayer(bottomBackgroundLayer)
//    }
//}
