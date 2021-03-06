//
//  LoginViewController.swift
//  Notifire
//
//  Created by David Bielik on 01/02/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class LoginViewController: VMViewController<LoginViewModel>, AppRevealing, KeyboardObserving, NavigationBarDisplaying, CenterStackViewPresenting, APIErrorResponding, APIErrorPresenting, NotifireAlertPresenting {

    // MARK: - APIFailableResponding
    typealias FailableViewModel = LoginViewModel

    // MARK: - Properties
    /// Determines if the view is appearing for the first time
    var firstTimeAppearing: Bool = true

    var backgroundViewExpandedHeightConstraint: NSLayoutConstraint!
    var stackViewKeyboardBottomConstraint: NSLayoutConstraint!
    var animatedViewNormalHeightConstraint: NSLayoutConstraint!

    weak var delegate: LoginViewControllerDelegate?

    // MARK: Actions
    var onForgotPassword: (() -> Void)?

    // MARK: KeyboardObserving
    var keyboardObserverHandler = KeyboardObserverHandler()

    // MARK: Static
    static let notifireBackgroundViewHeightToViewHeight: CGFloat = 0.28

    // MARK: UI
    lazy var textFieldReturnChainer = TextFieldReturnChainer(textFields: [emailTextInput.textField, passwordTextInput.textField])

    let notifireBackgroundView = NotifireBackgroundView()

    let headerLabel: UILabel = {
        let label = UILabel(style: .title)
        label.text = "Continue to your account"
        return label
    }()

    var stackView: UIStackView?

    lazy var emailTextInput: ValidatableTextInput = {
        let emailTextField = BorderedTextField()
        emailTextField.setPlaceholder(text: "Enter your e-mail")
        emailTextField.keyboardType = .emailAddress
        emailTextField.textContentType = .emailAddress
        let input = ValidatableTextInput(textField: emailTextField)
        input.rules = [
            ComponentRule(kind: .minimum(length: 1), showIfBroken: false),
            ComponentRule(kind: .maximum(length: Settings.Text.maximumUsernameLength), showIfBroken: true)
        ]
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.email)
        return input
    }()

    lazy var passwordTextInput = ValidatableTextInput.createPasswordTextInput(
        textFieldType: BorderedTextField.self,
        newPasswordTextContentType: false,
        placeholderText: "Enter your password",
        viewModel: viewModel,
        bindableKeyPath: \.password
    )

    lazy var forgotPasswordContainerView = ConstrainableView()

    lazy var forgotPasswordButton: ActionButton = {
        let button = ActionButton.createActionButton(text: "Forgot your password?") { [unowned self] _ in
            self.onForgotPassword?()
        }
        button.titleLabel?.font = UIFont.systemFont(ofSize: Size.Font.placeholder)
        button.contentHorizontalAlignment = .right
        return button
    }()

    lazy var signInButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Sign in", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.viewModel.login()
        }
        return button
    }()

    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSubviews()
        hideNavigationBarBackButtonText()
        startObservingNotifications()
        textFieldReturnChainer.onFinalReturn = { [weak self] in
            self?.viewModel.login()
        }
        prepareViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Add observers if the view is about to appear
        startObservingNotifications()

        guard !emailTextInput.textField.isFirstResponder && !passwordTextInput.textField.isFirstResponder && firstTimeAppearing else { return }
        firstTimeAppearing = false
        emailTextInput.textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove keyboard observers when the view is about to disappear
        stopObservingNotifications()
    }

    deinit {
        stopObservingNotifications()
    }

    // MARK: - Inherited
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        // Dismiss the keyboard if the touch event is outside of the stackView that contains
        // the textfields & sign in button.
        if let event = event, event.type == .touches, let touch = touches.first {
            let location = touch.location(in: view)

            guard let viewThatGotTouched = view.hitTest(location, with: event), let stackView = stackView else { return }
            if !(viewThatGotTouched === stackView) {
                view.endEditing(true)
            }
        }
    }

    // MARK: - Private
    func setupSubviews() {

        navigationItem.leftBarButtonItem = ActionButton.createCloseCrossBarButtonItem(target: self, action: #selector(didPressCloseButton))

        let safeArea = view.safeAreaLayoutGuide
        // animated view
        view.addSubview(notifireBackgroundView)
        notifireBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        notifireBackgroundView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        notifireBackgroundView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        animatedViewNormalHeightConstraint = notifireBackgroundView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: LoginViewController.notifireBackgroundViewHeightToViewHeight)
        animatedViewNormalHeightConstraint.isActive = true
        backgroundViewExpandedHeightConstraint = notifireBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: LoginViewController.notifireBackgroundViewHeightToViewHeight)
        backgroundViewExpandedHeightConstraint.priority = .init(300)
        backgroundViewExpandedHeightConstraint.isActive = true

        // loginContainer
        let loginContainerView = CurvedTopView()
        view.addSubview(loginContainerView)
        loginContainerView.topAnchor.constraint(equalTo: notifireBackgroundView.bottomAnchor).isActive = true
        loginContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loginContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        loginContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true

        // login stack view
        let textFieldStackView = UIStackView(arrangedSubviews: [emailTextInput, passwordTextInput, forgotPasswordContainerView], spacing: Size.textFieldSpacing)
        let stackViewSpacing: CGFloat = Size.componentSpacing * 1.5
        let stackView = insertStackView(arrangedSubviews: [headerLabel, textFieldStackView, signInButton], spacing: stackViewSpacing)
        stackView.topAnchor.constraint(equalTo: loginContainerView.topAnchor, constant: Size.componentSpacing).isActive = true
        self.stackView = stackView

        // Forgot Password
        forgotPasswordContainerView.add(subview: forgotPasswordButton)
        forgotPasswordButton.topAnchor.constraint(equalTo: forgotPasswordContainerView.topAnchor).isActive = true
        forgotPasswordButton.trailingAnchor.constraint(equalTo: forgotPasswordContainerView.trailingAnchor).isActive = true
        forgotPasswordButton.bottomAnchor.constraint(equalTo: forgotPasswordContainerView.bottomAnchor).isActive = true

        // StackView - keyboard constraint
        stackViewKeyboardBottomConstraint = stackView.bottomAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor)
        stackViewKeyboardBottomConstraint.priority = UILayoutPriority.init(rawValue: 950)

        keyboardObserverHandler.onKeyboardNotificationAnimationCallback = { expanding, duration in
            loginContainerView.switchPaths(expanded: expanding, duration: duration)
            if expanding {
                stackView.spacing = Size.componentSpacing * 0.75
            } else {
                stackView.spacing = stackViewSpacing
            }
        }

        keyboardObserverHandler.onKeyboardNotificationCallback = { [weak self] expanding, notification in
            guard let keyboardHeight = self?.keyboardObserverHandler.keyboardHeight(from: notification) else { return }
            if expanding {
                self?.stackViewKeyboardBottomConstraint.constant = -keyboardHeight - Size.componentSpacing
            } else {
                self?.stackViewKeyboardBottomConstraint.constant = 0
            }
        }

        keyboardObserverHandler.keyboardCollapsedConstraints = [backgroundViewExpandedHeightConstraint]
        keyboardObserverHandler.keyboardExpandedConstraints = [stackViewKeyboardBottomConstraint]
    }

    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [emailTextInput, passwordTextInput])

        viewModel.afterValidation = { [weak self] success in
            self?.signInButton.isEnabled = success
        }
        viewModel.onLoadingChange = { [weak self] loading in
            if loading {
                self?.dismissKeyboard()
                self?.emailTextInput.textField.isEnabled = false
                self?.passwordTextInput.textField.isEnabled = false
                self?.signInButton.startLoading()
            } else {
                self?.emailTextInput.textField.isEnabled = true
                self?.passwordTextInput.textField.isEnabled = true
                self?.signInButton.stopLoading()
            }
        }
        viewModel.onLogin = { [weak self] session in
            self?.delegate?.didCreate(session: session)
        }

        setViewModelOnError()
        setViewModelOnUserError()
    }

    // MARK: - Event Handlers
    @objc private func didPressCloseButton() {
        view.endEditing(true)
        delegate?.shouldDismissLogin()
    }
}

extension LoginViewController: UserErrorResponding {
    func alertActions(for error: LoginUserError, dismissCallback: @escaping (() -> Void)) -> [NotifireAlertAction]? {
        guard
            viewModel.shouldHandleManually(userError: error) else { return nil }
        let action = NotifireAlertAction(title: "Resend confirmation email", style: .positive, handler: { [unowned self] _ in
            self.viewModel.resendEmail()
            dismissCallback()
        })
        return [action]
    }
}
