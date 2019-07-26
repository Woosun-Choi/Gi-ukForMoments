//
//  Tag.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class Tag: NSManagedObject {
    
    func requestGiuks() -> [Giuk]? {
        if let giuks = self.giuks?.allObjects as? [Giuk] {
            guard let indexData = self.giukIndex else {
                assert(true, "indexData missing")
                return nil
            }
            guard let indexes = GiukIndex.init(json: indexData)?.indexOfGiuks else {
                assert(true, "bring index from indexData failed")
                return nil
            }
            let result = arrayAcendingWithOtherArray(array: giuks, compareArray: indexes, compareKeyPath: "identifire") as? [Giuk]
            //giuks.sorted{ indexes.firstIndex(of: $0.identifire!)! < indexes.firstIndex(of: $1.identifire!)! }
            return result
        } else {
            return nil
        }
    }
    
    func absd(_ target: [NSObject], ketPath: String) -> [Any] {
        var result = [Any]()
        for item in target {
            if let singleValue = item.value(forKey: ketPath) {
                result.append(singleValue)
            }
        }
        return result
    }
    
    func addGiukToIndex(giuk: Giuk) {
        if let identifire = giuk.identifire {
            if let indexData = self.giukIndex {
                var item = GiukIndex(json: indexData)
                item?.addNewIndex(identifire: identifire)
                self.giukIndex = item?.json
            } else {
                self.giukIndex = GiukIndex(indexes: [identifire]).json
            }
        } else {
            assert(true, "identifire is missing -- check structure")
        }
    }
    
    func replaceGiukIndexInTo(replacingGiuk: Giuk, fromIndex: Int, toIndex: Int) {
        guard let identifire = replacingGiuk.identifire else { return }
        if let indexData = self.giukIndex {
            var item = GiukIndex(json: indexData)
            if item?.indexOfGiuks.contains(identifire) ?? false {
                item?.replaceGiukIndex(from: fromIndex, to: toIndex)
                self.giukIndex = item?.json
            }
        }
    }
    
    func removeGiukFromIndex(giuk: Giuk) {
        if let indexData = self.giukIndex, let identifire = giuk.identifire {
            var item = GiukIndex(json: indexData)
            item?.removeFromIndex(identifire: identifire)
            self.giukIndex = item?.json
        }
    }
    
    func removeGiukFromTag(context: NSManagedObjectContext, giuk: Giuk) {
        self.removeGiukFromIndex(giuk: giuk)
        self.removeFromGiuks(giuk)
        if giuk.tags?.count == 0 {
            context.delete(giuk)
        }
        if self.giuks?.count == 0 {
            context.delete(self)
        }
        try? context.save()
    }
    
    func delete(context: NSManagedObjectContext, completion: (()->Void)? = nil) {
        if let containedGiuk = self.giuks?.allObjects as? [Giuk] {
            for giuk in containedGiuk {
                if giuk.tags?.count == 1 {
                    context.delete(giuk)
                    print("giuk and tag deleted")
                } else {
                    giuk.removeFromTags(self)
                    print("tag deleted alone")
                }
            }
            context.delete(self)
        } else if self.giuks?.count == 0{
            context.delete(self)
        }
        
        try? context.save()
        completion?()
    }
    
    static func findTagFromTagName(context: NSManagedObjectContext, tagName: String) -> Tag? {
        let request : NSFetchRequest<Tag> = Tag.fetchRequest()
        let predicate = NSPredicate(format: "tagName == %@", tagName)
        request.predicate = predicate
        do {
            if let result = try context.fetch(request).first {
                return result
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    static func findGiukFromTagName(context: NSManagedObjectContext, tagName: String) -> Giuk? {
        let request : NSFetchRequest<Tag> = Tag.fetchRequest()
        let predicate = NSPredicate(format: "tagName == %@", tagName)
        request.predicate = predicate
        do {
            if let result = try context.fetch(request).first {
                if let _giuks = result.giuks?.allObjects as? [Giuk] {
                    guard let indexData = result.giukIndex else {
                        assert(true, "indexData missing")
                        return nil}
                    guard let indexes = GiukIndex.init(json: indexData)?.indexOfGiuks else {
                        assert(true, "bring index from indexData failed")
                        return nil
                    }
                    let sorted = _giuks.sorted{ indexes.firstIndex(of: $0.identifire!)! < indexes.firstIndex(of: $1.identifire!)! }
                    return sorted.first
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    static func requestGiuksFromTagName(context: NSManagedObjectContext, tagName: String) -> [Giuk]? {
        let request : NSFetchRequest<Tag> = Tag.fetchRequest()
        let predicate = NSPredicate(format: "tagName == %@", tagName)
        request.predicate = predicate
        do {
            if let result = try context.fetch(request).first {
                if let giuks = result.giuks?.allObjects as? [Giuk] {
                    guard let indexData = result.giukIndex else {
                        assert(true, "indexData missing")
                        return nil}
                    guard let indexes = GiukIndex.init(json: indexData)?.indexOfGiuks else {
                        assert(true, "bring index from indexData failed")
                        return nil
                    }
                    return giuks.sorted{ indexes.firstIndex(of: $0.identifire!)! < indexes.firstIndex(of: $1.identifire!)! }
                } else {
                    return nil
                }
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    static func findAllTags(context: NSManagedObjectContext) -> [String]? {
        let request : NSFetchRequest<Tag> = Tag.fetchRequest()
        do {
            var result = try context.fetch(request)
            if result.count > 0 {
                result.sort{ $0.createdDate! > $1.createdDate!}
                var tags = [String]()
                for tag in result {
                    tags.append(tag.tagName!)
                }
                return tags
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    static func deleteOrRemoveFromGiuk(_ context: NSManagedObjectContext ,tag: String, giukData giuk: Giuk) {
        let request : NSFetchRequest<Tag> = Tag.fetchRequest()
        let predicate = NSPredicate(format: "tagName == %@", tag)
        request.predicate = predicate
        do {
            if let target = try context.fetch(request).first {
                if let giuks = target.giuks {
                    if (giuks.count) > 1 {
                        print("tag deleting count > 1")
                        giuk.removeFromTags(target)
                        target.removeGiukFromIndex(giuk: giuk)
                        try context.save()
                    } else if (giuks.count) == 1 {
                        print("tag deleting count = 1")
                        target.removeFromGiuks(giuk)
                        context.delete(target)
                    }
                } else {
                    return
                }
            }
        } catch { return }
    }
    
}
