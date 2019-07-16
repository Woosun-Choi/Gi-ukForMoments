//
//  Giuk.swift
//  Gi-ukForMoments
//
//  Created by goya on 08/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class Giuk: NSManagedObject {
    
    static func allGiuks(context: NSManagedObjectContext) -> [Giuk]? {
        let request: NSFetchRequest<Giuk> = Giuk.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            return nil
        }
    }
    
    var allTagNames : [String] {
        return ((self.tags?.allObjects as? [Tag])?.map{ $0.tagName } as? [String]) ?? [String]()
    }
    
    var allTagIndexes : [[String]]{
        return (((self.tags?.allObjects as? [Tag])?.map{ $0.giukIndex } as? [Data]) ?? [Data]()).map {GiukIndex.init(json: $0)?.indexOfGiuks ?? []}
    }
    
    private func createOrSetNewThumbnailToGiuk(context: NSManagedObjectContext, thumbData: ThumbnailInformation) {
        if self.thumbnail == nil {
            self.thumbnail = ThumbnailImage.createNewThumbnail(context: context, thumbnailData: thumbData)
        } else {
            self.thumbnail?.thumbnailImageData = thumbData.json
        }
    }
    
    private func createOrSetNewImageToGiuk(context: NSManagedObjectContext, imageData: CroppedImageInformation) {
        if self.image == nil {
            self.image = Image.createNewImage(context: context, imageData: imageData)
        } else {
            self.image?.imageData = imageData.json
        }
    }
    
    private func createOrSetNewTextToGiuk(context: NSManagedObjectContext, textData: TextInformation) {
        if self.text == nil {
            self.text = Text.createNewText(context: context, textData: textData)
        } else {
            self.text?.textData = textData.json
        }
    }
    
    private func createNewIdentifireAndCreatedDateToGiuk(identifire: String, createdDate: Date) {
        if self.createdDate == nil {
            self.createdDate = createdDate
        }
        if self.identifire == nil {
            self.identifire = identifire
        }
    }
    
    private func saveOrCreateTagsToGiuk(context: NSManagedObjectContext, tagInformation: TagInformation) throws {
        
        func fetchTag(_ tag: String) throws {
            let request : NSFetchRequest<Tag> = Tag.fetchRequest()
            let predicate = NSPredicate(format: "tagName == %@", tag)
            request.predicate = predicate
            do {
                if let targetTag = try context.fetch(request).first {
                    if let giuks = targetTag.giuks {
                        if giuks.contains(self) {
                            return
                        } else {
                            targetTag.addGiukToIndex(giuk: self)
                            targetTag.addToGiuks(self)
                        }
                    } else {
                        print("fetchTag - Tag.giuks empty! something wrong")
                        return
                    }
                } else {
                    let newTag = Tag(context: context)
                    newTag.tagName = tag
                    newTag.createdDate = self.createdDate
                    newTag.addGiukToIndex(giuk: self)
                    self.addToTags(newTag)
                }
            } catch {
                throw savingError.fetchingFailed
            }
        }
        
        if tagInformation.needsToBeDeleted.count > 0 {
            for tagItem in tagInformation.needsToBeDeleted {
                print("deleting tag recommanded : \(tagItem)")
                Tag.deleteOrRemoveFromGiuk(context, tag: tagItem, giukData: self)
            }
        }
        
        if tagInformation.needsToBeSaved.count > 0 {
            for tagItem in tagInformation.needsToBeSaved {
                print("saving tag recommanded : \(tagItem)")
                do { try fetchTag(tagItem) } catch let error { throw error }
            }
        } else {
            throw savingError.savingFailed
        }
        
        if self.tags?.count == 0 {
            print("preventing empty giuk -- giuk delete")
            context.delete(self)
        }
        // print("save after : \((self.tags?.allObjects as? [Tag])!.map{ $0.tagName })")
    }
    
    private func insertCreatedData(_ createdData: CreatedData, context: NSManagedObjectContext, isFirstWroted: Bool) {
        self.createOrSetNewThumbnailToGiuk(context: context, thumbData: createdData.thumbnailData)
        self.createOrSetNewImageToGiuk(context: context, imageData: createdData.croppedData)
        self.createOrSetNewTextToGiuk(context: context, textData: createdData.textData)
        self.createNewIdentifireAndCreatedDateToGiuk(identifire: createdData.identifire, createdDate: createdData.createdDate)
        do {
            try self.saveOrCreateTagsToGiuk(context: context, tagInformation: createdData.tagData)
        } catch let error {
            if let err = error as? savingError {
                if err == .savingFailed {
                    print("there is no changes for tags")
                } else if err == .fetchingFailed {
                    print("fectching Failed!")
                }
            }
            if isFirstWroted {
                return
            }
        }
    }
    
    static func createOrEditGiuk(_ context: NSManagedObjectContext, giuk: Giuk?, createdData: CreatedData, isFirstWroted: Bool, completion: (()->Void)? = nil) {
        if let targetGiuk = giuk {
            targetGiuk.insertCreatedData(createdData, context: context, isFirstWroted: isFirstWroted)
        } else {
            let newGiuk = Giuk(context: context)
            newGiuk.insertCreatedData(createdData, context: context, isFirstWroted: isFirstWroted)
        }
        print("saving context")
        try? context.save()
        print("saving finished. completion called")
        completion?()
    }
    
    enum savingError: Error {
        case savingFailed
        case fetchingFailed
    }
    
    func createWrotedDataFromGiuk(_ libraryOfTags: [String]) -> CreatedData? {
        guard let identifire = self.identifire, let createdDate = self.createdDate, let _imageData = self.image?.imageData,
            let _thumbData = self.thumbnail?.thumbnailImageData ,let _textData = self.text?.textData, let tags = self.tags?.allObjects as? [Tag] else { return nil }
       // print("\(tags.map{$0.tagName})")
        let sortedTags = (tags.sorted { $0.createdDate! > $1.createdDate! })
        var tagNames = [String]()
        for tag in sortedTags {
            tagNames.append(tag.tagName!)
        }
        
        let thumbData = ThumbnailInformation(json: _thumbData)
        let tagData = TagInformation(alreadyAdded: tagNames, library: libraryOfTags)
        let imageData = CroppedImageInformation(json: _imageData)
        let textData = TextInformation(json: _textData)
        
        let data = CreatedData(thumbnailData: thumbData!, croppedData: imageData!, textData: textData!, tagData: tagData, identifire: identifire, createdDate: createdDate)
        return data
    }

}
