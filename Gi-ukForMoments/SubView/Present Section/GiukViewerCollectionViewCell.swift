//
//  GiukViewerCollectionViewCell.swift
//  Gi-ukForMoments
//
//  Created by goya on 16/07/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

class GiukViewerCollectionViewCell: UICollectionViewCell {
    
    static var identifier: String = String(describing: GiukViewerCollectionViewCell.self)
    
    var giuk: Giuk? {
        didSet {
            if let data = self.giuk?.createWrotedDataFromGiuk([]) {
                viewer?.imageData = data.croppedData
                viewer?.textData = data.textData
            }
        }
    }
    
    weak var viewer: PresentGiukView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setViewer()
    }
    
    func setViewer() {
        if viewer == nil {
            let newViewer = generateUIView(view: viewer, frame: bounds)
            viewer = newViewer
            addSubview(viewer)
        } else {
            viewer?.setNewFrame(bounds)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setViewer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setViewer()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewer.imageData = nil
        viewer.textData = nil
        giuk = nil
    }
    
}
