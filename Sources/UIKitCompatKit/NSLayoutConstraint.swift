import UIKit

// MARK: - Internal Anchor Backport (safe names)
@available(iOS, introduced: 6.0, obsoleted: 9.0)
public class Anchor {
    weak var view: UIView?
    let attribute: NSLayoutConstraint.Attribute
    
    public init(view: UIView, attribute: NSLayoutConstraint.Attribute) {
        self.view = view
        self.attribute = attribute
    }
    
    public func constraint(equalTo other: Anchor,
                           multiplier: CGFloat = 1.0,
                           constant: CGFloat = 0) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view!,
            attribute: attribute,
            relatedBy: .equal,
            toItem: other.view,
            attribute: other.attribute,
            multiplier: multiplier,
            constant: constant
        )
        constraint.firstAnchor = self
        constraint.secondAnchor = other
        return constraint
    }
    
    public func constraint(equalToConstant constant: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(
            item: view!,
            attribute: attribute,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: constant
        )
        constraint.firstAnchor = self
        constraint.secondAnchor = nil
        return constraint
    }
}

// MARK: - UIView extension using safe internal anchors
public extension UIView {
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var leadingAnchor: Anchor { Anchor(view: self, attribute: .leading) }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var trailingAnchor: Anchor { Anchor(view: self, attribute: .trailing) }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var topAnchor: Anchor { Anchor(view: self, attribute: .top) }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var bottomAnchor: Anchor { Anchor(view: self, attribute: .bottom) }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var widthAnchor: Anchor { Anchor(view: self, attribute: .width) }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var heightAnchor: Anchor { Anchor(view: self, attribute: .height) }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var centerXAnchor: Anchor { Anchor(view: self, attribute: .centerX) }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var centerYAnchor: Anchor { Anchor(view: self, attribute: .centerY) }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var leftAnchor: Anchor { Anchor(view: self, attribute: .left) }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var rightAnchor: Anchor { Anchor(view: self, attribute: .right) }
    
    @available(iOS, introduced: 1.0, deprecated: 2.0, message: "Beware. The cookywookywoo is a powerful string indeed. Use sparingly. (On a real note, this is just my package testing string since I replicate so many API's it's hard to tell who's implementation the app is choosing to use.")
    var cookywookywoo: String {
        "dingdongbingbong, bingbongdingdong"
    }
}

// MARK: - NSLayoutConstraint isActive Backport
private var firstAnchorKey: UInt8 = 0
private var secondAnchorKey: UInt8 = 0
private let activeConstraints: NSHashTable = NSHashTable<AnyObject>(options: .weakMemory)

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension NSLayoutConstraint {
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var firstAnchor: Anchor? {
        get { objc_getAssociatedObject(self, &firstAnchorKey) as? Anchor }
        set { objc_setAssociatedObject(self, &firstAnchorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var secondAnchor: Anchor? {
        get { objc_getAssociatedObject(self, &secondAnchorKey) as? Anchor }
        set { objc_setAssociatedObject(self, &secondAnchorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    var isActive: Bool {
        get { activeConstraints.contains(self) }
        set {
            guard let firstView = firstItem as? UIView else { return }
            firstView.translatesAutoresizingMaskIntoConstraints = false

            let toItemView = secondItem as? UIView

            if newValue {
                if toItemView == nil {
                    // Constant constraint — add to the view itself
                    if !firstView.constraints.contains(self) {
                        firstView.addConstraint(self)
                    }
                } else {
                    // Normal constraint — add to superview
                    if let superview = firstView.superview, !superview.constraints.contains(self) {
                        superview.addConstraint(self)
                    }
                }
                activeConstraints.add(self)
            } else {
                if toItemView == nil {
                    firstView.removeConstraint(self)
                } else if let superview = firstView.superview {
                    superview.removeConstraint(self)
                }
                activeConstraints.remove(self)
            }
        }
    }

    
    // MARK: - Correct signatures (match UIKit)
    
    @available(iOS, introduced: 6.0, obsoleted: 8.0)
    class func activate(_ constraints: [NSLayoutConstraint]) {
        for c in constraints { c.isActive = true }
    }
    
    @available(iOS, introduced: 6.0, obsoleted: 8.0)
    class func deactivate(_ constraints: [NSLayoutConstraint]) {
        for c in constraints { c.isActive = false }
    }
}
