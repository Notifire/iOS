//
//  BorderedTextField.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// UITextField used for more important inputs that are the main part of the screen or that should be distinguished.
/// - Note: For normal input purposes use `BottomBarTextField`.
class BorderedTextField: CustomTextField {

    // MARK: - Inherited
    override open func setup() {
        layer.cornerRadius = Theme.defaultCornerRadius
        backgroundColor = .compatibleTextField
    }

    override open func set(new appearance: Appearance, animated: Bool = false) {
        super.set(new: appearance, animated: animated)
        // FIXME: Animated ?
        switch appearance {
        case .neutral:
            layer.borderWidth = 1
            layer.borderColor = UIColor.compatibleTextFieldBorder.cgColor
        case .positive:
            layer.borderWidth = 1
            layer.borderColor = UIColor.compatibleGreen.cgColor
        case .negative:
            layer.borderWidth = 1
            layer.borderColor = UIColor.compatibleRed.cgColor
        }
    }
}
