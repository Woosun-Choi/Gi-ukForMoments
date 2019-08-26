//
//  ThumbnailImage.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class ThumbnailImage: NSManagedObject {
    
    func thumbnailInformation() -> ThumbnailInformation? {
        if let data = self.thumbnailImageData {
            return ThumbnailInformation.init(thumbnailData: data)
        } else {
            return nil
        }
    }
    
    static func createNewThumbnail(context: NSManagedObjectContext, thumbnailData: ThumbnailInformation) -> ThumbnailImage {
        let newThumbnail = ThumbnailImage(context: context)
        let newThumbnailData = thumbnailData.json
        newThumbnail.thumbnailImageData = newThumbnailData
        return newThumbnail
    }
}
