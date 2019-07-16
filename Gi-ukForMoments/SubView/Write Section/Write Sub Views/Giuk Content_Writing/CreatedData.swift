//
//  CreatedData.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation

class CreatedData: NSObject {
    var identifire: String
    var createdDate: Date
    var croppedData: CroppedImageInformation
    var textData: TextInformation
    var tagData: TagInformation
    var thumbnailData: ThumbnailInformation
    
    init(thumbnailData: ThumbnailInformation ,croppedData: CroppedImageInformation, textData: TextInformation, tagData: TagInformation, identifire: String? = nil, createdDate: Date = Date()) {
        self.thumbnailData = thumbnailData
        self.croppedData = croppedData
        self.textData = textData
        self.tagData = tagData
        self.createdDate = createdDate
        if identifire == nil {
            let createdDateString = self.createdDate.requestStringFromDate(data: .year)! + self.createdDate.monthString + self.createdDate.requestStringFromDate(data: .day)!
            self.identifire = randomHashCreate(length: 12) + "_" + createdDateString
        } else {
            self.identifire = identifire!
        }
    }
}
