//
//  GiukIndex.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation

struct GiukIndex: Codable {
    
    var indexOfGiuks: [String]
    
    mutating func addNewIndex(identifire: String) {
        if indexOfGiuks.firstIndex(of: identifire) == nil {
            indexOfGiuks.insert(identifire, at: 0)
        }
    }
    
    mutating func removeFromIndex(identifire: String) {
        if let itemIndex = indexOfGiuks.firstIndex(of: identifire) {
            indexOfGiuks.remove(at: itemIndex)
        }
    }
    
    mutating func renewIndexAs(indexes: [String]) {
        indexOfGiuks = indexes
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let jsonData = try? JSONDecoder().decode(GiukIndex.self, from: json) {
            self = jsonData
        } else {
            return nil
        }
    }
    
    init(indexes: [String]) {
        self.indexOfGiuks = indexes
    }
}
