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
    
    var requieredActionWhenSavingComplete: (() -> Void)?
    
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
                requieredActionWhenSavingComplete?()
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
                self.photoControlView?.updateLayoutsAndReloadData(animate: true, duration: 0.45)
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
        self.thumbnails = nil
        self.photoControlView?.clearAllContent()
        super.closeButtonAction(sender)
//        UIView.animate(withDuration: 0.25, animations: {
//            self.closeButton.alpha = 0
//            self.writingSection?.alpha = 0
//        }) { (finished) in
//            self.thumbnails = nil
//            self.photoControlView?.clearAllContent()
//            self.dismiss(animated: true, completion: nil)
//        }
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
            if isNonColorPresneting {
                let filteredImage = filterModule.performImageFilter(filterEffect, image: thumbImage)
                return filteredImage
            } else {
                return thumbImage
            }
        } else {
            return nil
        }
    }
    
    func writingView(_ writingView: Giuk_ContentView_Writing, didSelectImageDataAt indexPath: IndexPath) -> Data? {
        if let thumbIndex = thumbnails?[indexPath.row].createdDate {
            let data = photoModule.getOriginalImageFromDate_AsSize(thumbIndex, size: 1000)
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
        if isNonColorPresneting {
            if let image = UIImage(data: imageData)?.fixOrientation() {
                return filterModule.performImageFilter(filterEffect, image: image)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    //end
}

extension WriteSectionViewController {
    
    //MARK: Frmae sources
    
}
