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
    static var greenColor: UIColor = .compatibleGreen
    static var redColor: UIColor = .compatibleLighterRedColor

    var bottomLineLayer: CALayer?

    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()

    // MARK: - Inherited
    override open func setup() {
        clearButtonMode = .never
        rightViewMode = .always
        // Remove borders
        borderStyle = .none

        // Add bottom line
        let bottomLine = CALayer()
        bottomLine.backgroundColor = UIColor.compatibleTextFieldBorder.cgColor
        self.bottomLineLayer = bottomLine

        layer.addSublayer(bottomLine)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        UIView.performWithoutAnimation {
            rightView?.frame = rightViewRect(forBounds: bounds)
        }

        if let bottomLine = bottomLineLayer {
            let height = HairlineView.minimalHeight
            bottomLine.frame = CGRect(x: 0, y: bounds.height - height, width: bounds.width, height: height)
        }
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        let text = textRect(forBounds: bounds)
        let origin = CGPoint(x: text.origin.x + text.width, y: 0)
        return CGRect(origin: origin, size: CGSize(width: CustomTextField.padding.right, height: bounds.height))
    }

    override open func set(new appearance: Appearance, animated: Bool = false) {
        let colorChangeClosure: (() -> Void) = { [weak self] in
            switch appearance {
            case .neutral, .loading, .positive:
                self?.textColor = UIColor.compatibleLabel
            case .negative:
                self?.textColor = Self.redColor
            }
        }
        if animated {
            UIView.animate(withDuration: 0.3, animations: colorChangeClosure)
        } else {
            colorChangeClosure()
        }

        guard lastAppearance != appearance else {
            super.set(new: appearance, animated: animated)
            return
        }

        let newRightView: UIView?
        switch appearance {
        case .neutral:
            newRightView = nil
        case .loading:
            newRightView = UIActivityIndicatorView.loadingIndicator
        case .positive:
            imageView.image = #imageLiteral(resourceName: "checkmark.circle.m").withRenderingMode(.alwaysTemplate)
            imageView.tintColor = Self.greenColor
            newRightView = imageView
        case .negative:
            imageView.image = #imageLiteral(resourceName: "exclamationmark.circle").withRenderingMode(.alwaysTemplate)
            imageView.tintColor = Self.redColor
            newRightView = imageView
        }

        if self.rightView == nil {
            // Empty rightView
            rightView = newRightView
            if animated {
                rightView?.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01)
                rightView?.alpha = 0
                UIView.animate(withDuration: 0.24) {
                    self.rightView?.alpha = 1
                    self.rightView?.transform = CGAffineTransform.identity
                }
            }
        } else {
            if newRightView == nil {
                if animated {
                    let currentRightView = rightView
                    UIView.animate(withDuration: 0.24, animations: {
                        currentRightView?.alpha = 0
                        currentRightView?.transform = CGAffineTransform.identity.scaledBy(x: 0.01, y: 0.01)
                    })
                }
                self.rightView = nil
            } else {
                rightView = newRightView
                rightView?.alpha = 1
                rightView?.transform = CGAffineTransform.identity
            }
        }
        super.set(new: appearance, animated: animated)
    }
}
