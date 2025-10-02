import UIKit

// MARK: - Internal Anchor Backport (safe names)
@available(iOS, introduced: 6.0, obsoleted: 9.0)
class Anchor {
    weak var view: UIView?
    let attribute: NSLayoutConstraint.Attribute
    
    init(view: UIView, attribute: NSLayoutConstraint.Attribute) {
        self.view = view
        self.attribute = attribute
    }
    
    func constraint(equalTo other: Anchor, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: view!,
            attribute: attribute,
            relatedBy: .equal,
            toItem: other.view,
            attribute: other.attribute,
            multiplier: multiplier,
            constant: constant
        )
    }
    
    func constraint(equalToConstant constant: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(
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
extension UIView {
    var leadingAnchor: Anchor { return Anchor(view: self, attribute: .leading) }
    var trailingAnchor: Anchor { return Anchor(view: self, attribute: .trailing) }
    var topAnchor: Anchor { return Anchor(view: self, attribute: .top) }
    var bottomAnchor: Anchor { return Anchor(view: self, attribute: .bottom) }
    var widthAnchor: Anchor { return Anchor(view: self, attribute: .width) }
    var heightAnchor: Anchor { return Anchor(view: self, attribute: .height) }
    var centerXAnchor: Anchor { return Anchor(view: self, attribute: .centerX) }
    var centerYAnchor: Anchor { return Anchor(view: self, attribute: .centerY) }
}

// MARK: - NSLayoutConstraint isActive Backport
private let activeConstraints: NSHashTable = NSHashTable<AnyObject>(options: .weakMemory)

@available(iOS, introduced: 6.0, obsoleted: 9.0)
extension NSLayoutConstraint {
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
    
    // MARK: - Activate / Deactivate multiple constraints
    static func activate(constraints: [NSLayoutConstraint]) {
        for c in constraints { c.isActive = true }
    }
    
    static func deactivate(constraints: [NSLayoutConstraint]) {
        for c in constraints { c.isActive = false }
    }
}


