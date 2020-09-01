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

class RegisterViewController: BottomNavigatorViewController, CenterStackViewPresenting {

    // MARK: - Properties
    let viewModel: RegisterViewModel
    weak var delegate: RegisterViewControllerDelegate?

    // MARK: Views
    let usernameTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.setPlaceholder(text: "Enter your username")
        return textField
    }()

    let emailTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.setPlaceholder(text: "Enter your email")
        return textField
    }()

    let passwordTextField: CustomTextField = {
        let textField = CustomTextField()
        textField.isSecureTextEntry = true
        textField.setPlaceholder(text: "Password")
        return textField
    }()

    let signUpButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Sign up", for: .normal)
        return button
    }()

    lazy var usernameTextInput: ValidatableTextInput = {
        let input = ValidatableTextInput(textField: usernameTextField)
        input.rules = [
            ComponentRule(
                kind: .minimum(length: Settings.Text.minimumUsernameLength),
                showIfBroken: false
            ),
            ComponentRule(kind: .maximum(length: Settings.Text.maximumUsernameLength), showIfBroken: true),
            ComponentRule(kind: .validity(.username), showIfBroken: true)
        ]
        input.showsValidState = true
        return input
    }()

    lazy var emailTextInput: ValidatableTextInput = {
        let input = ValidatableTextInput(textField: emailTextField)
        input.rules = [
            ComponentRule(kind: .minimum(length: 1), showIfBroken: false),
            ComponentRule(kind: .maximum(length: Settings.Text.maximumUsernameLength), showIfBroken: true),
            ComponentRule(kind: .validity(.email), showIfBroken: true)
        ]
        input.showsValidState = true
        return input
    }()

    lazy var passwordTextInput: ValidatableTextInput = {
        let input = ValidatableTextInput(textField: passwordTextField)
        input.rules = [
            ComponentRule(kind: .minimum(length: 5), showIfBroken: false),
            ComponentRule(kind: .maximum(length: Settings.Text.maximumPasswordLength), showIfBroken: true)
        ]
        return input
    }()

    // MARK: - Initialization
    init(viewModel: RegisterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.createComponentValidator(with: [usernameTextInput, emailTextInput, passwordTextInput])
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Register"

        // gestures
        addKeyboardDismissOnTap(to: view)
        let textFields = [usernameTextField, emailTextField, passwordTextField]
        textFields.forEach {
            $0.addTarget(self, action: #selector(didChange(textField:)), for: .editingChanged)
            $0.addTarget(self, action: #selector(didStopEditing(textField:)), for: .editingDidEndOnExit)
        }
        // viewModel
        viewModel.afterValidation = { [weak self] success in
            self?.signUpButton.isEnabled = success
        }

        signUpButton.onProperTap = { [unowned self] in // unowned when we are tapping
            self.signUpButton.startLoading()
            self.dismissKeyboard()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in // weak, because the vc might get dismissed
                self?.viewModel.register { result in
                    self?.signUpButton.stopLoading()
                    switch result {
                    case .success:
                        self?.delegate?.didRegisterSuccessfully()
                    case .failed:
                        let alert = UIAlertController(title: "Registration error", message: "Something went wrong. Please try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        self?.present(alert, animated: true, completion: nil)
                    case .serverError:
                        let alert = UIAlertController(title: "Server error", message: "Something went wrong. Please try again later.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        self?.present(alert, animated: true, completion: nil)
                    case .networkError:
                        let alert = UIAlertController(title: "Network error", message: "Please check your network connection and try again.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { _ in
                            alert.dismiss(animated: true, completion: nil)
                        }))
                        self?.present(alert, animated: true, completion: nil)
                    }
                }
            }

        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        usernameTextField.text = ""
        emailTextField.text = ""
        passwordTextField.text = ""
        didChange(textField: usernameTextField)
        didChange(textField: emailTextField)
        didChange(textField: passwordTextField)
        viewModel.username = ""
        viewModel.password = ""
        viewModel.email = ""
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        usernameTextField.becomeFirstResponder()
    }

    // MARK: - Inherited
    override func setupSubviews() {
        super.setupSubviews()

        // textfields
        let stackView = insertStackView(arrangedSubviews: [usernameTextInput, emailTextInput, passwordTextInput, signUpButton], spacing: Size.textFieldSpacing)
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing*3).isActive = true

        tappableLabel.setLinked(text: "Already using Notifire? Sign in.", link: "Sign in")
    }

    // MARK: - Event Handlers
    override func didTapTappableLabel() {
        delegate?.shouldFinishRegistration()
    }

    // MARK: TextField
    @objc func didChange(textField: UITextField) {
        let componentToValidate: ValidatableTextInput
        if textField == usernameTextField {
            viewModel.username = usernameTextInput.validatableInput
            componentToValidate = usernameTextInput
        } else if textField == emailTextField {
            viewModel.email = emailTextInput.validatableInput
            componentToValidate = emailTextInput
        } else {
            viewModel.password = passwordTextInput.validatableInput
            componentToValidate = passwordTextInput
        }
        viewModel.validate(component: componentToValidate)
    }

    @objc func didStopEditing(textField: UITextField) {
        if textField == usernameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            _ = passwordTextField.resignFirstResponder()
        }
    }
}
