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
    public var effect: UIBlurEffect?
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

    @objc public func updateBlur() {
        guard let superview = superview, let effect = effect else { return }

        // hide this view so it does not appear in the snapshot
        isHidden = true

        // choose capture scale
        let scaleToUse: CGFloat = {
            if effect.chosenCaptureScale == 0 {
                return captureScale
            } else {
                return effect.chosenCaptureScale
            }
        }()

        // target snapshot size in pixels. We will create a context exactly this size and avoid extra context scaling
        let targetSize = CGSize(width: bounds.width * scaleToUse, height: bounds.height * scaleToUse)

        // compute blur radius to apply to downsampled image
        // effect.radius is in device points. When we downsample by scaleToUse, convert to pixels for the blur filter.
        let blurRadiusInPixels = max(0.0, effect.radius * scaleToUse)

        // Take the snapshot at the downsampled size
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0) // explicit scale of 1 for a pixel sized context
        guard let ctx = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            isHidden = false
            return
        }

        // translate so we capture the correct area of superview. Multiply translation by scaleToUse because
        // the context is in downsampled pixels
        ctx.translateBy(x: -frame.origin.x * scaleToUse, y: -frame.origin.y * scaleToUse)

        // render the superview layer into the downsampled context
        superview.layer.render(in: ctx)

        guard let snapshot = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            isHidden = false
            return
        }
        UIGraphicsEndImageContext()

        // restore visibility so view hierarchy is intact
        isHidden = false

        // GPUImage processing. Important sequence:
        // 1) Create picture from snapshot
        // 2) Configure filters
        // 3) Call useNextFrameForImageCapture on the final filter
        // 4) call processImage on the picture
        // 5) read final framebuffer into UIImage
        autoreleasepool {
            let picture = GPUImagePicture(image: snapshot)
            let blur = GPUImageGaussianBlurFilter()
            blur.blurRadiusInPixels = CGFloat(Float(blurRadiusInPixels))

            let saturation = GPUImageSaturationFilter()
            saturation.saturation = CGFloat(Float(effect.vibrancy))

            // build pipeline picture -> blur -> saturation
            picture?.addTarget(blur)
            blur.addTarget(saturation)

            // ask final filter to capture next frame, then process
            saturation.useNextFrameForImageCapture()
            picture?.processImage()

            // now grab final UIImage
            if let resultImage = saturation.imageFromCurrentFramebuffer() {
                // UI updates on main thread
                DispatchQueue.main.async {
                    self.overlay.image = resultImage
                    self.applyLightOverlay()
                }
            }

            // clean up targets
            picture?.removeAllTargets()
            blur.removeAllTargets()
            saturation.removeAllTargets()
        }
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




