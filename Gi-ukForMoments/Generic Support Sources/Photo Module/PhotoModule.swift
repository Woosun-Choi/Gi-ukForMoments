//
//  PhotoModule.swift
//  LinearTimeLineViewDemo
//
//  Created by goya on 19/04/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation
import Photos

struct Thumbnail_DataType {
    
    var data: Data?
    var createdDate: Date?
    var index: Int?
    
    init(data: Data, created: Date, index: Int) {
        self.data = data
        self.createdDate = created
        self.index = index
    }
}

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
    
    enum RequestType {
        case all
        case toDay
    }
    
    enum RequestQuallity {
        case fast
        case high
    }
    
    var requestedType: RequestType = .all {
        didSet {
            if self.requestedType == .all {
                fetchOptions.predicate = nil
            } else {
                let predicate_1: NSPredicate = NSPredicate(format: "%K > %@", #keyPath(PHAsset.creationDate), requestedDate.presentDate_typeFull as CVarArg)
                let predicate_2: NSPredicate = NSPredicate(format: "%K < %@", #keyPath(PHAsset.creationDate), requestedDate.afterDate_typeFull as CVarArg)
                let andPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates: [predicate_1, predicate_2])
                fetchOptions.predicate = andPredicate
                
            }
        }
    }
    
    var requestedDate: Date! = Date()
    
    var requestedActionWhenAuthorized: (()->Void)?
    
    private var imageManager : PHImageManager = PHImageManager.default()
    private var requestOptions : PHImageRequestOptions = PHImageRequestOptions()
    private var fetchOptions : PHFetchOptions = PHFetchOptions()
    private var thumbnailSize: CGFloat = 100
    
    private func setRequestOptionsForQuallity(quallity: RequestQuallity, ascending: Bool) {
        switch quallity {
        case .fast:
            requestOptions.isSynchronous = true
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .fastFormat
            requestOptions.resizeMode = .fast
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: ascending)]
        case .high :
            requestOptions.isSynchronous = true
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .opportunistic
            requestOptions.resizeMode = .exact
            fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: ascending)]
        }
    }
    
    var indexList : [Int]?
    
    mutating func setIndexListOfThumbnails() -> [Int]? {
        var thumbnails = [Int]()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResault.count > 0 {
            for item in 0..<fetchResault.count {
                thumbnails.append(item)
            }
            if thumbnails.count > 0 {
                self.indexList = thumbnails
                return thumbnails
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getThumbnailFromIndex(_ index: Int, size: CGFloat? = nil) -> UIImage? {
        var requestedSizeFactor = thumbnailSize
        if let requsetedSize = size {
            requestedSizeFactor = requsetedSize
        }
        
        setRequestOptionsForQuallity(quallity: .fast, ascending: false)
        
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResault.count > 0 {
            var fetchedImage: UIImage?
            let imageAsset = fetchResault.object(at: index)
            imageManager.requestImage(for: imageAsset, targetSize: CGSize(width: requestedSizeFactor, height: requestedSizeFactor), contentMode: .aspectFill, options: requestOptions) { (image, hashable) in
                fetchedImage = image
            }
            return fetchedImage
        } else {
            return nil
        }
    }
    
    func getImageArrayWithThumbnails_AsData(_ size: CGFloat? = nil) -> [Thumbnail_DataType]? {
        
        var requestedSizeFactor = thumbnailSize
        if let requsetedSize = size {
            requestedSizeFactor = requsetedSize
        }
        
        var thumbnails = [Thumbnail_DataType]()
        
        setRequestOptionsForQuallity(quallity: .fast, ascending: false)
        
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResault.count > 0 {
            for item in 0..<fetchResault.count {
                let imageAsset = fetchResault.object(at: item)
                imageManager.requestImage(for: imageAsset, targetSize: CGSize(width: requestedSizeFactor, height: requestedSizeFactor), contentMode: .aspectFill, options: requestOptions, resultHandler: {
                    (image, error) in
                    
                    if let fetchedImage = image, let imagesCreatedDate = imageAsset.creationDate {
                        if let fetchedData = fetchedImage.jpegData(compressionQuality: 0.5) {
                            thumbnails.append(Thumbnail_DataType(data: fetchedData, created: imagesCreatedDate, index: item))
                        }
                    }
                    
                })
            }
            
            if thumbnails.count > 0 {
                return thumbnails
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getImageArrayWithThumbnails_AsUIImage(_ size: CGFloat? = nil) -> [Thumbnail]? {
        
        var requestedSizeFactor = thumbnailSize
        if let requsetedSize = size {
            requestedSizeFactor = requsetedSize
        }
        
        var thumbnails = [Thumbnail]()
        
        setRequestOptionsForQuallity(quallity: .fast, ascending: false)
        
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResault.count > 0 {
            for item in 0..<fetchResault.count {
                let imageAsset = fetchResault.object(at: item)
                imageManager.requestImage(for: imageAsset, targetSize: CGSize(width: requestedSizeFactor, height: requestedSizeFactor), contentMode: .aspectFill, options: requestOptions, resultHandler: {
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
        
        let instantRequestOptions : PHImageRequestOptions = PHImageRequestOptions()
        let instantFetchOptions : PHFetchOptions = PHFetchOptions()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(PHAsset.creationDate), date as CVarArg)
        
        instantRequestOptions.isSynchronous = true
        instantRequestOptions.isNetworkAccessAllowed = true
        instantRequestOptions.deliveryMode = .opportunistic
        instantRequestOptions.resizeMode = .exact
        instantFetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        instantFetchOptions.predicate = predicate
        
        var myImageData : Data!
        
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: instantFetchOptions)
        
        print(fetchResault.count)
        if fetchResault.count > 0 {
            if let imageAsset = fetchResault.firstObject {
                imageManager.requestImageData(for: imageAsset, options: requestOptions) {
                    (data, string, orientation, hashable) in
                    if let fetchedImage = data {
                        myImageData = fetchedImage
                    }
                }
                return myImageData
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getOriginalImageFromDate_AsSize(_ date: Date, size: CGFloat) -> Data? {
        
        let instantRequestOptions : PHImageRequestOptions = PHImageRequestOptions()
        let instantFetchOptions : PHFetchOptions = PHFetchOptions()
        let predicate = NSPredicate(format: "%K == %@", #keyPath(PHAsset.creationDate), date as CVarArg)
        
        instantRequestOptions.isSynchronous = true
        instantRequestOptions.isNetworkAccessAllowed = true
        instantRequestOptions.deliveryMode = .opportunistic
        instantRequestOptions.resizeMode = .exact
        instantFetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        instantFetchOptions.predicate = predicate
        
        var myImageData : Data!
        
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: instantFetchOptions)
        
        if fetchResault.count > 0 {
            let asset = fetchResault.object(at: 0)
            let ratio = CGFloat(Double(asset.pixelWidth)/Double(asset.pixelHeight))
            var newWidth : CGFloat = 0
            var newHeight: CGFloat = 0
            if ratio > 1 {
                newHeight = size
                newWidth = newHeight * ratio
            } else {
                newWidth = size
                newHeight = newWidth / ratio
            }
            let newSize = CGSize(width: newWidth, height: newHeight)
            imageManager.requestImage(for: asset, targetSize: newSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                image, error in
                if let myImage = image {
                    myImageData = myImage.jpegData(compressionQuality: 1)
                    print(myImage.size.width)
                }
            })
            return myImageData
        } else {
            return nil
        }
    }
    
    func getOriginalImageFromIndex(_ index: Int) -> Data? {
        
        setRequestOptionsForQuallity(quallity: .high, ascending: false)
        
        var myImageData : Data!
        
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResault.count > 0 {
            imageManager.requestImageData(for: fetchResault.object(at: index), options: requestOptions) {
                (data, string, orientation, hashable) in
                myImageData = data
            }
            return myImageData
        } else {
            return nil
        }
    }
    
    func getOriginalImageWithSize(_ index: Int, size targetSize: CGFloat) -> Data? {
        
        var myImageData : Data!
        
        setRequestOptionsForQuallity(quallity: .high, ascending: false)
        
        let fetchResault : PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        if fetchResault.count > 0 {
            let asset = fetchResault.object(at: index)
            let ratio = CGFloat(Double(asset.pixelHeight)/Double(asset.pixelWidth))
            print("height: \(asset.pixelHeight) width: \(asset.pixelWidth)")
            print(ratio)
            let newWidth = targetSize
            let newHeight = newWidth * ratio
            let newSize = CGSize(width: newWidth, height: newHeight)
            imageManager.requestImage(for: asset, targetSize: newSize, contentMode: .aspectFill, options: requestOptions, resultHandler: {
                image, error in
                if let myImage = image {
                    myImageData = myImage.jpegData(compressionQuality: 1)
                    print(myImage.size.width)
                }
            })
            return myImageData
        } else {
            return nil
        }
    }
    
    //MARK: authorizeChecker
    func authorizeChecker() {
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
    
    init(_ requestType : RequestType, requestedActionWhenAuthorized: (()->Void)? = nil) {
        self.requestedType = requestType
        self.requestedActionWhenAuthorized = requestedActionWhenAuthorized
    }
    
}
