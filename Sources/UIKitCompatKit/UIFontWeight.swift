import UIKit

// MARK: - UIFont.Weight Shim for iOS <8.2

@available(iOS, introduced: 6.0, deprecated: 8.2)
extension UIFont {
    typealias Weight = WeightA
    public struct WeightA: Equatable {
        let rawValue: CGFloat
        private init(_ value: CGFloat) { rawValue = value }
        
        public static let ultraLight = Weight(0.2)
        public static let thin       = Weight(0.25)
        public static let light      = Weight(0.3)
        public static let regular    = Weight(0.4)
        public static let medium     = Weight(0.5)
        public static let semibold   = Weight(0.6)
        public static let bold       = Weight(0.7)
        public static let heavy      = Weight(0.8)
        public static let black      = Weight(0.9)
    }
}


// MARK: - systemFont Shim
extension UIFont {
    @available(iOS, introduced: 6.0, deprecated: 8.2)
    static func systemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case .ultraLight: return UIFont(name: "HelveticaNeue-UltraLight", size: size) ?? UIFont.systemFont(ofSize: size)
        case .thin:       return UIFont(name: "HelveticaNeue-Thin", size: size) ?? UIFont.systemFont(ofSize: size)
        case .light:      return UIFont(name: "HelveticaNeue-Light", size: size) ?? UIFont.systemFont(ofSize: size)
        case .regular:    return UIFont.systemFont(ofSize: size)
        case .medium:     return UIFont(name: "HelveticaNeue-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        case .semibold:   return UIFont(name: "HelveticaNeue-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        case .bold, .heavy, .black:
            return UIFont.boldSystemFont(ofSize: size)
        default:
            return UIFont.systemFont(ofSize: size)
        }
    }

    @available(iOS, introduced: 6.0, deprecated: 13.0)
    static func monospacedSystemFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        switch weight {
        case .ultraLight, .thin, .light, .regular:
            return UIFont(name: "Courier", size: size) ?? UIFont.systemFont(ofSize: size)
        case .medium, .semibold, .bold, .heavy, .black:
            return UIFont(name: "Courier-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
        default:
            return UIFont(name: "Courier", size: size) ?? UIFont.systemFont(ofSize: size)
        }
    }
}
