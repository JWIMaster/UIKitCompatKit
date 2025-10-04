import UIKit
import ObjectiveC

// MARK: - UIView layoutMargins backport
private var layoutMarginsKey: UInt8 = 0
@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension UIView {
    var layoutMargins: UIEdgeInsets {
        get {
            (objc_getAssociatedObject(self, &layoutMarginsKey) as? NSValue)?.uiEdgeInsetsValue
            ?? UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        set {
            objc_setAssociatedObject(self, &layoutMarginsKey, NSValue(uiEdgeInsets: newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - UILayoutGuideShim (proxy-based)
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

    // MARK: - Anchors forwarding to proxyView
    public var topAnchor: Anchor { Anchor(view: proxyView, attribute: .top) }
    public var bottomAnchor: Anchor { Anchor(view: proxyView, attribute: .bottom) }
    public var leadingAnchor: Anchor { Anchor(view: proxyView, attribute: .leading) }
    public var trailingAnchor: Anchor { Anchor(view: proxyView, attribute: .trailing) }
    public var leftAnchor: Anchor { Anchor(view: proxyView, attribute: .left) }
    public var rightAnchor: Anchor { Anchor(view: proxyView, attribute: .right) }
    public var widthAnchor: Anchor { Anchor(view: proxyView, attribute: .width) }
    public var heightAnchor: Anchor { Anchor(view: proxyView, attribute: .height) }
    public var centerXAnchor: Anchor { Anchor(view: proxyView, attribute: .centerX) }
    public var centerYAnchor: Anchor { Anchor(view: proxyView, attribute: .centerY) }

    // MARK: - layoutFrame returns actual frame
    public var layoutFrame: CGRect {
        guard let view = owningView else { return .zero }
        view.layoutIfNeeded()
        return proxyView.frame
    }
}

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public typealias UILayoutGuide = UILayoutGuideShim

// MARK: - UIView layout guides storage
private var layoutGuidesKey: UInt8 = 0
private var layoutMarginsGuideKey: UInt8 = 0
private var safeAreaGuideKey: UInt8 = 0

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension UIView {

    // MARK: - addLayoutGuide backport
    func addLayoutGuide(_ guide: UILayoutGuideShim) {
        guide.attach(to: self)

        var guides = objc_getAssociatedObject(self, &layoutGuidesKey) as? [UILayoutGuideShim] ?? []
        guides.append(guide)
        objc_setAssociatedObject(self, &layoutGuidesKey, guides, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    var layoutGuides: [UILayoutGuideShim] {
        get { objc_getAssociatedObject(self, &layoutGuidesKey) as? [UILayoutGuideShim] ?? [] }
        set { objc_setAssociatedObject(self, &layoutGuidesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    // MARK: - layoutMarginsGuide
    var layoutMarginsGuide: UILayoutGuide {
        if let guide = objc_getAssociatedObject(self, &layoutMarginsGuideKey) as? UILayoutGuide { return guide }

        let guide = UILayoutGuide()
        guide.attach(to: self)

        // Pin proxyView to layoutMargins
        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top),
            guide.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left),
            guide.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right),
            guide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -layoutMargins.bottom)
        ])

        addLayoutGuide(guide)
        objc_setAssociatedObject(self, &layoutMarginsGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }

    // MARK: - safeAreaLayoutGuide
    var safeAreaLayoutGuide: UILayoutGuide {
        if let guide = objc_getAssociatedObject(self, &safeAreaGuideKey) as? UILayoutGuide { return guide }

        let guide = UILayoutGuide()
        guide.attach(to: self)

        var topInset: CGFloat = 0
        var bottomInset: CGFloat = 0
        if let vc = sequence(first: self.next, next: { $0?.next }).compactMap({ $0 as? UIViewController }).first {
            topInset += vc.topLayoutGuide.length
            bottomInset += vc.bottomLayoutGuide.length
        }

        NSLayoutConstraint.activate([
            guide.topAnchor.constraint(equalTo: topAnchor, constant: topInset),
            guide.leadingAnchor.constraint(equalTo: leadingAnchor),
            guide.trailingAnchor.constraint(equalTo: trailingAnchor),
            guide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -bottomInset)
        ])

        addLayoutGuide(guide)
        objc_setAssociatedObject(self, &safeAreaGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
}

// MARK: - UIViewController layout support shim
private var topGuideKey: UInt8 = 0
private var bottomGuideKey: UInt8 = 0

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public class UILayoutSupportShim: NSObject {
    public let length: CGFloat
    public init(length: CGFloat) { self.length = length }
}

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension UIViewController {
    var topLayoutGuide: UILayoutSupportShim {
        if let guide = objc_getAssociatedObject(self, &topGuideKey) as? UILayoutSupportShim { return guide }
        let statusBarHeight: CGFloat = UIApplication.shared.isStatusBarHidden ? 0 : 20
        let guide = UILayoutSupportShim(length: statusBarHeight) // default status bar height
        objc_setAssociatedObject(self, &topGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }

    var bottomLayoutGuide: UILayoutSupportShim {
        if let guide = objc_getAssociatedObject(self, &bottomGuideKey) as? UILayoutSupportShim { return guide }
        let guide = UILayoutSupportShim(length: 0)
        objc_setAssociatedObject(self, &bottomGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
}
