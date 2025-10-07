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

    public init(style: Style) {
        self.style = style
        switch style {
        case .light:
            self.radius = 8
            self.vibrancy = 1.25
        case .regular:
            self.radius = 40
            self.vibrancy = 1.4
        case .dark:
            self.radius = 25
            self.vibrancy = 1.05
        }
    }

    public init(blurRadius: CGFloat, vibrancy: CGFloat = 1.0) {
        self.style = nil
        self.radius = blurRadius
        self.vibrancy = vibrancy
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
            return 0.2
        case .a5:
            return 0.3
        case .a6:
            return 0.4
        case .a7_a8:
            return 0.7
        case .a9Plus:
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
        let blurRadius = effect!.radius*captureScale
        print(blurRadius)
        guard let superview = superview else { return }
        isHidden = true

        // Downscale for performance
        let scale: CGFloat = captureScale
        let scaledSize = CGSize(width: bounds.width * captureScale, height: bounds.height * captureScale)
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

        picture.addTarget(blur)
        blur.addTarget(saturation)
        saturation.useNextFrameForImageCapture()
        picture.processImage()

        overlay.image = saturation.imageFromCurrentFramebuffer()

        picture.removeAllTargets()
        blur.removeAllTargets()
        saturation.removeAllTargets()
    }

    deinit { displayLink?.invalidate() }
}




