//
//  ThumbnailInformation.swift
//  Gi-ukForMoments
//
//  Created by goya on 13/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation

struct ThumbnailInformation: Codable {
    var thumbnailImageData: Data?
    
    var json : Data? {
        if let jsonData = try? JSONEncoder().encode(self) {
            return jsonData
        } else {
            return nil
        }
    }
    
    init?(json: Data) {
        if let decodedData = try? JSONDecoder().decode(ThumbnailInformation.self, from: json) {
            self = decodedData
        } else {
            return nil
        }
    }
    
    init(thumbnailData: Data) {
        thumbnailImageData = thumbnailData
    }
}
