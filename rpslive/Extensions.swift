//
//  Extensions.swift
//  rpslive
//
//  Created by Ömer Faruk KISIK on 22.01.2022.
//

import SwiftUI
import UIKit
import AudioToolbox

extension UIDevice {
    static func vibrate() {
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    }
}

extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
}

