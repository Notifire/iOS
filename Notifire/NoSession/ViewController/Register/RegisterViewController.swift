//
//  RegisterViewController.swift
//  Notifire
//
//  Created by David Bielik on 28/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

/// Protocol that describes classes that are able to cancel the registration process.
protocol RegisteringViewControllerDelegate: class {
    /// Invoked when the user taps the "Sign in instead" bottom bar label.
    func shouldSignInInsteadOfRegister()
}

// MARK: - Register Password
class RegisterPasswordViewModel: InputValidatingViewModel, APIErrorProducing {

    // MARK: - Properties
    // MARK: Model
    var password = ""
    let email: String

    var loading: Bool = false {
        didSet {
            guard oldValue != loading else { return }
            onLoadingChange?(loading)
        }
    }

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: Callback
    var onRegister: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    // MARK: - Initialization
    init(registerEmailViewModel: RegisterEmailViewModel) {
        self.email = registerEmailViewModel.email
    }

    // MARK: - Methods
    func register() {
        guard allComponentsValidated else { return }
        loading = true
        apiManager.register(email: email, password: password) { [weak self] result in
            guard let `self` = self else { return }
            self.loading = false
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if response.success {
                    self.onRegister?()
                }
            }
        }
    }
}

protocol RegisterPasswordViewControllerDelegate: RegisteringViewControllerDelegate {
    /// Called when the user registers succesfully.
    func didRegisterSuccessfully(registerPasswordViewController: RegisterPasswordViewController)
}

class RegisterPasswordViewController: VMViewController<RegisterPasswordViewModel>, NavigationBarDisplaying, BottomNavigatorLabelContaining, KeyboardFollowingButtonContaining, APIErrorResponding, APIErrorPresenting {

    // MARK: - Properties
    weak var delegate: RegisterPasswordViewControllerDelegate?

    // MARK: UI
    lazy var textFieldReturnChainer = TextFieldReturnChainer(textField: passwordTextInput.textField)

    lazy var titleLabel = UILabel(style: .title, text: "You'll need a password", alignment: .center)

    lazy var passwordTextInput = ValidatableTextInput.createPasswordTextInput(
        textFieldType: BorderedTextField.self,
        newPasswordTextContentType: false,
        placeholderText: "Password",
        viewModel: viewModel,
        bindableKeyPath: \.password
    )

    // MARK: BottomNavigatorContaining
    lazy var bottomNavigator: UIView = defaultBottomNavigatorView()
    lazy var bottomNavigatorLabel: UILabel = {
        let label = TappableLabel.createBottomNavigatorSignInLabel()
        label.onHypertextTapped = { [weak self] in
            self?.delegate?.shouldSignInInsteadOfRegister()
        }
        return label
    }()

    lazy var signUpButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Sign up", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.viewModel.register()
        }
        return button
    }()

    // MARK: KeyboardFollowingButtonContaining
    var keyboardObserverHandler = KeyboardObserverHandler()
    var shouldAddKeyboardFollowingContainer: Bool { return false }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarBackButtonText()
        hideNavigationBar()

        view.backgroundColor = .compatibleSystemBackground

        setupSubviews()
        setupUserEvents()
        prepareViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Keyboard
        startObservingNotifications()
        UIView.performWithoutAnimation {
            passwordTextInput.textField.becomeFirstResponder()
        }
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
        addBottomNavigator()
        addBottomNavigatorLabel()

        view.add(subview: titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true

        view.add(subview: passwordTextInput)
        passwordTextInput.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Size.componentSpacing * 2).isActive = true
        passwordTextInput.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passwordTextInput.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true

        addKeyboardFollowing(button: signUpButton, buttonBottomLessThanOrEqualToAnchor: bottomNavigator.topAnchor)
    }

    private func setupUserEvents() {
        addKeyboardDismissOnTap(to: view)

        textFieldReturnChainer.onFinalReturn = { [weak self] in
            self?.viewModel.register()
        }
    }

    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [passwordTextInput])

        // viewModel
        viewModel.afterValidation = { [weak self] success in
            self?.signUpButton.isEnabled = success
        }
        viewModel.onLoadingChange = { [weak self] loading in
            if loading {
                self?.dismissKeyboard()
                self?.passwordTextInput.textField.isEnabled = false
                self?.signUpButton.startLoading()
            } else {
                self?.passwordTextInput.textField.isEnabled = true
                self?.signUpButton.stopLoading()
            }
        }
        viewModel.onRegister = { [weak self] in
            guard let `self` = self else { return }
            self.delegate?.didRegisterSuccessfully(registerPasswordViewController: self)
        }

        setViewModelOnError()
    }
}

// MARK: - Register Email

class RegisterEmailViewModel: InputValidatingViewModel {

    // MARK: - Properties
    var email = ""
}

protocol RegisterEmailViewControllerDelegate: RegisteringViewControllerDelegate {
    /// Called when the user wants to continue to the next part of the registration.
    func shouldContinueFromRegisterEmail(registerEmailViewController: RegisterEmailViewController)
}

class RegisterEmailViewController: VMViewController<RegisterEmailViewModel>, NavigationBarDisplaying, BottomNavigatorLabelContaining, KeyboardFollowingButtonContaining {

    // MARK: - Properties
    weak var delegate: RegisterEmailViewControllerDelegate?

    // MARK: UI
    lazy var textFieldReturnChainer = TextFieldReturnChainer(textField: emailTextInput.textField)

    lazy var titleLabel = UILabel(style: .title, text: "Create your account", alignment: .center)

    lazy var emailTextInput: ValidatableTextInput = {
        let textField = BottomBarTextField()
        textField.keyboardType = .emailAddress
        textField.textContentType = .emailAddress
        textField.setPlaceholder(text: "Enter your email")
        let input = ValidatableTextInput(textField: textField)
        input.rules = ComponentRule.createEmailRules
        input.showsValidState = true
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.email)
        return input
    }()

    lazy var continueButton: NotifireButton = {
        let button = NotifireButton()
        button.isEnabled = false
        button.setTitle("Next", for: .normal)
        button.onProperTap = { [unowned self] _ in
            self.continueToNextRegisterStep()
        }
        return button
    }()

    // MARK: BottomNavigatorContaining
    lazy var bottomNavigator: UIView = defaultBottomNavigatorView()
    lazy var bottomNavigatorLabel: UILabel = {
        let label = TappableLabel.createBottomNavigatorSignInLabel()
        label.onHypertextTapped = { [weak self] in
            self?.delegate?.shouldSignInInsteadOfRegister()
        }
        return label
    }()

    // MARK: KeyboardFollowingButtonContaining
    var keyboardObserverHandler = KeyboardObserverHandler()
    var shouldAddKeyboardFollowingContainer: Bool { return false }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarBackButtonText()
        hideNavigationBar()
        view.backgroundColor = .compatibleSystemBackground

        setupSubviews()
        setupUserEvents()
        prepareViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Keyboard
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
        addBottomNavigator()
        addBottomNavigatorLabel()

        view.add(subview: titleLabel)
        titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.componentSpacing).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true

        view.add(subview: emailTextInput)
        emailTextInput.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Size.componentSpacing * 2).isActive = true
        emailTextInput.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        emailTextInput.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true

        addKeyboardFollowing(button: continueButton, buttonBottomLessThanOrEqualToAnchor: bottomNavigator.topAnchor)
    }

    private func setupUserEvents() {
        addKeyboardDismissOnTap(to: view)

        textFieldReturnChainer.onFinalReturn = { [weak self] in
            self?.continueToNextRegisterStep()
        }
    }

    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [emailTextInput])

        // viewModel
        viewModel.afterValidation = { [weak self] success in
            self?.continueButton.isEnabled = success
        }
    }

    private func continueToNextRegisterStep() {
        delegate?.shouldContinueFromRegisterEmail(registerEmailViewController: self)
    }
}

extension TappableLabel {
    static func createBottomNavigatorSignInLabel() -> TappableLabel {
        let label = TappableLabel()
        label.set(style: .primary)
        let hyperText = "Sign in"
        let text = "Already using Notifire? \(hyperText)."
        label.set(hypertext: hyperText, in: text)
        return label
    }
}
