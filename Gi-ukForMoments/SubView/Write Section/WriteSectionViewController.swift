//
//  TestViewController.swift
//  Gi-ukForMoments
//
//  Created by goya on 30/05/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class WriteSectionViewController: Giuk_OpenFromFrame_ViewController, GiukContentView_WritingDatasource, Giuk_ContentView_WriteSection_Delegate {
    
    //MARK: subViews
    weak var writingSection: Giuk_ContentView_WriteSection!
    //end
    
    //MARK: variables
    var tag: String?
    
    var giuk: Giuk?
    
    var primarySelectedTag: String?
    
    var container: NSPersistentContainer? = AppDelegate.persistentContainer
    
    var context: NSManagedObjectContext {
        if let _context = container?.viewContext {
            return _context
        } else {
            return AppDelegate.viewContext
        }
    }
    
    var isEditOnly: Bool = true {
        didSet {
            photoModule.performAuthorizeChecking()
        }
    }
    
    var savingCompleted: Bool = false {
        didSet {
            if self.savingCompleted {
                    print("closing view")
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    //end
    
    //MARK: CollectionView RelatedVariables
    private var photoModule = PhotoModule(.all)
    
    private var filterModule = ImageFilterModule()
    
    var filterEffect : ImageFilterModule.CIFilterName = .CIPhotoEffectTonal
    
    private var thumbnails : [Thumbnail]? {
        didSet {
            DispatchQueue.main.async {
                self.photoControlView?.updateLayoutsAndReloadData()
            }
        }
    }
    
    private var photoControlView: Giuk_ContentView_SubView_ImageSelectAndCropView? {
        return writingSection?.writingView?.photoControlView
    }
    
    private var tagSelectView: TagGenerator? {
        return writingSection?.writingView?.tagControllView
    }
    //end

    //MARK: Controller Lifecyle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .GiukBackgroundColor_depth_1
        setContentView()
        writingSection?.dataSource = self
        writingSection?.delegate = self
        photoModule.requestedActionWhenAuthorized = {
            [unowned self] in
            if !self.isEditOnly {
                self.thumbnails = self.photoModule.getImageArrayWithThumbnails_AsUIImage()
            } else {
                return
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setContentView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setContentView()
        photoModule.performAuthorizeChecking()
        
        if let settedGiuk = giuk {
            let library = Tag.findAllTags(context: context) ?? []
            let data = settedGiuk.createWrotedDataFromGiuk(library)!
            setDataToContentView(cropInfo: data.croppedData, textInfo: data.textData, tagInfo: data.tagData)
        } else {
            let library = Tag.findAllTags(context: context) ?? []
            let tagInformation = TagInformation(alreadyAdded: [], library: library)
            writingSection?.writingView.tagControllView?.tagManager = tagInformation
            if let _tag = primarySelectedTag {
                tagSelectView?.tagManager.addedTags = [_tag]
            }
            writingSection?.writingView.tagControllView?.reloadData()
        }
    }
    //end
    
    func setDataToContentView(cropInfo: CroppedImageInformation, textInfo: TextInformation, tagInfo: TagInformation) {
        if cropInfo.cropInformation.isHorizontal {
            writingSection?.requieredButtonIndexes.photo = 0
        } else {
            writingSection?.requieredButtonIndexes.photo = 1
        }
        
        switch textInfo.alignment {
        case "left":
            writingSection?.requieredButtonIndexes.write = 0
        case "center":
            writingSection?.requieredButtonIndexes.write = 1
        case "right":
            writingSection?.requieredButtonIndexes.write = 2
        default:
            writingSection?.requieredButtonIndexes.write = 0
        }
        
        writingSection?.refreshViewSettingsBeforePresenting()
        
        writingSection?.writingView.photoControlView?.croppedImageData = cropInfo
        writingSection?.writingView.textControlView?.textData = textInfo
        writingSection?.writingView.tagControllView?.tagManager = tagInfo
        writingSection?.writingView.tagControllView?.reloadData()
    }
    
    //MARK: closeButtonAction
    override func closeButtonAction(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.closeButton.alpha = 0
            self.writingSection?.alpha = 0
        }) { (finished) in
            self.thumbnails = nil
            self.photoControlView?.clearAllContent()
            self.dismiss(animated: true, completion: nil)
        }
    }
    //end
    
    //MARK: Set subviews & Layouts
    func setContentView() {
        if writingSection == nil {
            let view = generateUIView(view: writingSection, origin: safeAreaRelatedAreaFrame.origin, size: safeAreaRelatedAreaFrame.size)
            writingSection = view
            self.view?.addSubview(writingSection)
        } else {
            writingSection?.setNewFrame(safeAreaRelatedAreaFrame)
        }
    }
    //end
    
    deinit {
        writingSection = nil
        print("viewcontroller has gone")
    }
    
}

extension WriteSectionViewController {
    
    //MARK: Frame datasource for control TextControlview
    
    func writingView_OwnerView(_ writingView: Giuk_ContentView_Writing) -> UIView? {
        return view
    }
    
    func writingView_ViewCoordinatesInOwnerView(_ writingView: Giuk_ContentView_Writing) -> CGRect {
        return view.convert(writingSection.writingView.frame, from: writingSection)
    }
    
    func writingView(_ writingView: Giuk_ContentView_Writing, numberOfImagesInSection section: Int) -> Int {
        return thumbnails?.count ?? 0
    }
    
    func writingView(_ writingView: Giuk_ContentView_Writing, thumbnailImageForItemAt indexPath: IndexPath) -> UIImage? {
        if let thumbImage = thumbnails?[indexPath.row].image.fixOrientation() {
            let filteredImage = filterModule.performImageFilter(filterEffect, image: thumbImage)
            return filteredImage
        } else {
            return nil
        }
    }
    
    func writingView(_ writingView: Giuk_ContentView_Writing, didSelectImageDataAt indexPath: IndexPath) -> Data? {
        if let thumbIndex = thumbnails?[indexPath.row].createdDate {
            let data = photoModule.getOriginalImageFromDate_AsSize(thumbIndex, size: 1200)
            return data
        } else {
            return nil
        }
    }
    
    func writingView_ShouldPerformActionAfter(_ writingView: Giuk_ContentView_Writing) -> (() -> Void)? {
        return {
            self.writingSection.check_DataIsPrepared()
        }
    }
    
    //MARK: writesection delegate
    func writeSection(_ writeSection: Giuk_ContentView_WriteSection, didEndEditing: Bool, wrotedData: CreatedData) {
        if self.isEditOnly {
            print("performing create database")
            Giuk.createOrEditGiuk(context, giuk: self.giuk, createdData: wrotedData, isFirstWroted: false) {
                self.savingCompleted = true
            }
        } else {
            print("performing create database")
            Giuk.createOrEditGiuk(context, giuk: self.giuk, createdData: wrotedData, isFirstWroted: true) {
                self.savingCompleted = true
            }
        }
    }
    
    func writeSection(_ writeSection: Giuk_ContentView_WriteSection, needRepresentedImageData imageData: Data) -> UIImage? {
        if let image = UIImage(data: imageData)?.fixOrientation() {
            return filterModule.performImageFilter(filterEffect, image: image)
        } else {
            return nil
        }
    }
    //end
    
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
