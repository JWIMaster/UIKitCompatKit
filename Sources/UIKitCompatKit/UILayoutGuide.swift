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

// MARK: - UILayoutGuide shim
@available(iOS, introduced: 6.0, obsoleted: 9.0)
public class UILayoutGuideShim {
    fileprivate weak var owningView: UIView?
    fileprivate var topInset: CGFloat = 0
    fileprivate var bottomInset: CGFloat = 0
    fileprivate var leadingInset: CGFloat = 0
    fileprivate var trailingInset: CGFloat = 0
    
    public init() {}
    
    fileprivate func attach(to view: UIView,
                            top: CGFloat = 0,
                            bottom: CGFloat = 0,
                            leading: CGFloat = 0,
                            trailing: CGFloat = 0) {
        owningView = view
        topInset = top
        bottomInset = bottom
        leadingInset = leading
        trailingInset = trailing
    }
    
    public var layoutFrame: CGRect {
        guard let view = owningView else { return .zero }
        return CGRect(
            x: view.bounds.origin.x + leadingInset,
            y: view.bounds.origin.y + topInset,
            width: view.bounds.width - leadingInset - trailingInset,
            height: view.bounds.height - topInset - bottomInset
        )
    }
    
    // Anchors use your existing Anchor backport
    public var topAnchor: Anchor { Anchor(view: owningView!, attribute: .top) }
    public var bottomAnchor: Anchor { Anchor(view: owningView!, attribute: .bottom) }
    public var leadingAnchor: Anchor { Anchor(view: owningView!, attribute: .leading) }
    public var trailingAnchor: Anchor { Anchor(view: owningView!, attribute: .trailing) }
    public var leftAnchor: Anchor { Anchor(view: owningView!, attribute: .left) }
    public var rightAnchor: Anchor { Anchor(view: owningView!, attribute: .right) }
    public var widthAnchor: Anchor { Anchor(view: owningView!, attribute: .width) }
    public var heightAnchor: Anchor { Anchor(view: owningView!, attribute: .height) }
    public var centerXAnchor: Anchor { Anchor(view: owningView!, attribute: .centerX) }
    public var centerYAnchor: Anchor { Anchor(view: owningView!, attribute: .centerY) }
}

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public typealias UILayoutGuide = UILayoutGuideShim

// MARK: - UIView extension for layout guides
private var layoutGuidesKey: UInt8 = 0
private var layoutMarginsGuideKey: UInt8 = 0
private var safeAreaGuideKey: UInt8 = 0

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension UIView {
    func addLayoutGuide(_ guide: UILayoutGuideShim) {
        var guides = objc_getAssociatedObject(self, &layoutGuidesKey) as? [UILayoutGuide] ?? []
        guides.append(guide)
        objc_setAssociatedObject(self, &layoutGuidesKey, guides, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    var layoutGuides: [UILayoutGuide] {
        get { objc_getAssociatedObject(self, &layoutGuidesKey) as? [UILayoutGuide] ?? [] }
        set { objc_setAssociatedObject(self, &layoutGuidesKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // Layout margins guide
    var layoutMarginsGuide: UILayoutGuide {
        if let guide = objc_getAssociatedObject(self, &layoutMarginsGuideKey) as? UILayoutGuide { return guide }
        let guide = UILayoutGuide()
        guide.attach(to: self,
                     top: layoutMargins.top,
                     bottom: layoutMargins.bottom,
                     leading: layoutMargins.left,
                     trailing: layoutMargins.right)
        addLayoutGuide(guide)
        objc_setAssociatedObject(self, &layoutMarginsGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
    
    // Safe area guide
    var safeAreaLayoutGuide: UILayoutGuide {
        if let guide = objc_getAssociatedObject(self, &safeAreaGuideKey) as? UILayoutGuide { return guide }
        let guide = UILayoutGuide()
        var topInset: CGFloat = layoutMargins.top
        var bottomInset: CGFloat = layoutMargins.bottom
        if let vc = sequence(first: self.next, next: { $0?.next }).compactMap({ $0 as? UIViewController }).first {
            topInset += vc.topLayoutGuide.length
            bottomInset += vc.bottomLayoutGuide.length
        }
        guide.attach(to: self,
                     top: topInset,
                     bottom: bottomInset,
                     leading: layoutMargins.left,
                     trailing: layoutMargins.right)
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
        let guide = UILayoutSupportShim(length: 20) // default status bar height
        objc_setAssociatedObject(self, &topGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
    
    var bottomLayoutGuide: UILayoutSupportShim {
        if let guide = objc_getAssociatedObject(self, &bottomGuideKey) as? UILayoutSupportShim { return guide }
        let guide = UILayoutSupportShim(length: 0) // default bottom
        objc_setAssociatedObject(self, &bottomGuideKey, guide, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return guide
    }
}
