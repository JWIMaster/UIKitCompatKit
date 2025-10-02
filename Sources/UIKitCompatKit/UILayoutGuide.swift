import UIKit
import ObjectiveC

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public class UILayoutGuideShim {
    private weak var owningView: UIView?
    private let proxyView: UIView

    public init() {
        proxyView = UIView()
        proxyView.translatesAutoresizingMaskIntoConstraints = false
        proxyView.isHidden = true
    }

    /// Attach the layout guide to a parent view
    public func attach(to view: UIView) {
        owningView = view
        view.addSubview(proxyView)
    }

    // MARK: - Anchors
    public var leadingAnchor: Anchor { proxyView.leadingAnchor }
    public var trailingAnchor: Anchor { proxyView.trailingAnchor }
    public var topAnchor: Anchor { proxyView.topAnchor }
    public var bottomAnchor: Anchor { proxyView.bottomAnchor }
    public var widthAnchor: Anchor { proxyView.widthAnchor }
    public var heightAnchor: Anchor { proxyView.heightAnchor }
    public var centerXAnchor: Anchor { proxyView.centerXAnchor }
    public var centerYAnchor: Anchor { proxyView.centerYAnchor }
}

extension UIScrollView {
    private struct Keys {
        static var contentGuide = "contentLayoutGuideShim"
        static var frameGuide = "frameLayoutGuideShim"
    }

    @available(iOS, introduced: 6.0, deprecated: 11.0)
    public var contentLayoutGuide: UILayoutGuideShim {
        if let guide = objc_getAssociatedObject(self, &Keys.contentGuide) as? UILayoutGuideShim {
            return guide
        }
        let guide = UILayoutGuideShim()
        guide.attach(to: self)
        objc_setAssociatedObject(self, &Keys.contentGuide, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
    
    @available(iOS, introduced: 6.0, deprecated: 11.0)
    public var frameLayoutGuide: UILayoutGuideShim {
        if let guide = objc_getAssociatedObject(self, &Keys.frameGuide) as? UILayoutGuideShim {
            return guide
        }
        let guide = UILayoutGuideShim()
        guide.attach(to: self)
        objc_setAssociatedObject(self, &Keys.frameGuide, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
}

