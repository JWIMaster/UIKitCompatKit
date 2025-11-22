import UIKit

public enum ChipsetClass: String {
    case a4 = "A4"
    case a5 = "A5"
    case a6 = "A6"
    case a7_a8 = "A7–A8"
    case a9Plus = "A9+"
    case a12Plus = "A12+"
    case unknown = "Unknown"
}

public class DeviceInfo {

    static let shared = DeviceInfo()

    public init() {}

    /// Returns the human-readable device identifier, e.g., "iPhone8,1"
    func deviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        let identifier = mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }

    /// Returns the device chipset class based on identifier
    public func chipsetClass() -> ChipsetClass {
        let id = deviceIdentifier()

        // iPhone
        if id.hasPrefix("iPhone") {
            switch id {
            case "iPhone1,1", "iPhone1,2": // iPhone 1 & 3G
                return .unknown
            case "iPhone2,1": // iPhone 3GS
                return .a4
            case "iPhone3,1", "iPhone3,2", "iPhone3,3": // iPhone 4
                return .a4
            case "iPhone4,1": // iPhone 4S
                return .a5
            case "iPhone5,1", "iPhone5,2": // iPhone 5
                return .a6
            case "iPhone5,3", "iPhone5,4": // iPhone 5C
                return .a6
            case "iPhone6,1", "iPhone6,2": // iPhone 5S
                return .a7_a8
            case "iPhone7,1", "iPhone7,2": // iPhone 6 & 6 Plus
                return .a7_a8
            case "iPhone8,1", "iPhone8,2", "iPhone8,4": // iPhone 6S & SE
                return .a9Plus
            case "iPhone9,1", "iPhone9,3": // iPhone 7
                return .a9Plus
            case "iPhone9,2", "iPhone9,4": // iPhone 7 Plus
                return .a9Plus
            case "iPhone10,1", "iPhone10,4": // iPhone 8
                return .a9Plus
            case "iPhone10,2", "iPhone10,5": // iPhone 8 Plus
                return .a9Plus
            case "iPhone10,3", "iPhone10,6": // iPhone X
                return .a9Plus
            case "iPhone11,2": // iPhone XS
                return .a12Plus
            case "iPhone11,4", "iPhone11,6": // iPhone XS Max
                return .a12Plus
            case "iPhone11,8": // iPhone XR
                return .a12Plus
            case "iPhone12,1": // iPhone 11
                return .a12Plus
            case "iPhone12,3": // iPhone 11 Pro
                return .a12Plus
            case "iPhone12,5": // iPhone 11 Pro Max
                return .a12Plus
            case "iPhone12,8": // iPhone SE (2nd gen)
                return .a12Plus
            case "iPhone13,1", "iPhone13,2", "iPhone13,3", "iPhone13,4": // iPhone 12 series
                return .a12Plus
            case "iPhone14,2", "iPhone14,3", "iPhone14,4", "iPhone14,5": // iPhone 13 series
                return .a12Plus
            case "iPhone14,6": // iPhone SE (3rd gen)
                return .a12Plus
            case "iPhone14,7", "iPhone14,8": // iPhone 14 series
                return .a12Plus
            case "iPhone15,2", "iPhone15,3": // iPhone 14 Pro series
                return .a12Plus
            case "iPhone15,4": // iPhone 15
                return .a12Plus
            default:
                return .unknown
            }
        }

        // iPad
        if id.hasPrefix("iPad") {
            switch id {
            case "iPad1,1", "iPad1,2": // iPad 1
                return .a4
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": // iPad 2
                return .a5
            case "iPad3,1", "iPad3,2", "iPad3,3": // iPad 3
                return .a5
            case "iPad3,4", "iPad3,5", "iPad3,6": // iPad 4
                return .a6
            case "iPad4,1", "iPad4,2", "iPad4,3": // iPad Air
                return .a7_a8
            case "iPad5,1", "iPad5,2": // iPad mini 4
                return .a7_a8
            case "iPad6,3", "iPad6,4": // iPad Pro 9.7"
                return .a7_a8
            case "iPad6,7", "iPad6,8": // iPad Pro 12.9"
                return .a7_a8
            case "iPad7,1", "iPad7,2": // iPad Pro 12.9" (2nd gen)
                return .a9Plus
            case "iPad7,3", "iPad7,4": // iPad Pro 10.5"
                return .a9Plus
            case "iPad7,5", "iPad7,6": // iPad (6th gen)
                return .a9Plus
            case "iPad7,11", "iPad7,12": // iPad (7th gen)
                return .a9Plus
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": // iPad Pro 11"
                return .a9Plus
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": // iPad Pro 12.9" (3rd gen)
                return .a9Plus
            case "iPad8,9", "iPad8,10": // iPad Pro 11" (2nd gen)
                return .a9Plus
            case "iPad8,11", "iPad8,12": // iPad Pro 12.9" (4th gen)
                return .a9Plus
            default:
                return .unknown
            }
        }

        // iPod
        if id.hasPrefix("iPod") {
            switch id {
            case "iPod1,1": // iPod touch (1st gen)
                return .unknown
            case "iPod2,1": // iPod touch (2nd gen)
                return .unknown
            case "iPod3,1": // iPod touch (3rd gen)
                return .a4
            case "iPod4,1": // iPod touch (4th gen)
                return .a4
            case "iPod5,1": // iPod touch (5th gen)
                return .a5
            case "iPod7,1": // iPod touch (6th gen)
                return .a7_a8
            case "iPod9,1": // iPod touch (7th gen)
                return .a9Plus
            default:
                return .unknown
            }
        }

        return .unknown
    }

    /// Convenience method: get a human-readable string
    public func chipsetClassString() -> ChipsetClass {
        return chipsetClass()
    }
}
