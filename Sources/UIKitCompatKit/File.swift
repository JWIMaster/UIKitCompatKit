import UIKit

// MARK: - Context Shim

@available(iOS, introduced: 6.0, obsoleted: 8.0, message: "Use UIViewControllerTransitionCoordinatorContext instead")
public protocol UIViewControllerTransitionCoordinatorContextShim {
    var isAnimated: Bool { get }
    var transitionDuration: TimeInterval { get }
    var targetTransform: CGAffineTransform { get }
}

// MARK: - Coordinator Shim

@available(iOS, introduced: 6.0, obsoleted: 8.0, message: "Use UIViewControllerTransitionCoordinator instead")
public protocol UIViewControllerTransitionCoordinatorShim: UIViewControllerTransitionCoordinatorContextShim {
    func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContextShim) -> Void)?,
                 completion: ((UIViewControllerTransitionCoordinatorContextShim) -> Void)?) -> Bool
}

// Dummy coordinator/context that mimics the real thing
final class DummyTransitionCoordinator: UIViewControllerTransitionCoordinatorShim {
    let isAnimated: Bool
    let transitionDuration: TimeInterval
    let targetTransform: CGAffineTransform

    init(animated: Bool = true,
         duration: TimeInterval = 0.25,
         transform: CGAffineTransform = .identity) {
        self.isAnimated = animated
        self.transitionDuration = duration
        self.targetTransform = transform
    }

    func animate(alongsideTransition animation: ((UIViewControllerTransitionCoordinatorContextShim) -> Void)?,
                 completion: ((UIViewControllerTransitionCoordinatorContextShim) -> Void)?) -> Bool {
        animation?(self)
        completion?(self)
        return true
    }
}

// MARK: - UIViewController Shim

extension UIViewController {

    /// Unified shim: on iOS 8+, system calls the real API.
    /// On iOS 6–7, this is triggered manually to match behaviour.
    public func viewWillTransition(to size: CGSize,
                                       with coordinator: UIViewControllerTransitionCoordinatorShim) {
        // subclasses override just like the real API
    }

    // Hook iOS 6/7 rotation callbacks and translate them
    public func willRotate(to toInterfaceOrientation: UIInterfaceOrientation,
                                  duration: TimeInterval) {

        // Work out the new size after rotation
        let newBounds = UIScreen.main.bounds
        let newSize: CGSize
        if toInterfaceOrientation.isPortrait {
            newSize = CGSize(width: newBounds.width, height: newBounds.height)
        } else {
            newSize = CGSize(width: newBounds.height, height: newBounds.width)
        }

        let dummy = DummyTransitionCoordinator(animated: true,
                                               duration: duration,
                                               transform: .identity)

        // Call our shimmed API
        self.viewWillTransition(to: newSize, with: dummy)
    }
}
