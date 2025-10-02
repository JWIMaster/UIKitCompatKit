import UIKit

// MARK: - UILayoutGuide Shim
@available(iOS, introduced: 6.0, obsoleted: 9.0)
public class UILayoutGuideShim {
    fileprivate weak var owningView: UIView?
    fileprivate let proxyView: UIView

    public init() {
        proxyView = UIView()
        proxyView.translatesAutoresizingMaskIntoConstraints = false
        proxyView.isHidden = true
    }

    fileprivate func attach(to view: UIView) {
        owningView = view
        view.addSubview(proxyView)
    }

    // Anchors (all use Anchor shim)
    public var leadingAnchor: Anchor { proxyView.leadingAnchor }
    public var trailingAnchor: Anchor { proxyView.trailingAnchor }
    public var leftAnchor: Anchor { proxyView.leftAnchor }
    public var rightAnchor: Anchor { proxyView.rightAnchor }
    public var topAnchor: Anchor { proxyView.topAnchor }
    public var bottomAnchor: Anchor { proxyView.bottomAnchor }
    public var widthAnchor: Anchor { proxyView.widthAnchor }
    public var heightAnchor: Anchor { proxyView.heightAnchor }
    public var centerXAnchor: Anchor { proxyView.centerXAnchor }
    public var centerYAnchor: Anchor { proxyView.centerYAnchor }
}

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public typealias UILayoutGuide = UILayoutGuideShim

// MARK: - UIView layout guide storage
private var layoutGuidesKey: UInt8 = 0
private var layoutMarginsKey: UInt8 = 0
private var layoutMarginsGuideKey: UInt8 = 0
private var safeAreaGuideKey: UInt8 = 0

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension UIView {
    func addLayoutGuide(_ guide: UILayoutGuideShim) {
        guide.attach(to: self)
        var guides = objc_getAssociatedObject(self, &layoutGuidesKey) as? [UILayoutGuide] ?? []
        guides.append(guide)
        objc_setAssociatedObject(self, &layoutGuidesKey, guides, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    var layoutGuides: [UILayoutGuide] {
        get { objc_getAssociatedObject(self, &layoutGuidesKey) as? [UILayoutGuide] ?? [] }
        set { objc_setAssociatedObject(self, &layoutGuidesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var layoutMargins: UIEdgeInsets {
        get { (objc_getAssociatedObject(self, &layoutMarginsKey) as? NSValue)?.uiEdgeInsetsValue ?? UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) }
        set { objc_setAssociatedObject(self, &layoutMarginsKey, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    var layoutMarginsGuide: UILayoutGuide {
        if let guide = objc_getAssociatedObject(self, &layoutMarginsGuideKey) as? UILayoutGuide { return guide }
        let guide = UILayoutGuide()
        self.addLayoutGuide(guide)
        guide.topAnchor.constraint(equalTo: Anchor(view: self, attribute: .top), constant: layoutMargins.top).isActive = true
        guide.bottomAnchor.constraint(equalTo: Anchor(view: self, attribute: .bottom), constant: -layoutMargins.bottom).isActive = true
        guide.leadingAnchor.constraint(equalTo: Anchor(view: self, attribute: .leading), constant: layoutMargins.left).isActive = true
        guide.trailingAnchor.constraint(equalTo: Anchor(view: self, attribute: .trailing), constant: -layoutMargins.right).isActive = true
        objc_setAssociatedObject(self, &layoutMarginsGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }

    var safeAreaLayoutGuide: UILayoutGuide {
        if let guide = objc_getAssociatedObject(self, &safeAreaGuideKey) as? UILayoutGuide { return guide }
        let guide = UILayoutGuide()
        self.addLayoutGuide(guide)

        if let vc = sequence(first: self.next, next: { $0?.next }).compactMap({ $0 as? UIViewController }).first {
            guide.topAnchor.constraint(equalTo: vc.topLayoutGuide.bottomAnchor).isActive = true
            guide.bottomAnchor.constraint(equalTo: vc.bottomLayoutGuide.topAnchor).isActive = true
        } else {
            guide.topAnchor.constraint(equalTo: Anchor(view: self, attribute: .top)).isActive = true
            guide.bottomAnchor.constraint(equalTo: Anchor(view: self, attribute: .bottom)).isActive = true
        }

        guide.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        guide.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true

        objc_setAssociatedObject(self, &safeAreaGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
}

// MARK: - Pre-iOS 9 UILayoutSupport Shim Protocol
@available(iOS, introduced: 6.0, obsoleted: 9.0)
public protocol UILayoutSupportShimProtocol: AnyObject {
    var length: CGFloat { get }
    var topAnchor: Anchor { get }
    var bottomAnchor: Anchor { get }
}




// MARK: - UIViewController layout support shim
private var topGuideKey: UInt8 = 0
private var bottomGuideKey: UInt8 = 0

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public class UILayoutSupportShim: NSObject, UILayoutSupportShimProtocol {
    public let length: CGFloat
    weak var associatedView: UIView?

    public init(length: CGFloat, view: UIView? = nil) {
        self.length = length
        self.associatedView = view
    }

    public var topAnchor: Anchor { Anchor(view: associatedView ?? UIView(), attribute: .top) }
    public var bottomAnchor: Anchor { Anchor(view: associatedView ?? UIView(), attribute: .bottom) }
}

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension UIViewController {
    var topLayoutGuide: UILayoutSupportShim {
        if let guide = objc_getAssociatedObject(self, &topGuideKey) as? UILayoutSupportShim { return guide }
        let guide = UILayoutSupportShim(length: 20, view: self.view)
        objc_setAssociatedObject(self, &topGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }

    var bottomLayoutGuide: UILayoutSupportShim {
        if let guide = objc_getAssociatedObject(self, &bottomGuideKey) as? UILayoutSupportShim { return guide }
        let guide = UILayoutSupportShim(length: 0, view: self.view)
        objc_setAssociatedObject(self, &bottomGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
}
