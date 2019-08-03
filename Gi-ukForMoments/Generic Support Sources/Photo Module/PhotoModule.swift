//
//  PhotoModule.swift
//  LinearTimeLineViewDemo
//
//  Created by goya on 19/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation
import Photos

struct Thumbnail {
    var image: UIImage
    var createdDate: Date
    var indexInPhotoLibary: Int
}

struct OriginalImage {
    var data: Data?
    var createdDate: Date?
    init(data: Data, created: Date) {
        self.data = data
        self.createdDate = created
    }
}

struct PhotoModule {
    
    var requestedActionWhenAuthorized: (()->Void)?
    
    private var thumbnailSize: CGFloat = 100
    
    var imageManager: PHImageManager {
        return PHImageManager.default()
    }
    
    func requestOption(deliverMode: PHImageRequestOptionsDeliveryMode = .opportunistic, resizeMode: PHImageRequestOptionsResizeMode = .exact) -> PHImageRequestOptions {
        let instantRequestOptions : PHImageRequestOptions = PHImageRequestOptions()
        instantRequestOptions.isSynchronous = true
        instantRequestOptions.isNetworkAccessAllowed = true
        instantRequestOptions.deliveryMode = deliverMode
        instantRequestOptions.resizeMode = resizeMode
        return instantRequestOptions
    }
    
    func getAllPHAssets(ascending: Bool = false) -> PHFetchResult<PHAsset> {
        let instantFetchOptions : PHFetchOptions = PHFetchOptions()
        instantFetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: ascending)]
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: instantFetchOptions)
        if fetchResault.count > 0 {
            return fetchResault
        } else {
            return PHFetchResult<PHAsset>()
        }
    }
    
    func getPHAssetsADayWithInDate(date: Date = Date() ,ascending: Bool = false) -> PHFetchResult<PHAsset> {
        let instantFetchOptions : PHFetchOptions = PHFetchOptions()
        
        let predicate_1: NSPredicate = NSPredicate(format: "%K > %@", #keyPath(PHAsset.creationDate), date.presentDate_typeFull as CVarArg)
        let predicate_2: NSPredicate = NSPredicate(format: "%K < %@", #keyPath(PHAsset.creationDate), date.afterDate_typeFull as CVarArg)
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate_1, predicate_2])
        instantFetchOptions.predicate = compoundPredicate
        
        instantFetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: ascending)]
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: instantFetchOptions)
        if fetchResault.count > 0 {
            return fetchResault
        } else {
            return PHFetchResult<PHAsset>()
        }
    }
    
    func getPHAssets(ascending: Bool = false) -> PHFetchResult<PHAsset> {
        let instantFetchOptions : PHFetchOptions = PHFetchOptions()
        instantFetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: ascending)]
        
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: instantFetchOptions)
        
        if fetchResault.count > 0 {
            return fetchResault
        } else {
            return PHFetchResult<PHAsset>()
        }
    }
    
    func getPHAssetFromDate(_ date: Date) -> PHAsset? {
        let instantFetchOptions : PHFetchOptions = PHFetchOptions()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(PHAsset.creationDate), date as CVarArg)
        instantFetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        instantFetchOptions.predicate = predicate
        
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: instantFetchOptions)
        
        if fetchResault.count > 0 {
            return fetchResault.object(at: 0)
        } else {
            return nil
        }
    }
    
    func getPHAssetFromIndex(_ index: Int) -> PHAsset? {
        let instantFetchOptions : PHFetchOptions = PHFetchOptions()
        instantFetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: instantFetchOptions)
        
        if fetchResault.count > 0 {
            return fetchResault.object(at: index)
        } else {
            return nil
        }
    }
    
    func getImageArrayWithThumbnails_AsUIImage(_ size: CGFloat? = nil) -> [Thumbnail]? {
        var requestedSizeFactor: CGFloat {
            if let requestedSize = size {
                return requestedSize
            } else {
                return thumbnailSize
            }
        }
        
        var thumbnails = [Thumbnail]()
        
        let fetchResault = getPHAssets(ascending: false)
        let _requestOption = requestOption(deliverMode: .fastFormat, resizeMode: .fast)
        if fetchResault.count > 0 {
            for item in 0..<fetchResault.count {
                let imageAsset = fetchResault.object(at: item)
                imageManager.requestImage(for: imageAsset, targetSize: CGSize(width: requestedSizeFactor, height: requestedSizeFactor), contentMode: .aspectFill, options: _requestOption, resultHandler: {
                    (image, error) in
                    if let fetchedImage = image, let imagesCreatedDate = imageAsset.creationDate {
                        thumbnails.append(Thumbnail(image: fetchedImage, createdDate: imagesCreatedDate, indexInPhotoLibary: item))
                    }
                })
            }
            return thumbnails
        } else {
            return nil
        }
    }
    
    func getOriginalImageFromDate(_ date: Date) -> Data? {
        var imageData: Data!
        if let assetData = getPHAssetFromDate(date) {
            let _requestOption = requestOption()
            imageManager.requestImageData(for: assetData, options: _requestOption) {
                (data, string, orientation, hashable) in
                if let fetchedImage = data {
                    imageData = fetchedImage
                }
            }
            return imageData
        } else {
            return nil
        }
    }
    
    func getOriginalImageFromDate_AsSize(_ date: Date, size: CGFloat) -> Data? {
        if let assetData = getPHAssetFromDate(date) {
            let _requestOption = requestOption()
            var resizedImageData : Data!
            let ratio = CGFloat(Double(assetData.pixelWidth)/Double(assetData.pixelHeight))
            var expectedWidth: CGFloat {
                if ratio > 1 {
                    return size
                } else {
                    return size * ratio
                }
            }
            var expectedHeight: CGFloat {
                if ratio > 1 {
                    return size/ratio
                } else {
                    return size
                }
            }
            let newSize = CGSize(width: expectedWidth, height: expectedHeight)
            imageManager.requestImage(for: assetData, targetSize: newSize, contentMode: .aspectFill, options: _requestOption, resultHandler: {
                image, error in
                if let targetImage = image {
                    resizedImageData = targetImage.jpegData(compressionQuality: 1)
                }
            })
            return resizedImageData
        } else {
            return nil
        }
    }
    
    //MARK: authorizeChecker
    func performAuthorizeChecking() {
        let status = PHPhotoLibrary.authorizationStatus()

        if (status == PHAuthorizationStatus.authorized) {
            // Access has been granted.
            DispatchQueue.global(qos: .userInitiated).async {
                self.requestedActionWhenAuthorized?()
                DispatchQueue.main.async {
                }
            }
        } else if (status == PHAuthorizationStatus.denied) {
            // Access has been denied.
        } else if (status == PHAuthorizationStatus.notDetermined) {
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.requestedActionWhenAuthorized?()
                        DispatchQueue.main.async {
                            //self.images = imageArray
                        }
                    }
                } else {  }
            })
        }
        else if (status == PHAuthorizationStatus.restricted) {
            // Restricted access - normally won't happen.
        }
    }
    
    init(requestedActionWhenAuthorized: (()->Void)? = nil) {
        self.requestedActionWhenAuthorized = requestedActionWhenAuthorized
    }
    
}

//func getOriginalImageFromIndex(_ index: Int) -> Data? {
//
//    setRequestOptionsForQuallity(quallity: .high, ascending: false)
//
//    var myImageData : Data!
//
//    let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//
//    if fetchResault.count > 0 {
//        imageManager.requestImageData(for: fetchResault.object(at: index), options: requestOptions) {
//            (data, string, orientation, hashable) in
//            myImageData = data
//        }
//        return myImageData
//    } else {
//        return nil
//    }
//}
//
//func getOriginalImageWithSize(_ index: Int, size targetSize: CGFloat) -> Data? {
//
//    var myImageData : Data!
//
//    setRequestOptionsForQuallity(quallity: .high, ascending: false)
//
//    let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//
//    if fetchResault.count > 0 {
//        let asset = fetchResault.object(at: index)
//        let imageRatio = CGFloat(Double(asset.pixelWidth)/Double(asset.pixelHeight))
//        var isHorizontalImage: Bool {
//            return imageRatio > 1
//        }
//        var expectedWidth: CGFloat {
//            if isHorizontalImage {
//                return targetSize
//            } else {
//                return targetSize * imageRatio
//            }
//        }
//        var expectedHeight: CGFloat {
//            if isHorizontalImage {
//                return targetSize/imageRatio
//            } else {
//                return targetSize
//            }
//        }
//        var expectedSize: CGSize {
//            return CGSize(width: expectedWidth, height: expectedHeight)
//        }
//        imageManager.requestImage(for: asset, targetSize: expectedSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
//            image, error in
//            if let myImage = image {
//                myImageData = myImage.jpegData(compressionQuality: 1)
//            }
//        })
//        return myImageData
//    } else {
//        return nil
//    }
//}

//var indexList : [Int]?
//
//mutating func setIndexListOfThumbnails() -> [Int]? {
//    var thumbnails = [Int]()
//    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//    let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//
//    if fetchResault.count > 0 {
//        for item in 0..<fetchResault.count {
//            thumbnails.append(item)
//        }
//        if thumbnails.count > 0 {
//            self.indexList = thumbnails
//            return thumbnails
//        } else {
//            return nil
//        }
//    } else {
//        return nil
//    }
//}
//
//func getThumbnailFromIndex(_ index: Int, size: CGFloat? = nil) -> UIImage? {
//    var requestedSizeFactor = thumbnailSize
//    if let requsetedSize = size {
//        requestedSizeFactor = requsetedSize
//    }
//
//    setRequestOptionsForQuallity(quallity: .fast, ascending: false)
//
//    let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//
//    if fetchResault.count > 0 {
//        var fetchedImage: UIImage?
//        let imageAsset = fetchResault.object(at: index)
//        imageManager.requestImage(for: imageAsset, targetSize: CGSize(width: requestedSizeFactor, height: requestedSizeFactor), contentMode: .aspectFill, options: requestOptions) { (image, hashable) in
//            fetchedImage = image
//        }
//        return fetchedImage
//    } else {
//        return nil
//    }
//}

//    func getImageArrayWithThumbnails_AsData(_ size: CGFloat? = nil) -> [Thumbnail_DataType]? {
//
//        var requestedSizeFactor = thumbnailSize
//        if let requsetedSize = size {
//            requestedSizeFactor = requsetedSize
//        }
//
//        var thumbnails = [Thumbnail_DataType]()
//
//        setRequestOptionsForQuallity(quallity: .fast, ascending: false)
//
//        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
//
//        if fetchResault.count > 0 {
//            for item in 0..<fetchResault.count {
//                let imageAsset = fetchResault.object(at: item)
//                imageManager.requestImage(for: imageAsset, targetSize: CGSize(width: requestedSizeFactor, height: requestedSizeFactor), contentMode: .aspectFill, options: requestOptions, resultHandler: {
//                    (image, error) in
//
//                    if let fetchedImage = image, let imagesCreatedDate = imageAsset.creationDate {
//                        if let fetchedData = fetchedImage.jpegData(compressionQuality: 0.5) {
//                            thumbnails.append(Thumbnail_DataType(data: fetchedData, created: imagesCreatedDate, index: item))
//                        }
//                    }
//
//                })
//            }
//
//            if thumbnails.count > 0 {
//                return thumbnails
//            } else {
//                return nil
//            }
//        } else {
//            return nil
//        }
//    }

//struct Thumbnail_DataType {
//
//    var data: Data?
//    var createdDate: Date?
//    var index: Int?
//
//    init(data: Data, created: Date, index: Int) {
//        self.data = data
//        self.createdDate = created
//        self.index = index
//    }
//}
