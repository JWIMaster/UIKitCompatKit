//
//  File.swift
//  
//
//  Created by JWI on 4/10/2025.
//

import Foundation
import UIKit


private class ClosureSleeve {
    let closure: () -> Void
    init(_ closure: @escaping () -> Void) {
        self.closure = closure
    }
    @objc func invoke() { closure() }
}

@available(iOS, introduced: 6.0, obsoleted: 14.0)
public extension UIButton {
    func addAction(for controlEvents: UIControl.Event, _ closure: @escaping () -> Void) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)
        // Use NSUUID for unique key
        objc_setAssociatedObject(self, NSUUID().uuidString, sleeve, .OBJC_ASSOCIATION_RETAIN)
    }
}
