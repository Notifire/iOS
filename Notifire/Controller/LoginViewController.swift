//
//  LoginViewController.swift
//  Notifire
//
//  Created by David Bielik on 01/02/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController, AppRevealing, KeyboardObserving, NavigationBarDisplaying, CenterStackViewPresenting, APIFailableResponding, APIFailableDisplaying, NotifirePoppablePresenting {

    // MARK: - APIFailableResponding
    typealias FailableViewModel = LoginViewModel

    // MARK: - Properties
    /// Determines if the view is appearing for the first time
    var firstTimeAppearing: Bool = true

    var backgroundViewExpandedHeightConstraint: NSLayoutConstraint!
    var stackViewKeyboardBottomConstraint: NSLayoutConstraint!
    var animatedViewNormalHeightConstraint: NSLayoutConstraint!

    let viewModel: LoginViewModel

    weak var delegate: LoginViewControllerDelegate?

    // MARK: Actions
    var onForgotPassword: (() -> Void)?

    // MARK: KeyboardObserving
    var keyboardObserverHandler = KeyboardObserverHandler()

    // MARK: Static
    static let notifireBackgroundViewHeightInRelationToViewHeight: CGFloat = 0.28

    // MARK: Views
    let notifireBackgroundView = NotifireBackgroundView()

    let headerLabel: UILabel = {
        let label = UILabel(style: .title)
        label.text = "Continue to your account"
        return label
    }()

    var stackView: UIStackView?

    lazy var usernameEmailTextInput: ValidatableTextInput = {
        let usernameEmailTextField = CustomTextField()
        usernameEmailTextField.setPlaceholder(text: "Enter your e-mail")
        usernameEmailTextField.keyboardType = .emailAddress
        let input = ValidatableTextInput(textField: usernameEmailTextField)
        input.rules = [
            ComponentRule(kind: .minimum(length: 1), showIfBroken: false),
            ComponentRule(kind: .maximum(length: Settings.Text.maximumUsernameLength), showIfBroken: true)
        ]
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: .username)
        return input
    }()

    lazy var passwordTextInput: ValidatableTextInput = {
        let passwordTextField = CustomTextField()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.setPlaceholder(text: "Enter your password")
        let input = ValidatableTextInput(textField: passwordTextField)
        input.rules = ComponentRule.passwordRules
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: .password)
        return input
    }()

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

    // MARK: - Initialization
    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.createComponentValidator(with: [usernameEmailTextInput, passwordTextInput])
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - VC Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        hideNavigationBarBackButtonText()
        setupObservers()
        setupUserEvents()
        prepareViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Add observers if the view is about to appear
        setupObservers()

        guard !usernameEmailTextInput.textField.isFirstResponder && !passwordTextInput.textField.isFirstResponder && firstTimeAppearing else { return }
        firstTimeAppearing = false
        usernameEmailTextInput.textField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove keyboard observers when the view is about to disappear
        removeObservers()
    }

    deinit {
        removeObservers()
    }

    // MARK: - Inherited
    override func setupSubviews() {
        super.setupSubviews()

        let image = UIImage(imageLiteralResourceName: "cross_symbol").resized(to: Size.Navigator.symbolSize)
        navigationItem.leftBarButtonItem = ActionButton.createActionBarButtonItem(image: image, target: self, action: #selector(didPressCloseButton))

        let safeArea = view.safeAreaLayoutGuide
        // animated view
        view.addSubview(notifireBackgroundView)
        notifireBackgroundView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        notifireBackgroundView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        notifireBackgroundView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        animatedViewNormalHeightConstraint = notifireBackgroundView.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: LoginViewController.notifireBackgroundViewHeightInRelationToViewHeight)
        animatedViewNormalHeightConstraint.isActive = true
        backgroundViewExpandedHeightConstraint = notifireBackgroundView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: LoginViewController.notifireBackgroundViewHeightInRelationToViewHeight)
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
        let textFieldStackView = UIStackView(arrangedSubviews: [usernameEmailTextInput, passwordTextInput, forgotPasswordContainerView], spacing: Size.textFieldSpacing)
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
    private func setupUserEvents() {
        let textFields = [usernameEmailTextInput.textField, passwordTextInput.textField]
        textFields.forEach {
            $0.addTarget(self, action: #selector(didStopEditing(textField:)), for: .editingDidEndOnExit)
        }
    }

    private func prepareViewModel() {
        viewModel.afterValidation = { [weak self] success in
            self?.signInButton.isEnabled = success
        }
        viewModel.onLoadingChange = { [weak self] loading in
            if loading {
                self?.dismissKeyboard()
                self?.usernameEmailTextInput.textField.isEnabled = false
                self?.passwordTextInput.textField.isEnabled = false
                self?.signInButton.startLoading()
            } else {
                self?.usernameEmailTextInput.textField.isEnabled = true
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
    // MARK: TextField
    @objc func didStopEditing(textField: UITextField) {
        if textField == usernameEmailTextInput.textField {
            passwordTextInput.textField.becomeFirstResponder()
        } else {
            viewModel.login()
        }
    }

    @objc private func didPressCloseButton() {
        view.endEditing(true)
        delegate?.shouldDismissLogin()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController(forPresented: presented)
    }
}

extension LoginViewController: UserErrorFailableResponding {
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
