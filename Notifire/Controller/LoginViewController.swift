//
//  LoginViewController.swift
//  Notifire
//
//  Created by David Bielik on 01/02/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: NotifireUserSessionCreationDelegate {
    func shouldStartRegisterFlow()
}

class LoginViewController: BottomNavigatorViewController, AppRevealing, KeyboardObserving, CenterStackViewPresenting, APIFailableResponding, APIFailableDisplaying, NotifirePoppablePresenting {
    
    // MARK: - APIFailableResponding
    typealias FailableViewModel = LoginViewModel
    
    // MARK: - Properties
    var animatedViewNormalHeightConstraint: NSLayoutConstraint!
    var animatedViewCollapsedHeightConstraint: NSLayoutConstraint!
    let viewModel: LoginViewModel
    
    weak var delegate: LoginViewControllerDelegate?
    
    // MARK: KeyboardObserving
    var observers: [NSObjectProtocol] = []
    lazy var keyboardExpandedConstraints: [NSLayoutConstraint] = [animatedViewCollapsedHeightConstraint]
    lazy var keyboardCollapsedConstraints: [NSLayoutConstraint] = [animatedViewNormalHeightConstraint]
    var keyboardAnimationBlock: ((Bool, TimeInterval) -> Void)?
    
    // MARK: Static
    static let notifireAnimatedViewHeightInRelationToViewHeight: CGFloat = 0.38
    
    // MARK: Views
    let notifireAnimatedView = NotifireAnimatedView()
    
    lazy var usernameEmailTextInput: ValidatableTextInput = {
        let usernameEmailTextField = CustomTextField()
        usernameEmailTextField.setPlaceholder(text: "Username or email")
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
        passwordTextField.setPlaceholder(text: "Password")
        let input = ValidatableTextInput(textField: passwordTextField)
        input.rules = ComponentRule.passwordRules
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: .password)
        return input
    }()
    
    lazy var signInButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Sign in", for: .normal)
        button.onProperTap = { [unowned self] in
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
        
        setupObservers()
        setupUserEvents()
        prepareViewModel()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notifireAnimatedView.isAnimating = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        notifireAnimatedView.isAnimating = true
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard presented is NotifirePoppable else { return nil }
        return NotifirePopAnimationController()
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Inherited
    override func setupSubviews() {
        super.setupSubviews()
        
        let safeArea = view.safeAreaLayoutGuide
        // animated view
        view.addSubview(notifireAnimatedView)
        notifireAnimatedView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        notifireAnimatedView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        notifireAnimatedView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        animatedViewNormalHeightConstraint = notifireAnimatedView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: LoginViewController.notifireAnimatedViewHeightInRelationToViewHeight)
        animatedViewNormalHeightConstraint.isActive = true
        animatedViewCollapsedHeightConstraint = notifireAnimatedView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier:
            LoginViewController.notifireAnimatedViewHeightInRelationToViewHeight * 0.7)
        
        // loginContainer
        let loginContainerView = CurvedTopView()
        view.addSubview(loginContainerView)
        loginContainerView.topAnchor.constraint(equalTo: notifireAnimatedView.bottomAnchor).isActive = true
        loginContainerView.bottomAnchor.constraint(equalTo: bottomNavigator.topAnchor).isActive = true
        loginContainerView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        loginContainerView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor).isActive = true
        
        // login stack view
        let textFieldStackView = UIStackView(arrangedSubviews: [usernameEmailTextInput, passwordTextInput], spacing: Size.textFieldSpacing)
        let stackView = insertStackView(arrangedSubviews: [textFieldStackView, signInButton], spacing: Size.componentSpacing)
        stackView.topAnchor.constraint(equalTo: loginContainerView.topAnchor, constant: Size.componentSpacing).isActive = true

        tappableLabel.setLinked(text: "New to Notifire? Sign up instead.", link: "Sign up")

        keyboardAnimationBlock = { expanded, duration in
            loginContainerView.switchPaths(expanded: expanded, duration: duration)
            if expanded {
                stackView.spacing = Size.componentSpacing * 0.5
            } else {
                stackView.spacing = Size.componentSpacing
            }
        }
    }
    
    // MARK: - Private
    private func setupUserEvents() {
        addKeyboardDismissOnTap(to: view)
        
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
    override open func didTapTappableLabel() {
        delegate?.shouldStartRegisterFlow()
    }
    
    // MARK: TextField
    @objc func didStopEditing(textField: UITextField) {
        if textField == usernameEmailTextInput.textField {
            passwordTextInput.textField.becomeFirstResponder()
        } else {
            viewModel.login()
        }
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
