//
//  PublicExtentions.swift
//  Don't Panic
//
//  Created by goya on 20/02/2019.
//  Copyright © 2019 goya. All rights reserved.
//

import UIKit

public func findItemsIndexInArray<T:Comparable>(_ array: [T], item: T) -> Int? {
    for (index, element) in array.enumerated() {
        if element == item {
            return index
        }
    }
    return nil
}

public func generateUIView<T: UIView>(view: T!, origin: CGPoint, size: CGSize) -> T! {
    if view == nil {
        let container = T()
        container.frame.size = size
        container.frame.origin = origin
        return container
    } else {
        view.frame.size = size
        view.frame.origin = origin
        return view
    }
}

public func generateUIView<T: UIView>(view: T!, frame: CGRect) -> T! {
    if view == nil {
        let container = T()
        container.frame = frame
        return container
    } else {
        view.frame = frame
        return view
    }
}

extension UIFont {
    
    enum appleSDGothicNeo: String {
        
        case thin = "AppleSDGothicNeo-Thin"
        case light = "AppleSDGothicNeo-Light"
        case regular = "AppleSDGothicNeo-Regular"
        case medium = "AppleSDGothicNeo-Medium"
        case semiBold = "AppleSDGothicNeo-SemiBold"
        case bold = "AppleSDGothicNeo-Bold"
        
        func font(size: CGFloat) -> UIFont {
            let font = UIFont(name: self.rawValue, size: size)!
            let metrics = UIFontMetrics.default
            let fontToUse = metrics.scaledFont(for: font)
            return fontToUse
        }
    }
}

extension UILabel {
    
    enum displayingTypes {
        case header
        case body
        case footer
    }
    
    private struct defaultFontSize {
        static let big : CGFloat = 25
        static let medium : CGFloat = 15
        static let small : CGFloat = 13
    }
    
    func setLabelAsSDStyle(type: displayingTypes) {
        switch type {
        case .header:
            self.font = UIFont.appleSDGothicNeo.medium.font(size: defaultFontSize.big)
        case .body :
            self.font = UIFont.appleSDGothicNeo.medium.font(size: defaultFontSize.medium)
        case .footer :
            self.font = UIFont.appleSDGothicNeo.medium.font(size: defaultFontSize.small)
        }
    }
    
    func setLabelAsSDStyleWithSpecificFontSize(type: UIFont.appleSDGothicNeo = .medium, fontSize: CGFloat) {
        self.font = type.font(size: fontSize)
    }
}

extension UIColor {
    
    static var goyaYellowWhite: UIColor {
        return UIColor.init(red: 241/255, green: 242/255, blue: 227/255, alpha: 1)
    }
    
    static var goyaBlack: UIColor {
        return UIColor.init(red: 50/255, green: 51/255, blue: 51/255, alpha: 1)
    }
    
    static var goyaSemiBlackColor: UIColor {
        return UIColor.init(red: 50/255, green: 51/255, blue: 51/255, alpha: 1)
    }
    
    static var GiukBackgroundColor_depth_1: UIColor {
        return UIColor.init(red: 105/255, green: 106/255, blue: 106/255, alpha: 1)
    }
    
    static var GiukBackgroundColor_depth_2: UIColor {
        return UIColor.init(red: 67/255, green: 68/255, blue: 68/255, alpha: 1)
    }
    
    static var goyaWhite: UIColor {
        return UIColor.init(red: 243/255, green: 243/255, blue: 243/255, alpha: 1)
    }
    
    static var goyaDarkWhite: UIColor {
        return UIColor.init(red: 233/255, green: 233/255, blue: 233/255, alpha: 1)
    }
    
    static var goyaZenColorBackground: UIColor {
        return UIColor.init(red: 55/255, green: 34/255, blue: 15/255, alpha: 1)
    }
    
    static var goyaZenColorYellow: UIColor {
        return UIColor.init(red: 241/255, green: 230/255, blue: 85/255, alpha: 1)
    }
    
    static var goyaZenColorOrange: UIColor {
        return UIColor.init(red: 211/255, green: 154/255, blue: 63/255, alpha: 1)
    }
    
    static var goyaBurgundyColor: UIColor {
        return UIColor.init(red: 128/255, green: 0/255, blue: 32/255, alpha: 1)
    }
    
    static var goyaFontColor: UIColor {
        return UIColor.init(red: 80/255, green: 81/255, blue: 81/255, alpha: 1)
    }
    
    static var goyaRoseGoldColor: UIColor {
        return UIColor.init(red: 223/255, green: 179/255, blue: 162/255, alpha: 1)
    }
    
    static var roseGoldColor: UIColor {
        return UIColor.init(red: 225/255, green: 198/255, blue: 179/255, alpha: 1)
    }
}

extension String {
    func centeredAttributedString(fontSize: CGFloat) -> NSAttributedString {
        let font = UIFont.appleSDGothicNeo.medium.font(size: fontSize)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        return NSAttributedString(string: self, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle,.font: font])
    }
}

extension CGRect {
    func offSetBy(dX: CGFloat, dY: CGFloat) -> CGRect {
        let newOrigin = self.origin.offSetBy(dX: dX, dY: dY)
        return CGRect(origin: newOrigin, size: self.size)
    }
}

extension CGFloat {
    var absValue : CGFloat {
        if self < 0 {
            return -self
        } else {
            return self
        }
    }
    
    var intValue: Int {
        return Int(self)
    }
    
    var clearUnderDot: CGFloat {
        return CGFloat(Int(self))
    }
    
    var preventNaN: CGFloat {
        if self.isNaN {
            return 1
        } else {
            return self
        }
    }
}

extension CGPoint {
    func offSetBy(dX: CGFloat, dY: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + dX, y: self.y + dY)
    }
}

extension Int {
    var absValue: Int {
        return Int(abs(Int32(self)))
    }
}

extension Date {
    
    static var dateForEmptyCell : Date {
        var component = Calendar.current.dateComponents([.year,.month,.day], from: Date())
        component.year = 1
        component.month = 1
        component.day = 1
        return Calendar.current.date(from: component)!
    }
    
    private var convertWithDateComponents : DateComponents {
        return Calendar.current.dateComponents([.day, .month, .year, .quarter, .weekday], from: self)
    }
    
    private var convertWithFullDateComponents : DateComponents {
        return Calendar.current.dateComponents([.day, .month, .year, .hour, .minute, .quarter, .weekday], from: self)
    }
    
    var day : Int {
        return self.convertWithDateComponents.day!
    }
    
    var month : Int {
        return self.convertWithDateComponents.month!
    }
    
    var year : Int {
        return self.convertWithDateComponents.year!
    }
    
    var weekDay : Int {
        return self.convertWithDateComponents.weekday!
    }
    
    var dateWithDateComponents : Date {
        let calender = Calendar.current
        let dateComponent = self.convertWithDateComponents
        let date = calender.date(from: dateComponent)
        return date!
    }
    
    static var currentDate : Date {
        let calender = Calendar.current
        let dateComponent = Date().convertWithDateComponents
        let date = calender.date(from: dateComponent)
        return date!
    }
    
    var firstDayOfMonth : Date {
        let calender = Calendar.current
        var dateComponent = self.convertWithDateComponents
        dateComponent.day = 1
        let date = calender.date(from: dateComponent)
        return date!
    }
    
    static func generateSpecificDate(year: Int, month: Int, day: Int) -> Date? {
        let calender = Calendar.current
        var component = Date().convertWithDateComponents
        component.year = year
        component.month = month
        component.day = day
        return calender.date(from: component)
    }
    
    
    static func firstDayOfTargetMonth(targetMonth: Int, year: Int = Date().year) -> Date {
        let calender = Calendar.current
        var dateComponent = Date().convertWithDateComponents
        dateComponent.day = 1
        dateComponent.month = targetMonth
        dateComponent.year = year
        let date = calender.date(from: dateComponent)
        return date!
    }
    
    static func lastDayOfTargetMonth(targetMonth: Int, year: Int = Date().year) -> Date {
        let calender = Calendar.current
        if targetMonth < 12 {
            let date = Date.firstDayOfTargetMonth(targetMonth: targetMonth + 1, year: year)
            var convertedDate = date.convertWithDateComponents
            convertedDate.day = (convertedDate.day ?? 0) - 1
            let lastDate = calender.date(from: convertedDate)!
            print(lastDate)
            return lastDate
        } else {
            let date = Date.firstDayOfTargetMonth(targetMonth: 1, year: year + 1)
            var convertedDate = date.convertWithDateComponents
            convertedDate.day = (convertedDate.day ?? 0) - 1
            let lastDate = calender.date(from: convertedDate)!
            print(lastDate)
            return lastDate
        }
    }
    
    static func monthCalenderFromTargetDate(date: Date) -> [Date] {
        var aMonthCalender = [Date]()
        let calender = Calendar.current
        var dateComponent = date.firstDayOfMonth.convertWithDateComponents
        
        while calender.date(from: dateComponent) != date.nextFirstDay {
            aMonthCalender.append(calender.date(from: dateComponent)!)
            dateComponent.day = dateComponent.day! + 1
        }
        
        return aMonthCalender
    }
    
    var firstDayOfYear : Date {
        let calender = Calendar.current
        var dateComponent = self.convertWithDateComponents
        dateComponent.day = 1
        dateComponent.month = 1
        let date = calender.date(from: dateComponent)
        return date!
    }
    
    var nextFirstDay : Date {
        let calender = Calendar.current
        var dateComponent = self.convertWithDateComponents
        if dateComponent.month != 12 {
            dateComponent.month = dateComponent.month! + 1
            dateComponent.day = 1
        } else {
            dateComponent.year = dateComponent.year! + 1
            dateComponent.month = 1
            dateComponent.day = 1
        }
        return calender.date(from: dateComponent)!
    }
    
    enum directions {
        case present
        case after
    }
    
    func setNewDateWithDistanceFromDate(direction: directions, from date: Date, distance: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        
        switch direction {
        case .present:
            (distance <= 0) ? (dateComponents.day = distance) : (dateComponents.day = -distance)
            return calendar.date(byAdding: dateComponents, to: date)?.dateWithDateComponents
        case .after:
            (distance >= 0) ? (dateComponents.day = distance) : (dateComponents.day = -distance)
            return calendar.date(byAdding: dateComponents, to: date)?.dateWithDateComponents
        }
    }
    
    func dateWithDistance(distance: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.day = distance
        return calendar.date(byAdding: dateComponents, to: self)?.dateWithDateComponents
    }
    
    var presentDate_typeFull: Date {
        let calender = Calendar.current
        var date = self.convertWithFullDateComponents
        if let day = date.day {
            date.day =  day - 1
            date.hour = 23
            date.minute = 59
        }
        let newDate = calender.date(from: date)!
        return newDate
    }
    
    var afterDate_typeFull: Date {
        let calender = Calendar.current
        var date = self.convertWithFullDateComponents
        if let day = date.day {
            date.day =  day + 1
            date.hour = 0
            date.minute = 0
        }
        let newDate = calender.date(from: date)!
        return newDate
    }
    
    var presentDate: Date {
        let newDate = setNewDateWithDistanceFromDate(direction: .present, from: self, distance: 1) ?? Date.currentDate
        return newDate
    }
    
    var afterDate: Date {
        let newDate = setNewDateWithDistanceFromDate(direction: .after, from: self, distance: 1) ?? Date.currentDate
        return newDate
    }
    
    private struct transformToRequestedType {
        static func transformToInt(_ com: Calendar.Component, from date: Date) -> DateComponents {
            let calendar = Calendar.current
            return calendar.dateComponents([com], from: date)
        }
        static func transformToString(dateformat format: String, from date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            return formatter.string(from: date)
        }
    }
    
    enum requestedDateData {
        case day
        case weekday
        case month
        case year
    }
    
    func requestStringFromDate(data: requestedDateData) -> String? {
        switch data {
        case .day: return transformToRequestedType.transformToString(dateformat: "dd", from: self)
        case .weekday: return transformToRequestedType.transformToString(dateformat: "EEEE", from: self)
        case .month: return transformToRequestedType.transformToString(dateformat: "MMM", from: self)
        case .year: return transformToRequestedType.transformToString(dateformat: "YYYY", from: self)
        }
    }
    
    func requestIntFromDate(data: requestedDateData) -> Int? {
        switch data {
        case .day: return transformToRequestedType.transformToInt(.day, from: self).day
        case .weekday: return self.weekDay
        case .month: return transformToRequestedType.transformToInt(.month, from: self).month
        case .year: return transformToRequestedType.transformToInt(.year, from: self).year
        }
    }
}

public extension UIDevice {
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad Mini 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}

extension UIView {
    
    func setNewFrame(_ frame: CGRect) {
        if self.frame != frame {
            self.frame = frame
            self.layoutSubviews()
        } else {
            return
        }
    }
    
    func setNewFrame(_ origin: CGPoint, size: CGSize) {
        if self.frame.origin != origin || self.frame.size != size{
            self.frame.origin = origin
            self.frame.size = size
            self.layoutSubviews()
        } else {
            return
        }
    }
    
    // Example use: myView.addBorder(toSide: .Left, withColor: UIColor.redColor().CGColor, andThickness: 1.0)
    
    enum ViewSide {
        case left, right, top, bottom
    }
    
    func addBorder(toSide side: ViewSide, withColor color: CGColor, andThickness thickness: CGFloat) {
        
        let border = CALayer()
        border.backgroundColor = color
        
        switch side {
        case .left: border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: thickness, height: frame.height); break
        case .right: border.frame = CGRect(x: bounds.maxX, y: bounds.minY, width: thickness, height: frame.height); break
        case .top: border.frame = CGRect(x: bounds.minX, y: bounds.minY, width: frame.width, height: thickness); break
        case .bottom: border.frame = CGRect(x: bounds.minX, y: bounds.maxY, width: frame.width, height: thickness); break
        }
        
        layer.addSublayer(border)
    }
    
}

extension UIViewController {
    
    func setNewFrame(_ frame: CGRect) {
        self.view.frame = frame
        self.view.setNeedsLayout()
    }
}

extension UIImage {
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        var myImage : UIImage?
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        if let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            myImage = newImage
        }
        return myImage!
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
    func fixOrientation() -> UIImage {
        
        guard let cgImage = cgImage else { return self }
        
        if imageOrientation == .up { return self }
        
        var transform = CGAffineTransform.identity
        
        switch imageOrientation {
            
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi/2)
            
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: -CGFloat.pi/2)
            
        case .up, .upMirrored:
            break
        default:
            break
        }
        
        switch imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
            
        case .up, .down, .left, .right:
            break
        default:
            break
        }
        
        if let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            
            ctx.concatenate(transform)
            
            switch imageOrientation {
                
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
                
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            }
            
            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage))
            }
        }
        
        // something failed -- return original
        return self
    }
    
    var withRenderingMode_alwaysTemplate : UIImage {
        return self.withRenderingMode(.alwaysTemplate)
        //you can set this image as letter, so you can set color for it.
        // ex) tintColor
    }
}

extension UIImageView {
    
    var imageFrame : CGRect {
        let imageViewSize = self.frame.size
        guard let imageSize = self.image?.size else{return CGRect.zero}
        let imageRatio = imageSize.width / imageSize.height
        let imageViewRatio = imageViewSize.width / imageViewSize.height
        if imageRatio < imageViewRatio {
            let scaleFactor = imageViewSize.height / imageSize.height
            let width = imageSize.width * scaleFactor
            let height = imageSize.height * scaleFactor
            let topLeftX = (imageViewSize.width - width) * 0.5
            let frameRect = CGRect(x: topLeftX, y: 0, width: width, height: height)
            return frameRect
        } else {
            let scaleFactor = imageViewSize.width / imageSize.width
            let width = imageSize.width * scaleFactor
            let height = imageSize.height * scaleFactor
            let topLeftY = (imageViewSize.height - height) * 0.5
            let frameRect = CGRect(x: 0, y: topLeftY, width: width, height: height)
            return frameRect
        }
    }
}

