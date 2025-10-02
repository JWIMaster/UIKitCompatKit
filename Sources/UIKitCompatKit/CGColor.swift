import UIKit

extension CGColor {
    /// Mimics CGColor(red:green:blue:alpha:) on iOS <13
    @available(iOS, introduced: 6.0, obsoleted: 13.0)
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        self.init(cgColor: color.cgColor)
    }
}
