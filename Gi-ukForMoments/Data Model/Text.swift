//
//  Text.swift
//  Gi-ukForMoments
//
//  Created by goya on 15/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit
import CoreData

class Text: NSManagedObject {
    
    static func createNewText(context: NSManagedObjectContext, textData: TextInformation) -> Text {
        let newText = Text(context: context)
        let newTextData = textData.json
        newText.textData = newTextData
        return newText
    }
}
