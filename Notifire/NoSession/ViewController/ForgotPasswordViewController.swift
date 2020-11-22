//
//  ForgotPasswordViewController.swift
//  Notifire
//
//  Created by David Bielik on 04/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

protocol KeyboardFollowingButtonContaining: KeyboardObserving {
    func addKeyboardFollowing(button: UIButton)
}

extension KeyboardFollowingButtonContaining where Self: UIViewController {
    func addKeyboardFollowing(button: UIButton) {
        let buttonContainerView = UIView()
        buttonContainerView.backgroundColor = .compatibleSystemBackground
        view.add(subview: buttonContainerView)
        buttonContainerView.embedSides(in: view)
        buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        let buttonSeparator = HairlineView()
        view.add(subview: buttonSeparator)
        buttonSeparator.embedSides(in: view)
        buttonSeparator.topAnchor.constraint(equalTo: buttonContainerView.topAnchor).isActive = true

        view.add(subview: button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true
        button.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: Size.textFieldSpacing).isActive = true
        let buttonBottomConstraint = button.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        buttonBottomConstraint.priority = .init(950)
        buttonBottomConstraint.isActive = true
        button.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Size.textFieldSpacing).isActive = true

        keyboardObserverHandler.onKeyboardNotificationCallback = { [weak self] expanding, notification in
            guard let keyboardHeight = self?.keyboardObserverHandler.keyboardHeight(from: notification) else { return }
            if expanding {
                buttonBottomConstraint.constant = -keyboardHeight - Size.textFieldSpacing
            }
        }
        keyboardObserverHandler.keyboardExpandedConstraints = [buttonBottomConstraint]
    }
}

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

    // MARK: - UIViewControllerAnimatedTransitioning
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController(forPresented: presented)
    }
}
