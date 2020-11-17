//
//  BottomBarTextField.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// UITextField used for generic inputs.
class BottomBarTextField: CustomTextField {

    // MARK: - Properties
    var bottomLineLayer: CALayer?

    // MARK: - Inherited
    override open func setup() {
        // Remove borders
        borderStyle = .none

        // Add bottom line
        let bottomLine = CALayer()
        self.bottomLineLayer = bottomLine
        layer.addSublayer(bottomLine)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let bottomLine = bottomLineLayer {
            let height = HairlineView.minimalHeight
            bottomLine.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
        }
    }

    override open func set(new appearance: Appearance, animated: Bool = false) {
        super.set(new: appearance, animated: animated)

        switch appearance {
        case .neutral:
            bottomLineLayer?.backgroundColor = UIColor.compatibleTextFieldBorder.cgColor
        case .positive:
            bottomLineLayer?.backgroundColor = UIColor.compatibleGreen.cgColor
        case .negative:
            bottomLineLayer?.backgroundColor = UIColor.compatibleRed.cgColor
        }
    }
}
