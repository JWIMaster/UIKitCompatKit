import UIKit
@available(iOS, introduced: 6.0, obsoleted: 9.0)
public class Anchor {
    weak var view: UIView?
    let attribute: NSLayoutConstraint.Attribute
    
    public init(view: UIView?, attribute: NSLayoutConstraint.Attribute) {
        self.view = view
        self.attribute = attribute
    }
    
    public func constraint(equalTo other: Anchor,
                           multiplier: CGFloat = 1.0,
                           constant: CGFloat = 0) -> NSLayoutConstraint {
        let firstView = view ?? UIView() // temporary placeholder, used until isActive
        let constraint = NSLayoutConstraint(
            item: firstView,
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
        guard let firstView = view else {
            let constraint = NSLayoutConstraint(
                item: UIView(),
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
        let constraint = NSLayoutConstraint(
            item: firstView,
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

// MARK: - NSLayoutConstraint backport for isActive
private var firstAnchorKey: UInt8 = 0
private var secondAnchorKey: UInt8 = 0
private let activeConstraints = NSHashTable<AnyObject>.weakObjects()

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension NSLayoutConstraint {
    var firstAnchor: Anchor? {
        get { objc_getAssociatedObject(self, &firstAnchorKey) as? Anchor }
        set { objc_setAssociatedObject(self, &firstAnchorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var secondAnchor: Anchor? {
        get { objc_getAssociatedObject(self, &secondAnchorKey) as? Anchor }
        set { objc_setAssociatedObject(self, &secondAnchorKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    var isActive: Bool {
        get { activeConstraints.contains(self) }
        set {
            if newValue {
                guard let firstView = firstItem as? UIView else { return }
                firstView.translatesAutoresizingMaskIntoConstraints = false
                
                // Only add if superview exists
                if let superview = firstView.superview, !superview.constraints.contains(self) {
                    superview.addConstraint(self)
                    activeConstraints.add(self)
                } else {
                    // Defer adding until superview exists
                    DispatchQueue.main.async {
                        if let superview = firstView.superview, !superview.constraints.contains(self) {
                            superview.addConstraint(self)
                            activeConstraints.add(self)
                        }
                    }
                }
            } else {
                if let firstView = firstItem as? UIView, let superview = firstView.superview {
                    superview.removeConstraint(self)
                }
                activeConstraints.remove(self)
            }
        }
    }
    
    class func activate(_ constraints: [NSLayoutConstraint]) {
        for c in constraints { c.isActive = true }
    }
    
    class func deactivate(_ constraints: [NSLayoutConstraint]) {
        for c in constraints { c.isActive = false }
    }
}
