import UIKit

// MARK: - User Interface Size Class Standin

@available(iOS, introduced: 2.0, obsoleted: 8.0)
public enum UIUserInterfaceSizeClass: Int {
    case unspecified = 0
    case compact = 1
    case regular = 2
}

// MARK: - Trait Collection Shim Standin

@available(iOS, introduced: 2.0, obsoleted: 8.0)
open class UITraitCollection: NSObject {
    public let horizontalSizeClass: UIUserInterfaceSizeClass
    public let verticalSizeClass: UIUserInterfaceSizeClass
    public let userInterfaceIdiom: UIUserInterfaceIdiom
    
    // Initialiser matches UIKit’s
    public init(horizontalSizeClass: UIUserInterfaceSizeClass = .unspecified,
                verticalSizeClass: UIUserInterfaceSizeClass = .unspecified,
                userInterfaceIdiom: UIUserInterfaceIdiom = .unspecified) {
        self.horizontalSizeClass = horizontalSizeClass
        self.verticalSizeClass = verticalSizeClass
        self.userInterfaceIdiom = userInterfaceIdiom
    }
    
    // MARK: - API surface
    
    open class func current() -> UITraitCollection {
        return UITraitCollection()
    }
    
    open func containsTraits(in trait: UITraitCollection) -> Bool {
        return (trait.horizontalSizeClass == .unspecified || trait.horizontalSizeClass == horizontalSizeClass)
            && (trait.verticalSizeClass == .unspecified || trait.verticalSizeClass == verticalSizeClass)
            && (trait.userInterfaceIdiom == .unspecified || trait.userInterfaceIdiom == userInterfaceIdiom)
    }
    
    open class func traits(from array: [UITraitCollection]) -> UITraitCollection {
        var h: UIUserInterfaceSizeClass = .unspecified
        var v: UIUserInterfaceSizeClass = .unspecified
        var idiom: UIUserInterfaceIdiom = .unspecified
        for t in array {
            if h == .unspecified { h = t.horizontalSizeClass }
            if v == .unspecified { v = t.verticalSizeClass }
            if idiom == .unspecified { idiom = t.userInterfaceIdiom }
        }
        return UITraitCollection(horizontalSizeClass: h, verticalSizeClass: v, userInterfaceIdiom: idiom)
    }
}

// MARK: - UIViewController Shim

@available(iOS, introduced: 2.0, obsoleted: 8.0)
extension UIViewController {
    @objc open var traitCollection: UITraitCollection {
        return UITraitCollection()
    }
    
    @objc open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // iOS 6 doesn’t support trait changes — no-op
    }
}

// MARK: - UIView Shim

@available(iOS, introduced: 2.0, obsoleted: 8.0)
extension UIView {
    @objc open var traitCollection: UITraitCollection {
        return UITraitCollection()
    }
    
    @objc open func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        // iOS 6 doesn’t support trait changes — no-op
    }
}
