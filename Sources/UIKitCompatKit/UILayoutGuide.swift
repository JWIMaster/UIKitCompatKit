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

public extension UIView {
    /// Mimics `addLayoutGuide(_:)` on iOS < 9 by attaching the UILayoutGuideShim's proxy view
    @available(iOS, introduced: 6.0, obsoleted: 9.0)
    func addLayoutGuide(_ guide: UILayoutGuideShim) {
        guide.attach(to: self)
    }
}

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public typealias UILayoutGuide = UILayoutGuideShim



