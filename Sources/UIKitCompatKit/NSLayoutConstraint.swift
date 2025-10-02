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
        NSLayoutConstraint(
            item: view!,
            attribute: attribute,
            relatedBy: .equal,
            toItem: other.view,
            attribute: other.attribute,
            multiplier: multiplier,
            constant: constant
        )
    }
    
    public func constraint(equalToConstant constant: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint(
            item: view!,
            attribute: attribute,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: constant
        )
    }
}

// MARK: - UIView extension using safe internal anchors
@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension UIView {
    var leadingAnchor: Anchor { Anchor(view: self, attribute: .leading) }
    var trailingAnchor: Anchor { Anchor(view: self, attribute: .trailing) }
    var topAnchor: Anchor { Anchor(view: self, attribute: .top) }
    var bottomAnchor: Anchor { Anchor(view: self, attribute: .bottom) }
    var widthAnchor: Anchor { Anchor(view: self, attribute: .width) }
    var heightAnchor: Anchor { Anchor(view: self, attribute: .height) }
    var centerXAnchor: Anchor { Anchor(view: self, attribute: .centerX) }
    var centerYAnchor: Anchor { Anchor(view: self, attribute: .centerY) }
    var cookywookywoo: Anchor { Anchor(view: self, attribute: .centerX) }
}

// MARK: - NSLayoutConstraint isActive Backport
private let activeConstraints: NSHashTable = NSHashTable<AnyObject>(options: .weakMemory)

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension NSLayoutConstraint {
    var isActive: Bool {
        get {
            return activeConstraints.contains(self)
        }
        set {
            guard let firstView = firstItem as? UIView else { return }
            firstView.translatesAutoresizingMaskIntoConstraints = false
            if newValue {
                if let superview = firstView.superview, !superview.constraints.contains(self) {
                    superview.addConstraint(self)
                }
                activeConstraints.add(self)
            } else {
                if let superview = firstView.superview {
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
    
    class func deactivate(_ constraints: [NSLayoutConstraint]) {
        for c in constraints { c.isActive = false }
    }
}
