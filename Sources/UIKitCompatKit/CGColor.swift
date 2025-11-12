import UIKit
import CoreGraphics

@available(iOS, introduced: 6.0, obsoleted: 13.0)
public struct CGColorShim {
    public let cgColor: CoreGraphics.CGColor

    // Mimic the iOS 13 initializer
    public init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.cgColor = UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
    }

    // Existing CGColor properties
    public var alpha: CGFloat { cgColor.alpha }
    public var colorSpace: CGColorSpace? { cgColor.colorSpace }
    public var components: [CGFloat]? { cgColor.components.map { Array($0) } }
    public var numberOfComponents: Int { cgColor.numberOfComponents }
    public var pattern: CGPattern? { cgColor.pattern }

    // Forward equality
    public static func == (lhs: CGColorShim, rhs: CGColorShim) -> Bool {
        return lhs.cgColor == rhs.cgColor
    }
}




