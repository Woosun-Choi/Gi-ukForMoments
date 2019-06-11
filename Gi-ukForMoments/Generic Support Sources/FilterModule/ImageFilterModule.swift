//
//  ImageFilterModule.swift
//  ImageFilerBasic
//
//  Created by goya on 27/12/2018.
//  Copyright © 2018 goya. All rights reserved.
//

import UIKit

class ImageFilterModule {
    
    private let context = CIContext()
    
    var filters : [CIFilterName] {
        return CIFilterName.allFilters
    }
    
    enum CIFilterName: String {
        case None = "None"
        case CIPhotoEffectChrome = "CIPhotoEffectChrome"
        case CIPhotoEffectFade = "CIPhotoEffectFade"
        case CIPhotoEffectInstant = "CIPhotoEffectInstant"
        case CIPhotoEffectNoir = "CIPhotoEffectNoir"
        case CIPhotoEffectProcess = "CIPhotoEffectProcess"
        case CIPhotoEffectTonal = "CIPhotoEffectTonal"
        case CIPhotoEffectTransfer = "CIPhotoEffectTransfer"
        case CISepiaTone = "CISepiaTone"
        case CIToneCurve = "CIToneCurve"
        case CIColorClamp = "CIColorClamp"
        case CIColorControls = "CIColorControls"
        
        static var allFilters: [CIFilterName] { return [
            CIFilterName.None,
            .CIPhotoEffectChrome,
            .CIPhotoEffectFade,
            .CIPhotoEffectInstant,
            .CIPhotoEffectNoir,
            .CIPhotoEffectProcess,
            .CIPhotoEffectTonal,
            .CIPhotoEffectTransfer,
            .CISepiaTone,
            .CIColorClamp,
            .CIColorControls]
        }
        
        static func requestedFilter(_ name: String) -> CIFilterName? {
            for filter in CIFilterName.allFilters {
                if filter.rawValue == name {
                    return filter
                }
            }
            return nil
        }
    }
    
    private enum CIFilterEffects {
        case None
        case CIPhotoEffectChrome((CIImage) -> CIImage?)
        case CIPhotoEffectFade((CIImage) -> CIImage?)
        case CIPhotoEffectInstant((CIImage) -> CIImage?)
        case CIPhotoEffectNoir((CIImage) -> CIImage?)
        case CIPhotoEffectProcess((CIImage) -> CIImage?)
        case CIPhotoEffectTonal((CIImage) -> CIImage?)
        case CIPhotoEffectTransfer((CIImage) -> CIImage?)
        case CISepiaTone((CIImage) -> CIImage?)
        case CIColorClamp((CIImage) -> CIImage?)
        case CIColorControls((CIImage) -> CIImage?)
    }
    
    private var CIFilterEffectsLibary : Dictionary<String,CIFilterEffects> = [
        "None" : CIFilterEffects.None,
        "CIPhotoEffectChrome": CIFilterEffects.CIPhotoEffectChrome({
            let filter = CIFilter(name: "CIPhotoEffectChrome" )
            filter?.setValue($0, forKey: kCIInputImageKey)
            return filter?.outputImage
        }),
        "CIPhotoEffectFade": CIFilterEffects.CIPhotoEffectFade({
            let filter = CIFilter(name: "CIPhotoEffectFade" )
            filter?.setValue($0, forKey: kCIInputImageKey)
            return filter?.outputImage
        }),
        "CIPhotoEffectInstant": CIFilterEffects.CIPhotoEffectInstant({
            let filter = CIFilter(name: "CIPhotoEffectInstant" )
            filter?.setValue($0, forKey: kCIInputImageKey)
            return filter?.outputImage
        }),
        "CIPhotoEffectNoir": CIFilterEffects.CIPhotoEffectNoir({
            let filter = CIFilter(name: "CIPhotoEffectNoir" )
            filter?.setValue($0, forKey: kCIInputImageKey)
            return filter?.outputImage
        }),
        "CIPhotoEffectProcess": CIFilterEffects.CIPhotoEffectProcess({
            let filter = CIFilter(name: "CIPhotoEffectProcess" )
            filter?.setValue($0, forKey: kCIInputImageKey)
            return filter?.outputImage
        }),
        "CIPhotoEffectTonal": CIFilterEffects.CIPhotoEffectTonal({
            let filter = CIFilter(name: "CIPhotoEffectTonal" )
            filter?.setValue($0, forKey: kCIInputImageKey)
            return filter?.outputImage
        }),
        "CIPhotoEffectTransfer": CIFilterEffects.CIPhotoEffectTransfer({
            let filter = CIFilter(name: "CIPhotoEffectTransfer" )
            filter?.setValue($0, forKey: kCIInputImageKey)
            return filter?.outputImage
        }),
        "CISepiaTone": CIFilterEffects.CISepiaTone({
            guard let filter = CIFilter(name: "CISepiaTone" ) else { return nil}
            filter.setValue($0, forKey: kCIInputImageKey)
            return filter.outputImage
        }),
        "CIColorClamp": CIFilterEffects.CIColorClamp({
            guard let filter = CIFilter(name: "CISepiaTone" ) else { return nil}
            filter.setValue($0, forKey: kCIInputImageKey)
            return filter.outputImage
        }),
        "CIColorControls": CIFilterEffects.CIColorControls({
            guard let filter = CIFilter(name: "CISepiaTone" ) else { return nil}
            filter.setValue($0, forKey: kCIInputImageKey)
            return filter.outputImage
        })
    ]
    
    func performImageFilter(_ filter: CIFilterName, image: UIImage) -> UIImage? {
        guard let coreImage = CIImage(image: image) else { return nil }
        let orientation = image.imageOrientation
        
        func finalResult(_ ciimage: CIImage) -> UIImage {
            let result = context.createCGImage(ciimage, from: ciimage.extent)
            return UIImage(cgImage: result!)
        }
        
        if let operation = CIFilterEffectsLibary[filter.rawValue] {
            switch operation {
            case .None : return image
            case .CIPhotoEffectChrome(let function) :
                return finalResult(function(coreImage)!)
            case .CIPhotoEffectFade(let function) :
                return finalResult(function(coreImage)!)
            case .CIPhotoEffectInstant(let function) :
                return finalResult(function(coreImage)!)
            case .CIPhotoEffectNoir(let function) :
                return finalResult(function(coreImage)!)
            case .CIPhotoEffectProcess(let function) :
                return finalResult(function(coreImage)!)
            case .CIPhotoEffectTonal(let function) :
                return finalResult(function(coreImage)!)
            case .CIPhotoEffectTransfer(let function) :
                return finalResult(function(coreImage)!)
            case .CISepiaTone(let function) :
                return finalResult(function(coreImage)!)
            case .CIColorClamp(let function) :
                return finalResult(function(coreImage)!)
            case .CIColorControls(let function) :
                return finalResult(function(coreImage)!)
            }
        } else {
            return nil
        }
    }
    
    func perfromContext() {
    }
    
}
