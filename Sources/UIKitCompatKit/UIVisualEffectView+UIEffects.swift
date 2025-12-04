#if !targetEnvironment(macCatalyst)
#if !MODERN_BUILD
import UIKit
import LiveFrost

/// GPUBlurEffect (like UIBlurEffect)
@available(iOS, introduced: 6.0, deprecated: 8.0)
public class UIBlurEffect {
    public enum Style {
        case light
        case regular
        case dark
    }

    public let radius: CGFloat
    public let vibrancy: CGFloat
    public let style: Style?

    public let chosenCaptureScale: CGFloat
    
    public init(style: Style, chosenCaptureScale: CGFloat = 0) {
        self.style = style
        switch style {
        case .light:
            self.radius = 8
            self.vibrancy = 1.25
            self.chosenCaptureScale = chosenCaptureScale
        case .regular:
            self.radius = 50
            self.vibrancy = 1.7
            self.chosenCaptureScale = chosenCaptureScale
        case .dark:
            self.radius = 25
            self.vibrancy = 1.05
            self.chosenCaptureScale = chosenCaptureScale
        }
    }

    public init(blurRadius: CGFloat, vibrancy: CGFloat = 1.0, chosenCaptureScale: CGFloat = 0) {
        self.style = nil
        self.radius = blurRadius
        self.vibrancy = vibrancy
        self.chosenCaptureScale = chosenCaptureScale
    }
}

// MARK: - GPUVisualEffectView (like UIVisualEffectView)
@available(iOS, introduced: 6.0, obsoleted: 8.0)
open class UIVisualEffectView: UIView {
    public let contentView = UIView()
    public var effect: UIBlurEffect?
    private var DeviceInfoClass = DeviceInfo()
    var device: ChipsetClass {
        return DeviceInfoClass.chipsetClass()
    }
    private var captureScale: CGFloat {
        switch device {
        case .a4:
            return 0.1
        case .a5:
            return 0.15
        case .a6:
            return 0.2
        case .a7_a8:
            return 0.3
        case .a9Plus:
            return 0.4
        case .a12Plus:
            return 1
        case .unknown:
            return 0.3
        }
    }
    
    private let blurView = LFGlassView()
    
    
    public init() {
        super.init(frame: .zero)
    }

    public init(effect: UIBlurEffect) {
        self.effect = effect
        super.init(frame: .zero)
        setup()
    }
    

    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        if let effect = effect {
            blurView.blurRadius = effect.radius
        }
        blurView.scaleFactor = captureScale
        addSubview(blurView)

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        blurView.frame = bounds
    }

    
    override open func didMoveToWindow() {
        blurView.snapshotTargetView = self.parentViewController?.view
    }
    
    
    
}


fileprivate extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while let r = responder {
            if let vc = r as? UIViewController {
                return vc
            }
            responder = r.next
        }
        return nil
    }
}


#endif
#endif
