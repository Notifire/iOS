//
//  CustomTextField.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class CustomTextField: UITextField {

    // MARK: LayerAppearance
    enum LayerAppearance {
        case neutral
        case negative
        case positive
    }

    // MARK: - Properties
    static let padding = UIEdgeInsets(top: 0, left: Theme.defaultCornerRadius*2, bottom: 0, right: Theme.defaultCornerRadius*4)

    // MARK: - Inherited
    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func resignFirstResponder() -> Bool {
        let resigned = super.resignFirstResponder()
        layoutIfNeeded()
        return resigned
    }

    // MARK: Sizing
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Size.componentHeight)
    }

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: CustomTextField.padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: CustomTextField.padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: CustomTextField.padding)
    }

    // MARK: - Private
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = Theme.defaultCornerRadius
        clearButtonMode = .whileEditing
        autocapitalizationType = .none

        // colors
        backgroundColor = .textFieldBackgroundColor
        tintColor = .notifireMainColor

        setLayer(appearance: .neutral)
    }

    // MARK: - Public
    public func setPlaceholder(text: String) {
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]
        attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }

    public func setLayer(appearance: LayerAppearance) {
        switch appearance {
        case .neutral:
            layer.borderWidth = 1
            layer.borderColor = UIColor.textFieldBorderColor.cgColor
        case .positive:
            layer.borderWidth = 1
            layer.borderColor = UIColor.green.cgColor
        case .negative:
            layer.borderWidth = 1
            layer.borderColor = UIColor.red.cgColor
        }
    }
}
