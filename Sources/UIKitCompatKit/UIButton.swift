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

@available(iOS, introduced: 6.0, deprecated: 14.0)
public extension UIButton {
    private struct AssociatedKeys {
        static var sleeves = "closureSleeves"
    }

    func addAction(for controlEvents: UIControl.Event, _ closure: @escaping () -> Void) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents)

        // Keep all sleeves alive
        var sleeves = objc_getAssociatedObject(self, &AssociatedKeys.sleeves) as? NSMutableArray
        if sleeves == nil {
            sleeves = NSMutableArray()
            objc_setAssociatedObject(self, &AssociatedKeys.sleeves, sleeves, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        sleeves?.add(sleeve)
    }
    
    
    func removeAllActions() {
        self.removeTarget(nil, action: nil, for: .allEvents)

        // Clear all stored sleeves
        if let sleeves = objc_getAssociatedObject(self, &UIButton.AssociatedKeys.sleeves) as? NSMutableArray {
            sleeves.removeAllObjects()
        }
    }
}

