//
//  ResetPasswordViewController.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class ResetPasswordViewController: DeeplinkedVMViewController<ResetPasswordViewModel>, CenterStackViewPresenting, APIErrorResponding, APIErrorPresenting, UserErrorResponding, KeyboardFollowingButtonContaining {

    // MARK: - Properties
    lazy var textFieldReturnChainer = TextFieldReturnChainer(textField: newPasswordTextInput.textField)

    // MARK: KeyboardObserving
    let keyboardObserverHandler = KeyboardObserverHandler()

    // MARK: UI
    let headerLabel: UILabel = {
        let label = UILabel(style: .title)
        label.text = "Reset your password"
        label.textAlignment = .left
        return label
    }()

    lazy var newPasswordTextInput = ValidatableTextInput.createPasswordTextInput(
        textFieldType: BorderedTextField.self,
        newPasswordTextContentType: true,
        placeholderText: "Enter a new password",
        rules: ComponentRule.passwordRules,
        viewModel: viewModel,
        bindableKeyPath: \.newPassword
    )

    lazy var confirmButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Change password", for: .normal)
        button.onProperTap = { [weak self] _ in
            self?.viewModel.resetPassword()
        }
        return button
    }()

    // MARK: - Initialization
    deinit {
        stopObservingNotifications()
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        textFieldReturnChainer.onFinalReturn = { [weak self] in
            self?.viewModel.resetPassword()
        }

        prepareViewModel()

        startObservingNotifications()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        newPasswordTextInput.textField.becomeFirstResponder()
    }

    // MARK: - Inherited
    override open func setupSubviews() {
        super.setupSubviews()

        let stackView = insertStackView(arrangedSubviews: [headerLabel, newPasswordTextInput])
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.doubleMargin).isActive = true

        addKeyboardFollowing(button: confirmButton)
    }

    // MARK: - Private
    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [newPasswordTextInput])

        viewModel.afterValidation = { [weak self] success in
            self?.confirmButton.isEnabled = success
        }

        viewModel.loadingModel.onLoadingChange = { [weak self] loading in
            self?.newPasswordTextInput.textField.isEnabled = !loading
            self?.navigationItem.leftBarButtonItem?.isEnabled = !loading
            if loading {
                self?.dismissKeyboard()
                self?.confirmButton.startLoading()
            } else {
                self?.confirmButton.stopLoading()
            }
        }

        setViewModelOnError()
        setViewModelOnUserError()
    }
}
