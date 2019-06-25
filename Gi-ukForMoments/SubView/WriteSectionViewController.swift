//
//  TestViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 30/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class WriteSectionViewController: Giuk_OpenFromFrame_ViewController, GiukContentView_WritingDatasource {
    
    weak var contentView: Giuk_ContentView_WriteSection!
    
    //MARK: CollectionView RelatedVariables
    private var photoModule = PhotoModule(.all)
    
    private var thumbnails : [Thumbnail]? {
        didSet {
            DispatchQueue.main.async {
                self.photoControlView.collectionView?.reloadData()
            }
        }
    }
    
    private var photoControlView: Giuk_ContentView_SubView_ImageSelectAndCropView! {
        return contentView.writingView.photoControlView
    }
    //end

    //MARK: Controller Lifecyle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .GiukBackgroundColor_depth_1
        setContentView()
        contentView.dataSource = self
        photoModule.requestedActionWhenAuthorized = {
            [unowned self] in
            self.thumbnails = self.photoModule.getImageArrayWithThumbnails_AsUIImage()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setContentView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photoModule.authorizeChecker()
    }
    //end
    
    override func closeButtonAction(_ sender: UIButton) {
        thumbnails = nil
        photoControlView.clearAllContent()
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
    
    deinit {
        contentView = nil
        print("viewcontroller gone")
    }
    
}

extension WriteSectionViewController {
    
    //MARK: Frame datasource for control TextControlview
    
    func writeSectionView_OwnerView(_ writingView: Giuk_ContentView_Writing) -> UIView? {
        return view
    }
    
    func writeSectionView_ViewCoordinatesInOwnerView(_ writingView: Giuk_ContentView_Writing) -> CGRect {
        return view.convert(contentView.writingView.frame, from: contentView)
    }
    
    func writeSectionView(_ writingView: Giuk_ContentView_Writing, numberOfImagesInSection section: Int) -> Int {
        return thumbnails?.count ?? 0
    }
    
    func writeSectionView(_ writingView: Giuk_ContentView_Writing, thumbnailImageForItemAt indexPath: IndexPath) -> UIImage? {
        return thumbnails?[indexPath.row].image
    }
    
    func writeSectionView(_ writingView: Giuk_ContentView_Writing, didSelectImageDataAt indexPath: IndexPath) -> Data? {
        if let thumbIndex = thumbnails?[indexPath.row].createdDate {
            print(thumbIndex)
            let data = photoModule.getOriginalImageFromDate_AsSize(thumbIndex, size: 600)
            return data
        } else {
            return nil
        }
    }
    
    func writeSectionView_ShouldPerformActionAfter(_ writingView: Giuk_ContentView_Writing) -> (() -> Void)? {
        return {
            self.contentView.checkImageExist()
        }
    }
    
//    func writeSectionView_ownerViewController(_ writeSectionView: Giuk_ContentView_WriteSection) -> UIViewController {
//        return self
//    }
//
//    func writeSectionView(_ writeSectionView: Giuk_ContentView_WriteSection, numberOfImagesInSection section: Int) -> Int {
//        return thumbnails?.count ?? 0
//    }
//
//    func writeSectionView(_ writeSectionView: Giuk_ContentView_WriteSection, thumbnailImageForItemAt indexPath: IndexPath) -> UIImage? {
//        return thumbnails?[indexPath.row].image
//    }
//
//    func writeSectionView(_ writeSectionView: Giuk_ContentView_WriteSection, didSelectImageDataAt indexPath: IndexPath) -> Data? {
//        if let thumbIndex = thumbnails?[indexPath.row].createdDate {
//            print(thumbIndex)
//            let data = photoModule.getOriginalImageFromDate_AsSize(thumbIndex, size: 600)
//            return data
//        } else {
//            return nil
//        }
//    }
//
//    func writeSectionView_ShouldPerformActionAfter(_ writeSectionView: Giuk_ContentView_WriteSection) -> (() -> Void)? {
//        return {
//            self.contentView.checkImageExist()
//        }
//    }
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
