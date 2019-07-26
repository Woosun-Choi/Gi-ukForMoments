//
//  ImageCroppingView.swift
//  ImageCroptest_Version2
//
//  Created by goya on 14/01/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

/*
 What this view does.
 present image and crop it
 - take an image as a data
 - return image data and cropinformation or cropped image
 
 view construct
 - scroll view
 - image view
 - croparea view
 
 required functions
 #1. is image data and cropinformation exist? -> y : c1, n : c2
 
 c1
 - set image to imageView
 - zoom to rect with cropinformation
 
 c2
 - take an image data and set image to imageView
 - initail setting to imageview and prepare for cropping
 -> perform crop
 
 */

struct ImageCropViewDescription {
    static private let language = Locale.current.languageCode
    static var notice_Title: String {
        switch language {
        case "kor": return "사진을 선택하세요"
        default : return "choose a moment"
        }
    }
    static var notice_SubTiltle: String {
        switch language {
        case "kor": return "\n사진을 확대하거나 축소하며\n위치를 조정하세요"
        default : return "\nzooming and scrolling\nto crop the photo"//"\nand reposition the photo\nwith zooming in or out"
        }
    }
}

@objc protocol ImageCroppingViewDelegate {
    @objc optional func imageCroppingView(_ croppingView: ImageCroppingView, newDataImageSetted settedData: Data?)
    @objc optional func imageCroppingView(_ croppingView: ImageCroppingView, needRepresentedImageData imageData: Data) -> UIImage?
}

class ImageCroppingView: UIView, UIScrollViewDelegate {
    
    //MARK: subViews
    weak var imageScrollView: UIScrollView!
    
    weak var croppingView: CroppingArea!
    
    weak var imageView: UIImageView!
    
    weak var noticeLabel: UILabel!
    
    weak var spinner: UIActivityIndicatorView!
    //end
    
    //MARK: variables
    weak var delegate: ImageCroppingViewDelegate?
    
    enum CroppingViewMode {
        case presentOnly
        case cropable
    }
    
    var mode: CroppingViewMode = .cropable {
        didSet {
            checkMode()
        }
    }
    
    var thumbnailData: ThumbnailInformation? {
        if let thumbData = requestThumbnailDataInEstimateCropArea() {
            return ThumbnailInformation(thumbnailData: thumbData)
        } else {
            return nil
        }
    }
    
    var croppedImageData: CroppedImageInformation? {
        get {
            return requestCroppedImageData()
        } set {
            image = newValue?.imageData
            cropInformation = newValue?.cropInformation
            refreshImage(cropInformation)
        }
    }
    
    var cropInformation: CropInformation?
    
    var requiredActionAfterCroppingFinished: ((UIImage) -> Void)?
    
    var requiredCroppingAreaFrameInCroppingView: CGRect?
    
    var image: Data? {
        get {
            return _image
        } set {
            cropInformation = nil
            _image = newValue
        }
    }
    
    private var _image: Data? {
        didSet {
            setNewImage()
            delegate?.imageCroppingView?(self, newDataImageSetted: self.image)
        }
    }
    
    var willCropAreaRect: CGRect {
        return requiredCroppingAreaFrameInCroppingView ?? (croppingView?.bounds ?? CGRect.zero)
    }
    //end
    
    //MARK: Computed Variables for cropping
    //MARK: trouble?
    private var estimateCropArea: CGRect {
        var factor : CGFloat = 0
        if imageStatus.ratio > croppingViewStatus.ratio {
            factor = imageView.image!.size.height/croppingViewStatus.size.height
        } else {
            factor = imageView.image!.size.width/croppingViewStatus.size.width
        }
        let scale = 1/imageScrollView.zoomScale
        let x = imageScrollView.contentOffset.x * scale * factor
        let y = imageScrollView.contentOffset.y * scale * factor
        let width = croppingViewStatus.size.width * scale * factor
        let height = croppingViewStatus.size.height * scale * factor
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    private func estimateCropAreaWithCropInformation(_ information: CropInformation) -> CGRect? {
        guard let image = imageView.image else {return nil}
        let originX = image.size.width * CGFloat(information.percentagePosition.dX)
        let originY = image.size.height * CGFloat(information.percentagePosition.dY)
        let origin = CGPoint(x: originX, y: originY)
        let width = image.size.width * CGFloat(information.percentageSize.width)
        let height = image.size.height * CGFloat(information.percentageSize.height)
        let size = CGSize(width: width, height: height)
        return CGRect(origin: origin, size: size)
    }
    
    private var imageStatus : (size: CGSize, ratio: CGFloat) {
        let imageSize = imageView?.imageFrame.size ?? CGSize.zero
        let imageRatio = (imageSize.width/imageSize.height).preventNaN
        return (size: imageSize, ratio: imageRatio)
    }
    
    private var croppingViewStatus: (size: CGSize, ratio: CGFloat) {
        let size = willCropAreaRect.size
        let ratio = (willCropAreaRect.width/willCropAreaRect.height).preventNaN
        return (size: size, ratio: ratio)
    }
    //end
    
    //MARK: Set and Layout subviews
    private func setOrRePositioning_ImageScrollView() {
        if imageScrollView == nil {
            let newView = generateUIView(view: imageScrollView, frame: fullFrame)
            newView?.minimumZoomScale = 1
            newView?.maximumZoomScale = 3
            newView?.showsVerticalScrollIndicator = false
            newView?.showsHorizontalScrollIndicator = false
            newView?.backgroundColor = UIColor.clear
            imageScrollView = newView
            addSubview(imageScrollView)
        } else {
            imageScrollView.setNewFrame(fullFrame)
            imageScrollView.zoomScale = 1
        }
    }
    
    private func setOrRepositioning_imageView() {
        if imageView == nil {
            let newView = generateUIView(view: imageView, frame: imageScrollView?.bounds ?? CGRect.zero)
            newView?.backgroundColor = .clear
            newView?.contentMode = .scaleAspectFit
            imageView = newView
            imageScrollView.addSubview(imageView)
        } else {
            if image == nil {
                imageView.setNewFrame(imageScrollView?.bounds ?? CGRect.zero)
            } else {
                reSizeImageView()
                updateContentSize(true)
            }
        }
    }
    
    private func setOrRePositioning_CroppingView() {
        if croppingView == nil {
            let view = generateUIView(view: croppingView, frame: fullFrame)
            view?.backgroundColor = UIColor.clear
            view?.isOpaque = false
            croppingView = view
            croppingView.recommendedCropAreaRect = willCropAreaRect
            addSubview(croppingView)
        } else {
            croppingView.setNewFrame(fullFrame)
            croppingView.recommendedCropAreaRect = willCropAreaRect
            
        }
    }
    
    private func setOrRePositioning_NoticeLabel() {
        let fontSize = valueBetweenMinAndMax(maxValue: DescribingSources.sectionsFontSize.maxFontSize.cgFloat, minValue: DescribingSources.sectionsFontSize.minFontSize.cgFloat, mutableValue: (frame.height * 0.0618))
        
        let attributedText = String.generatePlaceHolderMutableAttributedString(fontSize: fontSize, titleText: ImageCropViewDescription.notice_Title, subTitleText: ImageCropViewDescription.notice_SubTiltle)
        
        if mode == .cropable {
            if noticeLabel == nil {
                let label = generateUIView(view: noticeLabel, frame: bounds)
                noticeLabel = label
                let fontSize = max(fullFrame.height * 0.05, 14)
                noticeLabel.setLabelAsSDStyleWithSpecificFontSize(type: .medium, fontSize: fontSize)
                noticeLabel.textColor = .GiukBackgroundColor_depth_1
                noticeLabel.textAlignment = .center
                noticeLabel.numberOfLines = 0
                noticeLabel.attributedText = attributedText
                addSubview(noticeLabel)
            } else {
                noticeLabel.setNewFrame(bounds)
                noticeLabel.attributedText = attributedText
            }
        }
    }
    
    private func setSpinner() {
        if spinner == nil {
            let newView = generateUIView(view: spinner, frame: bounds)
            newView?.stopAnimating()
            newView?.isHidden = true
            newView?.style = .whiteLarge
            newView?.color = .goyaBlack
            newView?.backgroundColor = UIColor.goyaWhite.withAlphaComponent(0.3)
            spinner = newView
            addSubview(spinner)
        } else {
            spinner.setNewFrame(bounds)
        }
    }
    
    private func checkMode() {
        switch mode {
        case .cropable:
            imageScrollView?.isUserInteractionEnabled = true
        case .presentOnly:
            imageScrollView?.isUserInteractionEnabled = false
        }
    }
    
    private func configureSubviews() {
        setOrRePositioning_ImageScrollView()
        setOrRePositioning_CroppingView()
        setOrRepositioning_imageView()
        setOrRePositioning_NoticeLabel()
        setSpinner()
        checkMode()
    }
    //end
    
    
    //MARK: View Manipulate With CropData and ImageData
    private func checkImageAndUpdateViewsState() {
        if image == nil {
            croppingView?.isHidden = true
            noticeLabel?.isHidden = false
            imageScrollView.backgroundColor = .clear
        } else {
            croppingView?.isHidden = false
            noticeLabel?.isHidden = true
            imageScrollView.backgroundColor = .clear
        }
    }
    
    private func setImageToImageView(_ image: UIImage?) {
        if let settedImage = image {
            imageView.image = settedImage
            resetZoomingState(imageBeingCentered: true)
        } else {
            imageView.image = nil
            imageScrollView.zoomScale = 1
        }
        checkImageAndUpdateViewsState()
    }
    
    private func setNewImage() {
        if let imageData = self.image {
            if let image = delegate?.imageCroppingView?(self, needRepresentedImageData: imageData) {
                setImageToImageView(image)
            } else {
                if let presentImage = UIImage(data: imageData)?.fixOrientation() {
//                    if let module = filterModule, let filter = filterEffect {
//                        let targetImage = module.performImageFilter(filter, image: presentImage)
//                        setImageToImageView(targetImage)
//                    } else {
                        setImageToImageView(presentImage)
//                    }
                }
            }
        } else {
            setImageToImageView(nil)
        }
    }
    
    func refreshImage(_ cropInfo: CropInformation?) {
        if image != nil {
            if let info = cropInfo {
                zoomWithCropInformationData(info)
            } else {
                resetZoomingState(imageBeingCentered: true)
            }
        }
    }
    
    private func resetZoomingState(imageBeingCentered: Bool) {
        imageScrollView.zoomScale = 1
        reSizeImageView()
        updateContentSize(imageBeingCentered)
    }
    
    func resetCropInformation() {
        cropInformation = nil
        resetZoomingState(imageBeingCentered: true)
    }
    
    private func zoomWithCropInformationData(_ data: CropInformation?) {
        guard let scrollView = imageScrollView else{ return }
        guard let imgView = imageView else {return}
            let cropAreaWidthFactor = max(fullFrame.width - willCropAreaRect.width, 0)
            let cropAreaHeightFactor = max(fullFrame.height - willCropAreaRect.height, 0)
            if let coordinatedData = data {
                resetZoomingState(imageBeingCentered: false)
                let originX = (CGFloat(coordinatedData.percentagePosition.dX) * (imgView.frame.width)) - (cropAreaWidthFactor/2)
                let originY = (CGFloat(coordinatedData.percentagePosition.dY) * (imgView.frame.height)) - (cropAreaHeightFactor/2)
                let sizeWidth = (CGFloat(coordinatedData.percentageSize.width) * (imgView.frame.width)) + cropAreaWidthFactor
                let sizeHeight = (CGFloat(coordinatedData.percentageSize.height) * (imgView.frame.height)) + cropAreaHeightFactor
                let targetRect = CGRect(x: originX, y: originY, width: sizeWidth, height: sizeHeight)
                if sizeWidth.preventNaN.clearUnderDot == (scrollView.frame.width).clearUnderDot || sizeHeight.preventNaN.clearUnderDot == (scrollView.frame.height).clearUnderDot {
                    scrollView.scrollRectToVisible(targetRect, animated: false)
                } else {
                    scrollView.zoom(to: targetRect, animated: false)
                }
            } else {
                return
            }
    }
    //end
    
    //MARK: Functions for ImageView to prepare for cropping
    private func reSizeImageView() {
        if imageStatus.ratio > 1 {
            var estimatedHeight = willCropAreaRect.height
            var estimatedWidth : CGFloat {
                return estimatedHeight * imageStatus.ratio
            }
            
            while estimatedWidth < willCropAreaRect.width {
                estimatedHeight += 0.1
            }
            
            let width = max(estimatedWidth, 0)
            let height = max(estimatedHeight, 0)
            let newSize = CGSize(width: width, height: height)
            imageView?.frame.size = newSize
        } else {
            var estimatedWidth = willCropAreaRect.width
            var estimatedHeight : CGFloat {
                return estimatedWidth / imageStatus.ratio
            }
            
            while estimatedHeight < willCropAreaRect.height {
                estimatedWidth += 0.1
            }
            
            let width = max(estimatedWidth, 0)
            let height = max(estimatedHeight, 0)
            let newSize = CGSize(width: width, height: height)
            imageView?.frame.size = newSize
        }
    }
    
    private func updateContentSize(_ makeImageBeingCentered : Bool) {
        guard let scrollView = imageScrollView else { return }
        let imageSize = imageStatus.size
        let croppingAreaSize = croppingViewStatus.size
        
        let topEdgeMarginX = (scrollView.frame.width - croppingAreaSize.width)
        let topEdgeMarginY = (scrollView.frame.height - croppingAreaSize.height)
        
        let estimateWidth = max((imageSize.width + topEdgeMarginX), 0)
        let estimateHeight = max((imageSize.height + topEdgeMarginY), 0)
        
        scrollView.contentSize = CGSize(width: estimateWidth, height: estimateHeight)
        
        var newOffSetX : CGFloat = 0
        var newOffSetY : CGFloat = 0
        
        let expectedOffSetX = (estimateWidth - scrollView.frame.width)/2
        let expectedOffSetY = (estimateHeight - scrollView.frame.height)/2
        
        if imageStatus.ratio > 1.1 {
            (expectedOffSetX >= 0) ? (newOffSetX = expectedOffSetX) : (newOffSetX = topEdgeMarginX)
            (expectedOffSetY >= 0) ? (newOffSetY = expectedOffSetY) : (newOffSetY = 0)
        } else if imageStatus.ratio < 0.9 {
            (expectedOffSetX >= 0) ? (newOffSetX = expectedOffSetX) : (newOffSetX = 0)
            (expectedOffSetY >= 0) ? (newOffSetY = expectedOffSetY) : (newOffSetY = topEdgeMarginY)
        } else {
            (expectedOffSetX >= 0) ? (newOffSetX = expectedOffSetX) : (newOffSetX = 0)
            (expectedOffSetY >= 0) ? (newOffSetY = expectedOffSetY) : (newOffSetY = 0)
        }
        if makeImageBeingCentered {
            imageView.frame.origin = CGPoint(x: topEdgeMarginX/2, y: topEdgeMarginY/2)
            imageScrollView.setContentOffset(CGPoint(x: newOffSetX, y: newOffSetY), animated: false)
        }
    }
    //end
    
    //MARK: perform crop as uiimage result
    func performCrop() {
        guard let targetImage = imageView.image else { return }
        guard let croppedCGImage = targetImage.cgImage?.cropping(to: estimateCropArea) else { print("image setting error"); return }
        let croppedImage = UIImage(cgImage: croppedCGImage)
        requiredActionAfterCroppingFinished?(croppedImage)
    }
    
    func performCropWithCropInformation() {
        guard let targetImage = imageView.image else { print("image is not set"); return }
        guard let information = cropInformation else { print("cropinformation is not set"); return }
        guard let targetRect = estimateCropAreaWithCropInformation(information) else { print("calculating rect got error"); return }
        guard let croppedCGImage = targetImage.cgImage?.cropping(to: targetRect) else { print("image setting error"); return }
        let croppedImage = UIImage(cgImage: croppedCGImage)
        requiredActionAfterCroppingFinished?(croppedImage)
    }
    //end
    
    //MARK: perform crop as ImageCropData
    private func generateImageCropInformation(imageRatio: Double, originalImageSize: CGSize, estimateCropAreaInImage: CGRect) -> CropInformation {
        
        var isHorizontalImage: Bool {
            if imageRatio > 1 {
                return true
            } else {
                return false
            }
        }
        
        let originalImageSizeFactor = originalImageSize
        
        let percentageSizeWidth = Double(estimateCropAreaInImage.width/originalImageSizeFactor.width)
        let percentageSizeHeight = Double(estimateCropAreaInImage.height/originalImageSizeFactor.height)
        let percentageOriginX = Double(estimateCropAreaInImage.origin.x/originalImageSizeFactor.width)
        let percentageOriginY = Double(estimateCropAreaInImage.origin.y/originalImageSizeFactor.height)
        
        let cropInfo = CropInformation(isHorizontal: isHorizontalImage, percentageSizeOfWillCroppedArea: CropInformation.percentageSizeInImage(width: percentageSizeWidth, height: percentageSizeHeight), percentagePostionInScrollView: CropInformation.percentagePostionInImage(dX: percentageOriginX, dY: percentageOriginY))
        
        return cropInfo
    }
    
    func requestImageCropInformation() -> CropInformation? {
        guard let image = imageView.image else {return nil}
        let imageInfo = generateImageCropInformation(imageRatio: Double(croppingViewStatus.ratio), originalImageSize: image.size, estimateCropAreaInImage: estimateCropArea)
        return imageInfo
    }
    
    func requestCroppedImageData() -> CroppedImageInformation? {
        guard let data = image else { return nil }
        guard let imageInfo = requestImageCropInformation() else { return nil }
        return CroppedImageInformation(cropInformation: imageInfo, imageData: data)
    }
    
    private func calculateThumbnailAreaRectAsSquare() -> CGRect {
        let estimatedSizeFactor = min(estimateCropArea.width, estimateCropArea.height)
        let esimatedSize = CGSize(width: estimatedSizeFactor, height: estimatedSizeFactor)
        var isHorizontalCropArea: Bool {
            return (estimateCropArea.width/estimateCropArea.height > 1)
        }
        var thumbnailsRectOrigin = estimateCropArea.origin
        if isHorizontalCropArea {
            thumbnailsRectOrigin = thumbnailsRectOrigin.offSetBy(dX: (estimateCropArea.width - estimatedSizeFactor)/2, dY: 0)
        } else {
            thumbnailsRectOrigin = thumbnailsRectOrigin.offSetBy(dX: 0, dY: (estimateCropArea.height - estimatedSizeFactor)/2)
        }
        return CGRect(origin: thumbnailsRectOrigin, size: esimatedSize)
    }
    
    func requestThumbnailDataInEstimateCropArea() -> Data? {
        let rect = calculateThumbnailAreaRectAsSquare()
        guard let imageData = image else { return nil }
        guard let targetImage = UIImage(data: imageData)?.fixOrientation() else { return nil }
        guard let croppedCGImage = targetImage.cgImage?.cropping(to: rect) else { print("image setting error"); return nil }
        let croppedImage = UIImage(cgImage: croppedCGImage).resizedImageWithinRect(rectSize: CGSize(width: 150, height: 150))
        let thumbnailData = croppedImage.jpegData(compressionQuality: 1)
        return thumbnailData
    }
    
    private func updateCropInformation() {
        cropInformation = requestImageCropInformation()
    }
    // End
    
    //MARK: scrollview delegates
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        updateContentSize(false)
        updateCropInformation()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCropInformation()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCropInformation()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        updateCropInformation()
    }
    //end
    
    //MARK: draw and layoutsubviews
    override func layoutSubviews() {
        super.layoutSubviews()
        configureSubviews()
        refreshImage(cropInformation)
    }
    
    override func draw(_ rect: CGRect) {
        configureSubviews()
        refreshImage(cropInformation)
//        zoomWithCropInformationData(cropInformation)
    }
    //end
    
    //MARK: init methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureSubviews()
        imageScrollView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureSubviews()
        imageScrollView.delegate = self
    }
    
    convenience init(mode: CroppingViewMode, cropData: CroppedImageInformation?) {
        self.init()
        self.mode = mode
        self.croppedImageData = cropData
    }
    //end
}

extension ImageCroppingView {
    
    class CroppingArea: UIView {
        
        var recommendedCropAreaRect: CGRect! {
            didSet {
                setNeedsDisplay()
            }
        }
        
        override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            if self.recommendedCropAreaRect != nil {
                // Ensures to use the current background color to set the filling color
                self.backgroundColor?.setFill()
                UIRectFill(rect)
                
                let transparentLayer = CAShapeLayer()
                let path = CGMutablePath()
                
                // Make hole in view's overlay
                // NOTE: Here, instead of using the transparentHoleView UIView we could use a specific CFRect location instead...
                path.addRect(recommendedCropAreaRect)
                path.addRect(bounds)
                
                transparentLayer.path = path
                transparentLayer.fillRule = CAShapeLayerFillRule.evenOdd
                self.layer.mask = transparentLayer
            }
        }
        
        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            return false
        }
    }
    
    private var fullFrame: CGRect {
        return bounds
        //        let width = self.frame.width
        //        let height = self.frame.height
        //        let size = CGSize(width: width, height: height)
        //        return CGRect(origin: CGPoint.zero, size: size)
    }
    
    var centeredSuqareFrame: CGRect {
        let width = (fullFrame.width * 0.9).clearUnderDot
        let height = (fullFrame.height * 0.9).clearUnderDot
        let frameSize = CGSize(width: width, height: height)
        let origin = CGPoint(x: (imageScrollView.frame.width - width)/2, y: (imageScrollView.frame.height - height)/2)
        return CGRect(origin: origin, size: frameSize)
    }
    
    var verticalCenteredRectagleFrame: CGRect {
        var height = (imageScrollView.frame.height * 0.9).clearUnderDot
        let width = (height / 2.589).clearUnderDot
        
        var sizeCondition: Bool {
            return (width > frame.width)
        }
        
        while sizeCondition {
            height -= 0.1
        }
        
        let frameSize = CGSize(width: width, height: max(height, 0))
        let origin = CGPoint(x: (imageScrollView.frame.width - width)/2, y: (imageScrollView.frame.height - height)/2)
        return CGRect(origin: origin, size: frameSize)
    }
    
    var horizontalCenteredRectangleFrame: CGRect {
        var width = (imageScrollView.frame.width * 0.9).clearUnderDot
        let height = (width * 0.618).clearUnderDot
        
        var sizeCondition: Bool {
            return (height > frame.height)
        }
        
        if sizeCondition {
            while sizeCondition {
                width -= 0.1
            }
        }
        
        let frameSize = CGSize(width: width, height: height)
        let origin = CGPoint(x: (imageScrollView.frame.width - width)/2, y: (imageScrollView.frame.height - height)/2)
        return CGRect(origin: origin, size: frameSize)
    }
}
