//
//  CroppedImageData.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation

struct CroppedImageData: Codable {
    
    var cropInformation: CropInformation
    var imageData: Data
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(CroppedImageData.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    init(cropInformation: CropInformation, imageData: Data) {
        self.cropInformation = cropInformation
        self.imageData = imageData
    }
}
