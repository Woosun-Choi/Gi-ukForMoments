//
//  TagInformation.swift
//  Gi-ukForMoments
//
//  Created by goya on 28/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import Foundation

struct TagInformation: Codable {
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data) {
        if let newValue = try? JSONDecoder().decode(TagInformation.self, from: json) {
            self = newValue
        } else {
            return nil
        }
    }
    
    private(set) var alreadyAdded = [String]()
    var addedTags = [String]() { didSet {updateNeedToBeManagedTags()}}
    private(set) var library = [String]()
    
    private(set) var needsToBeDeleted = [String]()
    private(set) var needsToBeSaved = [String]()
    
    mutating func addTags(tag: String) {
        if addedTags.firstIndex(of: tag) == nil {
            addedTags.append(tag)
        }
    }
    
    mutating func removeTags(tag: String) {
        if let index = addedTags.firstIndex(of: tag) {
            addedTags.remove(at: index)
        }
    }
    
    mutating func updateNeedToBeManagedTags() {
        needsToBeSaved = addedTags.filter{ alreadyAdded.firstIndex(of: $0) == nil }
        needsToBeDeleted = alreadyAdded.filter { addedTags.firstIndex(of: $0) == nil }
    }
    
    init(alreadyAdded: [String] = [String](), library: [String] = [String]()) {
        self.alreadyAdded = alreadyAdded
        self.addedTags = alreadyAdded
        self.library = library
    }
    
    mutating func clearSavingData() {
        needsToBeSaved = [String]()
        needsToBeDeleted = [String]()
    }
}
