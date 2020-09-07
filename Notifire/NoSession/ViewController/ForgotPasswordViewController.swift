//
//  ForgotPasswordViewController.swift
//  Notifire
//
//  Created by David Bielik on 04/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension APIFailableResponding where Self: VMViewController<APIFailable>, Self: APIFailableDisplaying {

    var failableDisplaying: APIFailableDisplaying {
        return self
    }

}

protocol ForgotPasswordViewControllerDelegate: class {
    func shouldDisplaySuccessfulEmailSend()
}

class ForgotPasswordViewController: VMViewController<ForgotPasswordViewModel>, NavigationBarDisplaying, APIFailableResponding, APIFailableDisplaying, NotifirePoppablePresenting, CenterStackViewPresenting, KeyboardObserving {

    // MARK: - Properties
    weak var delegate: ForgotPasswordViewControllerDelegate?

    // MARK: UI
    let headerLabel: UILabel = {
        let label = UILabel(style: .title)
        label.text = "Issues with logging in?"
        label.textAlignment = .left
        return label
    }()

    lazy var emailTextInput: ValidatableTextInput = {
        let emailTextField = CustomTextField()
        emailTextField.keyboardType = .emailAddress
        emailTextField.setPlaceholder(text: "Enter your e-mail")
        let input = ValidatableTextInput(textField: emailTextField)
        input.rules = ComponentRule.emailRules
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: .email)
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
        setupUserEvents()

        // ViewModel
        prepareViewModel()

        /// Reuse the loginVC email  if possible, `viewModel.email` will contain the email if it is valid
        emailTextInput.updateText(with: viewModel.email)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Observers
        setupObservers()
        emailTextInput.textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }

    deinit {
        removeObservers()
    }

    // MARK: - Private
    private func setupSubviews() {
        // Stack View
        let stackView = insertStackView(arrangedSubviews: [headerLabel, emailTextInput], spacing: Size.componentSpacing)
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.standardMargin).isActive = true

        // Send Email (Continue) Button
        let buttonContainerView = UIView()
        buttonContainerView.backgroundColor = .compatibleSystemBackground
        view.add(subview: buttonContainerView)
        buttonContainerView.embedSides(in: view)
        buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let buttonSeparator = HairlineView()
        view.add(subview: buttonSeparator)
        buttonSeparator.embedSides(in: view)
        buttonSeparator.topAnchor.constraint(equalTo: buttonContainerView.topAnchor).isActive = true

        view.add(subview: sendEmailButton)
        sendEmailButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sendEmailButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true
        sendEmailButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: Size.textFieldSpacing).isActive = true
        let buttonBottomConstraint = sendEmailButton.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        buttonBottomConstraint.priority = .init(950)
        buttonBottomConstraint.isActive = true
        sendEmailButton.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Size.textFieldSpacing).isActive = true

        keyboardObserverHandler.onKeyboardNotificationCallback = { [weak self] expanding, notification in
            guard let keyboardHeight = self?.keyboardObserverHandler.keyboardHeight(from: notification) else { return }
            if expanding {
                buttonBottomConstraint.constant = -keyboardHeight - Size.textFieldSpacing
            }
        }
        keyboardObserverHandler.keyboardExpandedConstraints = [buttonBottomConstraint]
    }

    private func setupUserEvents() {
        emailTextInput.textField.addTarget(self, action: #selector(didStopEditing(textField:)), for: .editingDidEndOnExit)
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

        viewModel.onSendEmailSuccess = { [weak self] in
            self?.delegate?.shouldDisplaySuccessfulEmailSend()
        }

        setViewModelOnError()
    }

    // MARK: - Event Handlers
    // MARK: Text Field
    @objc func didStopEditing(textField: UITextField) {
        if textField == emailTextInput.textField {
            viewModel.sendResetPasswordEmail()
        }
    }

    // MARK: - UIViewControllerAnimatedTransitioning
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController(forPresented: presented)
    }
}
