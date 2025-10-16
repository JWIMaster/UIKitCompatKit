import UIKit
import GPUImage1Swift

// MARK: - GPUBlurEffect (like UIBlurEffect)
@available(iOS, introduced: 6.0, obsoleted: 8.0)
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
        case .regular:
            self.radius = 50
            self.vibrancy = 1.7
        case .dark:
            self.radius = 25
            self.vibrancy = 1.05
        }
        self.chosenCaptureScale = chosenCaptureScale
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
    
    // MARK: - Public properties
    public let contentView = UIView()
    public var effect: UIBlurEffect?
    public let overlay = UIImageView()
    
    private var displayLink: CADisplayLink?
    private var DeviceInfoClass = DeviceInfo()
    
    var device: ChipsetClass {
        return DeviceInfoClass.chipsetClass()
    }
    
    private var captureScale: CGFloat {
        switch device {
        case .a4: return 0.1
        case .a5: return 0.15
        case .a6: return 0.2
        case .a7_a8: return 0.3
        case .a9Plus: return 0.4
        case .a12Plus: return 1
        case .unknown: return 0.3
        }
    }
    
    // MARK: - Shared snapshot per frame
    private static var sharedSnapshot: UIImage?
    private static var lastFrameTime: TimeInterval = 0
    
    // MARK: - Init
    public init() { super.init(frame: .zero) }
    
    public init(effect: UIBlurEffect) {
        self.effect = effect
        super.init(frame: .zero)
        setup()
        startDisplayLink()
    }

    required public init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Setup
    private func setup() {
        clipsToBounds = true
        overlay.frame = bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.layer.compositingFilter = "screenBlendMode"
        addSubview(overlay)
        
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }
    
    // MARK: - Display Link
    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateBlur))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    // MARK: - Update Blur
    @objc public func updateBlur() {
        guard let superview = superview, let effect = effect else { return }

        // Capture shared snapshot once per frame
        let currentTime = CACurrentMediaTime()
        if currentTime != UIVisualEffectView.lastFrameTime {
            
            isHidden = true // prevent capturing self
            
            let scale: CGFloat = effect.chosenCaptureScale == 0 ? captureScale : effect.chosenCaptureScale
            let scaledSize = CGSize(width: superview.bounds.width * scale, height: superview.bounds.height * scale)
            
            UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
            let ctx = UIGraphicsGetCurrentContext()!
            ctx.scaleBy(x: scale, y: scale)
            ctx.translateBy(x: -superview.frame.origin.x, y: -superview.frame.origin.y)
            superview.layer.render(in: ctx)
            UIVisualEffectView.sharedSnapshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            UIVisualEffectView.lastFrameTime = currentTime
            isHidden = false
        }
        
        guard let snapshot = UIVisualEffectView.sharedSnapshot else { return }
        
        // GPUImage blur + vibrancy
        let scale = effect.chosenCaptureScale == 0 ? captureScale : effect.chosenCaptureScale
        let blurRadius = effect.radius * scale
        
        let picture = GPUImagePicture(image: snapshot)!
        let blur = GPUImageGaussianBlurFilter()
        blur.blurRadiusInPixels = CGFloat(Float(blurRadius))
        let saturation = GPUImageSaturationFilter()
        saturation.saturation = effect.vibrancy
        
        blur.addTarget(saturation)
        saturation.useNextFrameForImageCapture()
        picture.addTarget(blur)
        picture.processImage()
        
        overlay.image = saturation.imageFromCurrentFramebuffer()
        
        picture.removeAllTargets()
        blur.removeAllTargets()
        saturation.removeAllTargets()
        
        applyLightOverlay()
    }
    
    // MARK: - Light Overlay
    private func applyLightOverlay() {
        guard let style = effect?.style else { return }

        overlay.layer.sublayers?.removeAll(where: { $0.name == "LightOverlay" })

        let overlayLayer = CALayer()
        overlayLayer.name = "LightOverlay"
        overlayLayer.frame = overlay.bounds

        switch style {
        case .light:
            overlayLayer.backgroundColor = UIColor(white: 1, alpha: 0.25).cgColor
        case .regular:
            overlayLayer.backgroundColor = UIColor(white: 1, alpha: 0.25).cgColor
        case .dark:
            overlayLayer.backgroundColor = UIColor.clear.cgColor
        }

        overlay.layer.addSublayer(overlayLayer)
    }
    
    deinit {
        displayLink?.invalidate()
    }
}
