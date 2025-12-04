#if !targetEnvironment(macCatalyst)
#if compiler(<6.0)
#if !canImport(UIKit.UILayoutGuide)
import UIKit

extension UIScrollView {
    private struct Keys {
        static var contentGuide = "contentLayoutGuideShim"
        static var frameGuide = "frameLayoutGuideShim"
    }

    @available(iOS, introduced: 6.0, deprecated: 11.0)
    @_disfavoredOverload
    public var contentLayoutGuide: UILayoutGuideShim {
        if let guide = objc_getAssociatedObject(self, &Keys.contentGuide) as? UILayoutGuideShim {
            return guide
        }
        let guide = UILayoutGuideShim()
        self.addLayoutGuide(guide)
        objc_setAssociatedObject(self, &Keys.contentGuide, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
    
    @available(iOS, introduced: 6.0, deprecated: 11.0)
    @_disfavoredOverload
    public var frameLayoutGuide: UILayoutGuideShim {
        if let guide = objc_getAssociatedObject(self, &Keys.frameGuide) as? UILayoutGuideShim {
            return guide
        }
        let guide = UILayoutGuideShim()
        self.addLayoutGuide(guide)
        objc_setAssociatedObject(self, &Keys.frameGuide, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
}

#endif
#endif
#endif
