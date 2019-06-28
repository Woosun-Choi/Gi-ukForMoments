//
//  Giuk_ContentView_Writing.swift
//  Gi-ukForMoments
//
//  Created by goya on 24/06/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

@objc protocol GiukContentView_WritingDatasource {
    @objc func writeSectionView_OwnerView(_ writingView: Giuk_ContentView_Writing) -> UIView?
    @objc func writeSectionView_ViewCoordinatesInOwnerView(_ writingView: Giuk_ContentView_Writing) -> CGRect
    @objc func writeSectionView(_ writingView: Giuk_ContentView_Writing, numberOfImagesInSection section: Int) -> Int
    @objc func writeSectionView(_ writingView: Giuk_ContentView_Writing, thumbnailImageForItemAt indexPath: IndexPath) -> UIImage?
    @objc func writeSectionView(_ writingView: Giuk_ContentView_Writing, didSelectImageDataAt indexPath: IndexPath) -> Data?
    @objc func writeSectionView_ShouldPerformActionAfter(_ writingView: Giuk_ContentView_Writing) -> (()->Void)?
}

class Giuk_ContentView_Writing: NonAutomaticScrollView, ImageSelectAndCropViewDataSource, Giuk_ContentView_WritingTextViewDelegate, TagGeneratorDelegate {
    
    weak var dataSource: GiukContentView_WritingDatasource?
    
    enum WritingState {
        case choosingPhoto
        case writingComment
        case choosingTag
    }
    
    var writingState: WritingState = .choosingPhoto {
        didSet {
            checkWritingState()
            layoutSubviews()
        }
    }
    
    weak var photoControlView: Giuk_ContentView_SubView_ImageSelectAndCropView!
    
    weak var textControlView: Giuk_ContentView_WritingTextView!
    
    weak var tagControllView: TagGenerator!
    
    var limitNumberOfCharactorsForTextView: Int = 500 {
        didSet {
            textControlView.limitNumberOfCharactors = self.limitNumberOfCharactorsForTextView
        }
    }
    
    var wrotedData: (cropData: CroppedImageData, textData: TextInformation, hashData: TagInformation)? {
        let cropData = photoControlView.croppedImageData!
        let textData = textControlView.textData
        let hashData = TagInformation()
        return (cropData, textData, hashData)
    }
    
    
    //MARK: set views
    private func setOrRepostionPhotoControlView() {
        if photoControlView == nil {
            let newView = generateUIView(view: photoControlView, origin: CGPoint.zero, size: bounds.size)
            photoControlView = newView
            photoControlView.dataSource = self
            addSubview(photoControlView)
        } else {
            photoControlView.setNewFrame(bounds)
        }
    }
    
    private func setOrRepositionTextControlView() {
        let targetFrame = convert(photoControlView.estimateAreaForWriting, from: photoControlView)
        if textControlView == nil {
            let newView = generateUIView(view: textControlView, frame: targetFrame)
            textControlView = newView
            textControlView.alpha = 0
            textControlView.isUserInteractionEnabled = false
            textControlView.delegate = self
            textControlView.limitNumberOfCharactors = limitNumberOfCharactorsForTextView
            addSubview(textControlView)
        } else {
            textControlView.setNewFrame(targetFrame)
        }
    }
    
    private func setOrRepositionHashTagScrollView() {
        let width = bounds.width
        let height = bounds.height
        let size = CGSize(width: width, height: height)
        let origin = CGPoint(x: photoControlView.frame.maxX, y: 0)
        let newFrame = CGRect(origin: origin, size: size)
        
        if tagControllView == nil {
            let newView = generateUIView(view: tagControllView, frame: newFrame)
            tagControllView = newView
            tagControllView.delegate = self
            addSubview(tagControllView)
        } else {
            tagControllView.setNewFrame(newFrame)
        }
    }
    //end
    
    
    //MARK: functions for control views
    func checkWritingState() {
        switch writingState {
        case .choosingPhoto:
            scrollAvailable = false
            photoControlView.imageCropView.mode = .cropable
            textControlView?.isUserInteractionEnabled = false
            UIView.animate(withDuration: 0.25) {
                self.textControlView.alpha = 0
            }
        case .writingComment:
            scrollAvailable = true
            photoControlView.imageCropView.mode = .presentOnly
            textControlView?.isUserInteractionEnabled = true
            UIView.animate(withDuration: 0.25) {
                self.textControlView.alpha = 1
            }
            if contentOffSet.x != 0 {
                let position = CGPoint.zero
                scrollToPosition(position, duration: 0.5)
            }
        case .choosingTag:
            textControlView?.isUserInteractionEnabled = false
            scrollAvailable = false
            let position = contentOffSet.offSetBy(dX: -tagControllView.frame.width, dY: 0)
            scrollToPosition(position, duration: 0.5)
        }
    }
    
    func setImageCropViewOrientationTo(isHorizontal: Bool) {
        if photoControlView.isHorizontal != isHorizontal {
            photoControlView.imageCropView.cropInformation = nil
            photoControlView.isHorizontal = isHorizontal
        }
    }
    
    
    
    
    
    
    
    //MARK: ImageCropView Datasources
    func imageSelectAndCropView(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.writeSectionView(self, numberOfImagesInSection: section) ?? 0
    }

    func imageSelectAndCropView(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, imageForItemAt indexPath: IndexPath) -> UIImage? {
        return dataSource?.writeSectionView(self, thumbnailImageForItemAt: indexPath)
    }

    func imageSelectAndCropView(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, didSelectImageDataAt indexPath: IndexPath) -> Data? {
        return dataSource?.writeSectionView(self, didSelectImageDataAt: indexPath)
    }

    func imageSelectAndCropView_ShouldPerformActionAfter(_ imageSelectAndCropView: Giuk_ContentView_SubView_ImageSelectAndCropView, didSelectImageDataAt indexPath: IndexPath) -> (() -> Void)? {
        return dataSource?.writeSectionView_ShouldPerformActionAfter(self)
    }
    //end
    
    //MARK: textView control while user in typing
    func writingTextView(_ writingView: Giuk_ContentView_WritingTextView, didChangeSelectionAt rect: CGRect, keyBoardHeight: CGFloat) {
        
        guard let ownerView = dataSource?.writeSectionView_OwnerView(self) else {return}
        guard let subViewFrameInfo = dataSource?.writeSectionView_ViewCoordinatesInOwnerView(self) else {return}
        let fullframeInfo = ownerView.frame
        
        let leftHeight = fullframeInfo.height - keyBoardHeight
        let leftAreaHeight = subViewFrameInfo.maxY - leftHeight
        
        var textShouldBeIn: CGRect {
            let originX: CGFloat = 5
            let originY: CGFloat = 5
            let maxheight = bounds.height - leftAreaHeight - 10
            let maxWidth = bounds.width - 10
            return CGRect(x: originX, y: originY, width: maxWidth, height: maxheight)
        }
        
        let point = convert(rect, from: writingView)
        let currentOriginOfContentContainer = contentOffSet
        if point.maxY > textShouldBeIn.maxY && (contentOffSet.y > -(leftAreaHeight + 10)) {
            scrollToPosition(currentOriginOfContentContainer.offSetBy(dX: 0, dY: (textShouldBeIn.maxY - point.maxY)), animated: false)
            maximumScrollAvailableAmountToBottom = contentOffSet.y
        } else if point.minY < textShouldBeIn.minY && (contentOffSet.y < 0) {
            let targetPoint = currentOriginOfContentContainer.offSetBy(dX: 0, dY: (textShouldBeIn.minY - point.minY))
            if targetPoint.y < (writingView.textView.font?.pointSize ?? 0) {
                scrollToPosition(CGPoint.zero, animated: false)
            } else {
                scrollToPosition(targetPoint, animated: false)
            }
        }
    }
    
    func writingTextView(_ writingView: Giuk_ContentView_WritingTextView, didEndEditing: Bool) {
        if didEndEditing {
            resetScollControlState()
            scrollToPosition(CGPoint.zero, animated: true)
        }
    }
    //end
    
    
    //MARK: init and update view layout
    
    private func setAllSubViews() {
        setOrRepostionPhotoControlView()
        setOrRepositionTextControlView()
        setOrRepositionHashTagScrollView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setAllSubViews()
    }
    
    override func draw(_ rect: CGRect) {
        setAllSubViews()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setAllSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setAllSubViews()
    }
    //end

}
