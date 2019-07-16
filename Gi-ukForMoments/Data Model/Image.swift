//
//  Image.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class Image: NSManagedObject {
    
    static func createNewImage(context: NSManagedObjectContext, imageData: CroppedImageInformation) -> Image {
        let newImage = Image(context: context)
        let newImageData = imageData.json
        newImage.imageData = newImageData
        return newImage
    }
}
