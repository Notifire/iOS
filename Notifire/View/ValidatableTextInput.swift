//
//  ValidatableTextInput.swift
//  Notifire
//
//  Created by David Bielik on 05/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol InputValidatingBindableEnum {}

protocol InputValidatingBindable {
    associatedtype EnumDescribingKeyPaths: InputValidatingBindableEnum
    func keyPath(for value: EnumDescribingKeyPaths) -> ReferenceWritableKeyPath<Self, String>
}

class ValidatingViewModelBinder {

    private let updateViewModelKeyPath: ((String, ValidatableComponent) -> Void)
    let willUpdateKeyPathValue: ((String) -> Void)?

    init<VM: InputValidatingViewModel & InputValidatingBindable>(viewModel: VM, for value: VM.EnumDescribingKeyPaths, onUpdate: ((String) -> Void)? = nil) {
        let keyPath = viewModel.keyPath(for: value)
        self.updateViewModelKeyPath = { string, component in
            viewModel[keyPath: keyPath] = string
            viewModel.validate(component: component)
        }
        self.willUpdateKeyPathValue = onUpdate
    }

    func updateKeyPathAndValidate(component: ValidatableComponent) {
        let string = component.validatableInput
        willUpdateKeyPathValue?(string)
        updateViewModelKeyPath(string, component)
    }
}

class ValidatableTextInput: ConstrainableView, ValidatableComponent, Loadable {

    // MARK: - Properties
    let textField: CustomTextField
    var errorLabel: UILabel?

    private var maximumLength: Int?
    var validatingViewModelBinder: ValidatingViewModelBinder?

    // MARK: Constraints
    var textFieldToViewBottomConstraint: NSLayoutConstraint!

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

    var validatableInput: String {
        return textField.text ?? textField.attributedText?.string ?? ""
    }

    // MARK: - Initialization
    init(textField: CustomTextField? = nil) {
        if let safeTextField = textField {
            self.textField = safeTextField
        } else {
            self.textField = CustomTextField()
        }
        super.init()
        self.textField.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        self.textField = CustomTextField()
        super.init(coder: aDecoder)
    }

    // MARK: - Inherited
    override func setupSubviews() {
        textField.addTarget(self, action: #selector(didChangeTextField), for: .editingChanged)

        add(subview: textField)
        textField.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        textField.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        textField.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textFieldToViewBottomConstraint = textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        textFieldToViewBottomConstraint.isActive = true
    }

    // MARK: - Private
    private func updateAppearance() {
        let newAppearance: CustomTextField.LayerAppearance?
        switch validityState {
        case .neutral:
            removeErrorLabel()
            removeSpinner()
            newAppearance = .neutral
        case .validating:
            addSmallSpinner()
            //layoutIfNeeded()
            newAppearance = nil
        case .invalid(let rule):
            removeSpinner()
            guard rule.showIfBroken else { return }
            let label = errorLabel ?? addErrorLabel()
            //layoutIfNeeded()
            setNeedsLayout()
            label.text = rule.brokenRuleDescription ?? rule.description
            newAppearance = .negative
        case .valid:
            removeErrorLabel()
            removeSpinner()
            newAppearance = showsValidState ? .positive : .neutral
        }
        if let appearance = newAppearance {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
                self.textField.setLayer(appearance: appearance)
            }, completion: nil)
        }
    }

    var errorLabelBottomConstraint: NSLayoutConstraint?

    private func addErrorLabel() -> UILabel {
        textFieldToViewBottomConstraint.isActive = false
        let label = UILabel(style: .negative)
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        label.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: Size.textFieldSpacing*0.75).isActive = true
        let bottomConstraint = label.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint.isActive = true
        errorLabelBottomConstraint = bottomConstraint
        label.leadingAnchor.constraint(equalTo: textField.leadingAnchor, constant: Size.smallMargin).isActive = true
        label.trailingAnchor.constraint(equalTo: textField.trailingAnchor, constant: Size.smallMargin).isActive = true
        let height = label.heightAnchor.constraint(equalToConstant: 0)
        height.priority = UILayoutPriority(rawValue: 980)
        height.isActive = true
        errorLabel = label
        self.layoutIfNeeded()
        height.isActive = false
        UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.layoutIfNeeded()
        }, completion: nil)
        return label
    }

    private func removeErrorLabel() {
        if let label = errorLabel {
            label.heightAnchor.constraint(equalToConstant: 0).isActive = true
            errorLabelBottomConstraint?.isActive = false
            textFieldToViewBottomConstraint.isActive = true
            UIView.animate(withDuration: 0.3, delay: 0, options: [.beginFromCurrentState], animations: {
                self.layoutIfNeeded()
            }, completion: ({ finished in
                guard finished else { return }
                label.removeFromSuperview()
                self.errorLabel = nil
            }))
        }
    }

    private func addSmallSpinner() {
        guard let spinner = startLoading() else { return }
        spinner.color = .spinnerColor
        spinner.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }

    private func removeSpinner() {
        stopLoading()
    }

    @objc private func didChangeTextField(textField: UITextField) {
        validatingViewModelBinder?.updateKeyPathAndValidate(component: self)
    }

    // MARK: - Public
    /// This function updates the `text` property of the `UITextField` and triggers the component validation.
    public func updateText(with value: String) {
        textField.text = value
        validatingViewModelBinder?.updateKeyPathAndValidate(component: self)
    }
}

extension ValidatableTextInput: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let allowedMaxLength = maximumLength, let currentText = textField.text else { return true }
        let newLength = currentText.count + string.count - range.length
        return newLength <= allowedMaxLength
    }

    // TODO: If this returns false, the textfield can't resignFirstResponder.
    // Use this to avoid hiding the keyboard in some VCs (e.g. ForgotPasswordViewController)
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        return false
//    }
}
