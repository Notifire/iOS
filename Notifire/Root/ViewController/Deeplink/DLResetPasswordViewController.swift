//
//  DLResetPasswordViewController.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class DLResetPasswordViewController: DeeplinkedVMViewController<DLResetPasswordViewModel>, CenterStackViewPresenting, APIErrorResponding, APIErrorPresenting, UserErrorResponding, KeyboardFollowingButtonContaining {

    // MARK: - Properties
    lazy var textFieldReturnChainer = TextFieldReturnChainer(textField: newPasswordTextInput.textField)

    // MARK: KeyboardObserving
    let keyboardObserverHandler = KeyboardObserverHandler()

    // MARK: UI
    lazy var headerLabel: UILabel = {
        let label = UILabel(style: .title)
        label.text = viewModel.headerText
        label.textAlignment = .left
        return label
    }()

    lazy var newPasswordTextInput = ValidatableTextInput.createPasswordTextInput(
        textFieldType: BorderedTextField.self,
        newPasswordTextContentType: true,
        placeholderText: viewModel.placeholderText,
        rules: ComponentRule.passwordRules,
        viewModel: viewModel,
        bindableKeyPath: \.newPassword
    )

    lazy var confirmButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle(viewModel.confirmText, for: .normal)
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

    // MARK: - UserErrorPresenting
    func dismissCompletion(error: EmailTokenError) {
        delegate?.shouldCloseDeeplink()
    }
}
