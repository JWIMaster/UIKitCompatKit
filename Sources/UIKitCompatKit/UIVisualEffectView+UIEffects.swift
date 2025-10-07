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
public class UIVisualEffectView: UIView {
    public let contentView = UIView()
    private var effect: UIBlurEffect?
    private let overlay = UIImageView()
    private var displayLink: CADisplayLink?
    private var DeviceInfoClass = DeviceInfo()
    var device: ChipsetClass {
        return DeviceInfoClass.chipsetClass()
    }
    private var captureScale: CGFloat {
        switch device {
        case .a4:
            return 0.1
        case .a5:
            return 0.2
        case .a6:
            return 0.25
        case .a7_a8:
            return 0.4
        case .a9Plus:
            return 0.6
        case .a12Plus:
            return 1
        case .unknown:
            return 0.3
        }
    }
    
    
    
    public init() {
        super.init(frame: .zero)
    }

    public init(effect: UIBlurEffect) {
        self.effect = effect
        super.init(frame: .zero)
        setup()
        startDisplayLink()
    }
    

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        clipsToBounds = true
        overlay.frame = bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(overlay)

        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)
    }

    private func startDisplayLink() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateBlur))
        displayLink?.add(to: .main, forMode: .common)
    }

    @objc private func updateBlur() {
        guard let superview = superview else { return }
        isHidden = true

        // Downscale for performance
        let scale: CGFloat = {
            if effect!.chosenCaptureScale == 0 {
                return captureScale
            } else {
                return effect!.chosenCaptureScale
            }
        }()
        let blurRadius = effect!.radius*scale
        print(blurRadius)
        let scaledSize = CGSize(width: bounds.width * scale, height: bounds.height * scale)
        UIGraphicsBeginImageContextWithOptions(scaledSize, false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.scaleBy(x: scale, y: scale)
        ctx.translateBy(x: -frame.origin.x, y: -frame.origin.y)
        superview.layer.render(in: ctx)
        guard let snapshot = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            isHidden = false
            return
        }
        UIGraphicsEndImageContext()
        isHidden = false

        // GPUImage blur + vibrancy
        let picture = GPUImagePicture(image: snapshot)!
        let blur = GPUImageGaussianBlurFilter()
        blur.blurRadiusInPixels = CGFloat(Float(blurRadius))
        let saturation = GPUImageSaturationFilter()
        saturation.saturation = effect!.vibrancy
        
        overlay.image = saturation.imageFromCurrentFramebuffer()
        applyLightOverlay()
        

        picture.addTarget(blur)
        blur.addTarget(saturation)
        saturation.useNextFrameForImageCapture()
        picture.processImage()

        overlay.image = saturation.imageFromCurrentFramebuffer()

        picture.removeAllTargets()
        blur.removeAllTargets()
        saturation.removeAllTargets()
    }
    
    
    private func applyLightOverlay() {
        guard let style = effect?.style else { return }

        // Remove existing overlay layer if any
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


    deinit { displayLink?.invalidate() }
}




