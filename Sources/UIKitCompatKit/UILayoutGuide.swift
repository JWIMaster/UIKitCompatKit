import UIKit
import ObjectiveC

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

    // Anchors using your Anchor backport
    public var leadingAnchor: Anchor { Anchor(view: proxyView, attribute: .leading) }
    public var trailingAnchor: Anchor { Anchor(view: proxyView, attribute: .trailing) }
    public var leftAnchor: Anchor { Anchor(view: proxyView, attribute: .left) }
    public var rightAnchor: Anchor { Anchor(view: proxyView, attribute: .right) }
    public var topAnchor: Anchor { Anchor(view: proxyView, attribute: .top) }
    public var bottomAnchor: Anchor { Anchor(view: proxyView, attribute: .bottom) }
    public var widthAnchor: Anchor { Anchor(view: proxyView, attribute: .width) }
    public var heightAnchor: Anchor { Anchor(view: proxyView, attribute: .height) }
    public var centerXAnchor: Anchor { Anchor(view: proxyView, attribute: .centerX) }
    public var centerYAnchor: Anchor { Anchor(view: proxyView, attribute: .centerY) }

    // Public layoutFrame for reading
    public var layoutFrame: CGRect {
        proxyView.frame
    }
}

// MARK: - UIView Layout Guide Storage
private var layoutGuidesKey: UInt8 = 0
private var layoutMarginsKey: UInt8 = 0
private var layoutMarginsGuideKey: UInt8 = 0
private var safeAreaGuideKey: UInt8 = 0

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public typealias UILayoutGuide = UILayoutGuideShim

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

        guide.topAnchor.constraint(equalTo: self.topAnchor, constant: layoutMargins.top).isActive = true
        guide.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -layoutMargins.bottom).isActive = true
        guide.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: layoutMargins.left).isActive = true
        guide.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -layoutMargins.right).isActive = true

        objc_setAssociatedObject(self, &layoutMarginsGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }

    var safeAreaLayoutGuide: UILayoutGuide {
        if let guide = objc_getAssociatedObject(self, &safeAreaGuideKey) as? UILayoutGuide { return guide }
        let guide = UILayoutGuide()
        self.addLayoutGuide(guide)

        var topOffset: CGFloat = 0
        var bottomOffset: CGFloat = 0

        if let vc = sequence(first: self.next, next: { $0?.next }).compactMap({ $0 as? UIViewController }).first {
            topOffset = vc.topLayoutGuide.length
            bottomOffset = vc.bottomLayoutGuide.length
        }

        guide.topAnchor.constraint(equalTo: self.topAnchor, constant: topOffset + layoutMargins.top).isActive = true
        guide.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -(bottomOffset + layoutMargins.bottom)).isActive = true
        guide.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: layoutMargins.left).isActive = true
        guide.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -layoutMargins.right).isActive = true

        objc_setAssociatedObject(self, &safeAreaGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }

    // Method to layout all guides manually
    func layoutAllGuides() {
        for guide in layoutGuides {
            guide.proxyView.superview?.layoutIfNeeded()
        }
    }
}

// MARK: - UIViewController Layout Support Shim
private var topGuideKey: UInt8 = 0
private var bottomGuideKey: UInt8 = 0

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public class UILayoutSupportShim: NSObject {
    public let length: CGFloat
    fileprivate let proxyView: UIView

    public init(length: CGFloat, view: UIView? = nil) {
        self.length = length
        proxyView = UIView()
        proxyView.translatesAutoresizingMaskIntoConstraints = false
        proxyView.isHidden = true
        view?.addSubview(proxyView)
    }

    public var topAnchor: Anchor { Anchor(view: proxyView, attribute: .top) }
    public var bottomAnchor: Anchor { Anchor(view: proxyView, attribute: .bottom) }
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
