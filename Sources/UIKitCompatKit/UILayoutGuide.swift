import UIKit

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public class UILayoutGuideShim {
    private weak var owningView: UIView?
    private let proxyView: UIView

    public init() {
        proxyView = UIView()
        proxyView.translatesAutoresizingMaskIntoConstraints = false
        proxyView.isHidden = true
    }

    public func attach(to view: UIView) {
        owningView = view
        view.addSubview(proxyView)
        // No default width/height — size comes entirely from constraints
    }

    // MARK: - Anchors (already your Anchor type)
    public var leadingAnchor: Anchor { proxyView.leadingAnchor }
    public var trailingAnchor: Anchor { proxyView.trailingAnchor }
    public var topAnchor: Anchor { proxyView.topAnchor }
    public var bottomAnchor: Anchor { proxyView.bottomAnchor }
    public var widthAnchor: Anchor { proxyView.widthAnchor }
    public var heightAnchor: Anchor { proxyView.heightAnchor }
    public var centerXAnchor: Anchor { proxyView.centerXAnchor }
    public var centerYAnchor: Anchor { proxyView.centerYAnchor }
}

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public typealias UILayoutGuide = UILayoutGuideShim

@available(iOS, introduced: 6.0, obsoleted: 9.0)
public extension UIView {
    func addLayoutGuide(_ guide: UILayoutGuideShim) {
        guide.attach(to: self)
    }
}
