import UIKit

// MARK: - Internal Anchor Backport (safe names)
class JAnchor {
    weak var view: UIView?
    let attribute: NSLayoutAttribute
    
    init(view: UIView, attribute: NSLayoutAttribute) {
        self.view = view
        self.attribute = attribute
    }
    
    func constraint(equalTo other: JAnchor, multiplier: CGFloat = 1.0, constant: CGFloat = 0) -> NSLayoutConstraint {
        return NSLayoutConstraint(
            item: view!,
            attribute: attribute,
            relatedBy: .Equal,
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
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: constant
        )
    }
}

// MARK: - UIView extension using safe internal anchors
extension UIView {
    var jLeadingAnchor: JAnchor { return JAnchor(view: self, attribute: .Leading) }
    var jTrailingAnchor: JAnchor { return JAnchor(view: self, attribute: .Trailing) }
    var jTopAnchor: JAnchor { return JAnchor(view: self, attribute: .Top) }
    var jBottomAnchor: JAnchor { return JAnchor(view: self, attribute: .Bottom) }
    var jWidthAnchor: JAnchor { return JAnchor(view: self, attribute: .Width) }
    var jHeightAnchor: JAnchor { return JAnchor(view: self, attribute: .Height) }
    var jCenterXAnchor: JAnchor { return JAnchor(view: self, attribute: .CenterX) }
    var jCenterYAnchor: JAnchor { return JAnchor(view: self, attribute: .CenterY) }
}

// MARK: - NSLayoutConstraint isActive Backport
private let activeConstraints: NSHashTable = NSHashTable(options: .WeakMemory)

extension NSLayoutConstraint {
    var jIsActive: Bool {
        get {
            return activeConstraints.containsObject(self)
        }
        set {
            guard let firstView = firstItem as? UIView else { return }
            firstView.translatesAutoresizingMaskIntoConstraints = false
            if newValue {
                if let superview = firstView.superview where !superview.constraints.contains(self) {
                    superview.addConstraint(self)
                }
                activeConstraints.addObject(self)
            } else {
                if let superview = firstView.superview {
                    superview.removeConstraint(self)
                }
                activeConstraints.removeObject(self)
            }
        }
    }
    
    // MARK: - Activate / Deactivate multiple constraints
    static func activate(constraints: [NSLayoutConstraint]) {
        for c in constraints { c.jIsActive = true }
    }
    
    static func deactivate(constraints: [NSLayoutConstraint]) {
        for c in constraints { c.jIsActive = false }
    }
}

// MARK: - Typealiases / Modern-looking names
extension UIView {
    var leadingAnchor: JAnchor { return jLeadingAnchor }
    var trailingAnchor: JAnchor { return jTrailingAnchor }
    var topAnchor: JAnchor { return jTopAnchor }
    var bottomAnchor: JAnchor { return jBottomAnchor }
    var widthAnchor: JAnchor { return jWidthAnchor }
    var heightAnchor: JAnchor { return jHeightAnchor }
    var centerXAnchor: JAnchor { return jCenterXAnchor }
    var centerYAnchor: JAnchor { return jCenterYAnchor }
}
