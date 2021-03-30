//
//  ValidatableTextInput.swift
//  Notifire
//
//  Created by David Bielik on 05/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ValidatableTextInput: ConstrainableView, ValidatableComponent {

    // MARK: - Properties
    private var maximumLength: Int?
    var validatingViewModelBinder: ValidatingViewModelBinder?

    // MARK: UI
    let textField: CustomTextField

    lazy var tooltipErrorLabel = TooltipErrorLabelView()

    var currentSpinner: UIActivityIndicatorView?

    // MARK: Constraint
    var errorLabelBottomConstraint: NSLayoutConstraint?
    var textFieldBottomConstraint: NSLayoutConstraint?

    // MARK: ValidatableComponent
    var showsValidState = false
    var rules: [ComponentRule] = [] {
        didSet {
            rules.forEach {
                if case .maximum(let ruleMaxLength) = $0.kind {
                    maximumLength = ruleMaxLength
                }
            }
        }
    }

    var validityState: ValidatableComponentState = .neutral {
        didSet {
            updateAppearance()
        }
    }

    var validatableInput: String = ""

    var neutralStateValid: Bool

    // MARK: - Initialization
    init(textField: CustomTextField? = nil, neutralStateValid: Bool = false) {
        if let safeTextField = textField {
            self.textField = safeTextField
        } else {
            self.textField = BorderedTextField()
        }
        self.neutralStateValid = neutralStateValid
        super.init()
        self.textField.delegate = self
        self.textField.parentValidatableTextInput = self
    }

    required init?(coder aDecoder: NSCoder) {
        self.textField = BorderedTextField()
        self.neutralStateValid = false
        super.init(coder: aDecoder)
    }

    // MARK: - Inherited
    override func setupSubviews() {
        clipsToBounds = true
        textField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)

        add(subview: tooltipErrorLabel)
        add(subview: textField)
        textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textField.heightAnchor.constraint(equalToConstant: Size.componentHeight).isActive = true
        let textFieldBottom = textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        textFieldBottom.isActive = true
        textFieldBottomConstraint = textFieldBottom

        tooltipErrorLabel.embedSides(in: textField)
        tooltipErrorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor).isActive = true

        let errorLabelBottom = tooltipErrorLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        errorLabelBottomConstraint = errorLabelBottom
    }

    // MARK: - Private
    private func updateAppearance() {
        let newAppearance: CustomTextField.Appearance?
        switch validityState {
        case .neutral:
            hideErrorLabel()
            newAppearance = .neutral
        case .validating:
            hideErrorLabel()
            newAppearance = .loading
        case .invalid(let rule):
            if rule.showIfBroken {
                showErrorLabel()
                tooltipErrorLabel.errorLabel.text = rule.brokenRuleDescription ?? rule.description
                newAppearance = .negative
            } else {
                hideErrorLabel()
                newAppearance = .neutral
            }
        case .valid:
            hideErrorLabel()

            // This is necessary to enable the return key after a delayed response from the API
            // Otherwise the UIKeyboard gets the textField.hasText property too soon (before the real value is relevant).
            if rules.contains(where: { $0.kind == ComponentRule.Kind.validity(.email) }) {
                textField.reloadInputViews()
            }

            newAppearance = showsValidState ? .positive : .neutral
        }
        if let appearance = newAppearance {
            self.textField.set(new: appearance, animated: true)
        }
    }

    private func showErrorLabel() {
        layoutIfNeeded()
        textFieldBottomConstraint?.isActive = false
        errorLabelBottomConstraint?.isActive = true
        tooltipErrorLabel.setNeedsDisplay()
        UIView.animate(withDuration: 0.24, delay: 0, options: [.beginFromCurrentState], animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }

    private func hideErrorLabel() {
        layoutIfNeeded()
        errorLabelBottomConstraint?.isActive = false
        textFieldBottomConstraint?.isActive = true
        tooltipErrorLabel.setNeedsDisplay()
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            self.superview?.layoutIfNeeded()
        }, completion: nil)
    }

    @objc private func didChangeTextField(textField: UITextField) {
        validatableInput = textField.text ?? ""
        validatingViewModelBinder?.updateKeyPathAndValidate(component: self)
    }

    // MARK: - Public
    /// This function updates the `text` property of the `UITextField` and triggers the component validation.
    public func updateText(with value: String) {
        textField.text = value
        validatableInput = value
        validatingViewModelBinder?.updateKeyPathAndValidate(component: self)
    }
}

extension ValidatableTextInput: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let allowedMaxLength = maximumLength, let currentText = textField.text else { return true }
        let newLength = currentText.count + string.count - range.length
        return newLength <= allowedMaxLength
    }
}

extension ValidatableTextInput {

    /// Create ValidatableTextInput for a password entry textfield.
    static func createPasswordTextInput<VM: InputValidatingViewModel>(textFieldType: CustomTextField.Type, newPasswordTextContentType: Bool, placeholderText: String, rules: [ComponentRule] = ComponentRule.passwordRules, viewModel: VM, bindableKeyPath: ReferenceWritableKeyPath<VM, String>) -> ValidatableTextInput {
        let textField = textFieldType.init()
        textField.setPlaceholder(text: placeholderText)
        if #available(iOS 12.0, *), newPasswordTextContentType {
            textField.textContentType = .newPassword
        } else {
            textField.textContentType = .password
        }
        textField.keyboardType = .default
        textField.isSecureTextEntry = true
        let input = ValidatableTextInput(textField: textField)
        input.rules = rules
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: bindableKeyPath)
        return input
    }
}
