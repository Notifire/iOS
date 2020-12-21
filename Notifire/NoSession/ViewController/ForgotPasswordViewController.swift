//
//  ForgotPasswordViewController.swift
//  Notifire
//
//  Created by David Bielik on 04/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: VMViewController<ForgotPasswordViewModel>, NavigationBarDisplaying, APIErrorResponding, APIErrorPresenting, NotifireAlertPresenting, CenterStackViewPresenting, KeyboardFollowingButtonContaining {

    // MARK: - Properties
    lazy var textFieldReturnChainer = TextFieldReturnChainer(textField: emailTextInput.textField)

    // MARK: UI
    lazy var headerLabel = UILabel(style: .title, text: "Issues with logging in?", alignment: .left)

    lazy var emailTextInput: ValidatableTextInput = {
        let emailTextField = BorderedTextField()
        emailTextField.keyboardType = .emailAddress
        emailTextField.setPlaceholder(text: "Enter your e-mail")
        let input = ValidatableTextInput(textField: emailTextField)
        input.rules = ComponentRule.emailRules
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.email)
        return input
    }()

    lazy var sendEmailButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Continue", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.viewModel.sendResetPasswordEmail()
        }
        return button
    }()

    // MARK: APIFailableResponding
    typealias FailableViewModel = ForgotPasswordViewModel

    // MARK: KeyboardObserving
    let keyboardObserverHandler = KeyboardObserverHandler()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // View Setup
        view.backgroundColor = .compatibleSystemBackground
        setupSubviews()

        // User Events
        textFieldReturnChainer.onFinalReturn = { [weak self] in
            self?.viewModel.sendResetPasswordEmail()
        }

        // ViewModel
        prepareViewModel()

        // Reuse the loginVC email  if possible, `viewModel.email` will contain the email if it is valid
        emailTextInput.updateText(with: viewModel.email)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Observers
        startObservingNotifications()
        emailTextInput.textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObservingNotifications()
    }

    deinit {
        stopObservingNotifications()
    }

    // MARK: - Private
    private func setupSubviews() {
        // Stack View
        let stackView = insertStackView(arrangedSubviews: [headerLabel, emailTextInput], spacing: Size.componentSpacing)
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.doubleMargin).isActive = true

        // Send Email (Continue) Button
        addKeyboardFollowing(button: sendEmailButton)
    }

    private func prepareViewModel() {
        // Input Validation
        viewModel.createComponentValidator(with: [emailTextInput])

        viewModel.afterValidation = { [weak self] success in
            self?.sendEmailButton.isEnabled = success
        }

        viewModel.onLoadingChange = { [weak self] loading in
            if loading {
                self?.emailTextInput.textField.isEnabled = false
                self?.sendEmailButton.startLoading()
            } else {
                self?.emailTextInput.textField.isEnabled = true
                self?.sendEmailButton.stopLoading()
            }
        }

        setViewModelOnError()
    }
}
