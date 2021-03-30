//
//  CustomTextField.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

/// Base class for customizable text fields that work with component validator.
class CustomTextField: UITextField {

    // MARK: Appearance
    enum Appearance {
        case neutral
        case negative
        case positive
        case loading
    }

    // MARK: - Properties
    static let padding = UIEdgeInsets(top: 0, left: Theme.defaultCornerRadius*2, bottom: 0, right: Theme.defaultCornerRadius*4)

    /// The text input that is the parent of this textfield.
    weak var parentValidatableTextInput: ValidatableTextInput?

    // MARK: Private
    var lastAppearance: Appearance?

    // MARK: - Inherited
    required init() {
        super.init(frame: .zero)
        privateSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        privateSetup()
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

    // MARK: Dark Mode
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                guard let lastAppearance = lastAppearance else { return }
                set(new: lastAppearance)
            }
        }
    }

    // MARK: 'Return' key enabled
    override var hasText: Bool {
        return parentValidatableTextInput?.isValid ?? super.hasText
    }

    // MARK: - Private
    private func privateSetup() {
        enablesReturnKeyAutomatically = true
        translatesAutoresizingMaskIntoConstraints = false
        clearButtonMode = .whileEditing
        autocapitalizationType = .none
        inputAssistantItem.leadingBarButtonGroups = []
        inputAssistantItem.trailingBarButtonGroups = []
        autocorrectionType = .no

        // colors
        textColor = .compatibleLabel
        tintColor = .primary

        setup()

        set(new: .neutral)
    }

    // MARK: - Public
    public func setPlaceholder(text: String) {
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: Size.Font.placeholder),
            NSAttributedString.Key.foregroundColor: UIColor.compatibleTertiaryLabel
        ]
        attributedPlaceholder = NSAttributedString(string: text, attributes: attributes)
    }

    /// Sets a new appearance for the TextField.
    /// - Note: also saves the previous appearance
    open func set(new appearance: Appearance, animated: Bool = false) {
        lastAppearance = appearance

    }

    /// Override this function to provide custom setup.
    open func setup() {}
}
