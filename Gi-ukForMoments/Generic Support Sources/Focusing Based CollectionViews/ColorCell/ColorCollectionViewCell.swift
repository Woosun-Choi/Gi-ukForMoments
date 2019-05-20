//
//  ColorCollectionViewCell.swift
//  CenteredCollectionViewTest
//
//  Created by goya on 24/03/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = String(describing: ColorCollectionViewCell.self)
    
    var color: UIColor?
    
    var date: Date? {
        didSet {
            if let day = date?.day {
                numberView.dayNumber = day
            }
        }
    }

    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var numberView: AnalogNumberView!
    
    override func prepareForReuse() {
        colorView.backgroundColor = .clear
        numberView.dayNumber = 0
        date = nil
    }
    
    func setColor() {
        if let color = self.color {
            colorView.backgroundColor = color
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
