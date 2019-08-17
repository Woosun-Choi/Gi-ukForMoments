//
//  PrimarySettings.swift
//  Gi-ukForMoments
//
//  Created by goya on 12/08/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class PrimarySettings: NSManagedObject {
    
    static func checkAndCreateSettings(context: NSManagedObjectContext) {
        let request : NSFetchRequest<PrimarySettings> = PrimarySettings.fetchRequest()
        do {
            if let counting = try? context.count(for: request) {
                if counting == 1 {
                    
                } else if counting == 0 {
                    let newSetting = PrimarySettings(context: context)
                    newSetting.filterName = "CIPhotoEffectTonal"
                    newSetting.userID = "notAuthorized"
                    print("new setting")
                    try! context.save()
                } else {
                    assert(true, "memory consistency breaked!")
                }
            }
        }
    }
    
    static func callSettings(context: NSManagedObjectContext) -> PrimarySettings? {
        let request : NSFetchRequest<PrimarySettings> = PrimarySettings.fetchRequest()
        do {
            if let counting = try? context.count(for: request) {
                if counting == 1 {
                    return try? context.fetch(request).first
                } else if counting == 0 {
                    let newSetting = PrimarySettings(context: context)
                    newSetting.filterName = "CIPhotoEffectTonal"
                    newSetting.userID = "notAuthorized"
                    print("new setting")
                    try! context.save()
                    return newSetting
                } else {
                    assert(true, "memory consistency breaked!")
                    return nil
                }
            } else {
                return nil
            }
        }
    }
}
