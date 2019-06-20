//
//  ImageCropInformation.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation

struct CropInformation: Codable {
    
    var isHorizontal: Bool
    
    struct percentageSizeInImage: Codable {
        var width: Double
        var height: Double
    }
    
    struct percentagePostionInImage: Codable {
        var dX: Double
        var dY: Double
    }
    
    var percentageSize: percentageSizeInImage
    var percentagePosition: percentagePostionInImage
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(CropInformation.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    init(isHorizontal: Bool, percentageSizeOfWillCroppedArea: percentageSizeInImage, percentagePostionInScrollView: percentagePostionInImage) {
        self.isHorizontal = isHorizontal
        self.percentageSize = percentageSizeOfWillCroppedArea
        self.percentagePosition = percentagePostionInScrollView
    }
}
