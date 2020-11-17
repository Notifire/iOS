//
//  RegisterViewController.swift
//  Notifire
//
//  Created by David Bielik on 28/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol RegisterViewControllerDelegate: class {
    func shouldFinishRegistration()
    func didRegisterSuccessfully()
}

class RegisterViewController: VMViewController<RegisterViewModel>, BottomNavigatorLabelContaining, CenterStackViewPresenting, APIErrorResponding, APIErrorPresenting {

    // MARK: - Properties
    weak var delegate: RegisterViewControllerDelegate?

    // MARK: UI
    lazy var textFieldReturnChainer = TextFieldReturnChainer(textFields: [emailTextInput.textField, passwordTextInput.textField])

    let signUpButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Sign up", for: .normal)
        return button
    }()

    lazy var emailTextInput: ValidatableTextInput = {
        let textField = BorderedTextField()
        textField.keyboardType = .emailAddress
        textField.setPlaceholder(text: "Enter your email")
        let input = ValidatableTextInput(textField: textField)
        input.rules = ComponentRule.createEmailRules
        input.showsValidState = true
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.email)
        return input
    }()

    lazy var passwordTextInput = ValidatableTextInput.createPasswordTextInput(
        textFieldType: BorderedTextField.self,
        newPasswordTextContentType: true,
        placeholderText: "Password",
        viewModel: viewModel,
        bindableKeyPath: \.password
    )

    // MARK: BottomNavigatorLabelContaining
    lazy var bottomNavigator: UIView = defaultBottomNavigatorView()
    lazy var bottomNavigatorLabel: UILabel = {
        let label = TappableLabel()
        label.set(style: .primary)
        let hyperText = "Sign in"
        let text = "Already using Notifire? \(hyperText)."
        label.set(hypertext: hyperText, in: text)
        label.onHypertextTapped = { [weak self] in
            self?.delegate?.shouldFinishRegistration()
        }
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"
        view.backgroundColor = .compatibleSystemBackground

        setupSubviews()
        setupUserEvents()
        prepareViewModel()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.password = ""
        viewModel.email = ""
        emailTextInput.updateText(with: viewModel.email)
        passwordTextInput.updateText(with: viewModel.password)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextInput.textField.becomeFirstResponder()
    }

    // MARK: - Private
    private func setupSubviews() {
        addBottomNavigator()
        addBottomNavigatorLabel()

        // textfields
        let stackView = insertStackView(arrangedSubviews: [emailTextInput, passwordTextInput, signUpButton], spacing: Size.textFieldSpacing)
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing*3).isActive = true

    }

    private func setupUserEvents() {
        addKeyboardDismissOnTap(to: view)

        textFieldReturnChainer.onFinalReturn = { [weak self] in
            self?.dismissKeyboard()
            self?.viewModel.register()
        }

        signUpButton.onProperTap = { [unowned self] _ in // unowned when we are tapping
            self.dismissKeyboard()
            self.viewModel.register()
        }
    }

    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [emailTextInput, passwordTextInput])

        // viewModel
        viewModel.afterValidation = { [weak self] success in
            self?.signUpButton.isEnabled = success
        }
        viewModel.onLoadingChange = { [weak self] loading in
            if loading {
                self?.dismissKeyboard()
                self?.emailTextInput.textField.isEnabled = false
                self?.passwordTextInput.textField.isEnabled = false
                self?.signUpButton.startLoading()
            } else {
                self?.emailTextInput.textField.isEnabled = true
                self?.passwordTextInput.textField.isEnabled = true
                self?.signUpButton.stopLoading()
            }
        }
        viewModel.onRegister = { [weak self] in
            self?.delegate?.didRegisterSuccessfully()
        }

        setViewModelOnError()
    }

    // MARK: - Event Handlers
    // MARK: TextField
    @objc func didStopEditing(textField: UITextField) {
        if textField == emailTextInput.textField {
            passwordTextInput.textField.becomeFirstResponder()
        } else {
            _ = passwordTextInput.textField.resignFirstResponder()
        }
    }
}
