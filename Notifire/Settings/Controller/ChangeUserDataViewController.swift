//
//  ChangeUserDataViewController.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

protocol TitleProviding {
    var title: String { get }
}

class LoadingModel {

    // MARK: - Properties
    public var isLoading: Bool = false {
           didSet {
               guard oldValue != isLoading else { return }
               onLoadingChange?(isLoading)
           }
       }

    public var onLoadingChange: ((Bool) -> Void)?

    public func toggle() {
        isLoading = !isLoading
    }
}

protocol SuccessAlertDataProviding {
    var onSuccess: (() -> Void)? { get set }

    // Alert
    /// The title of the alert
    var successAlertTitle: String? { get }
    /// The text for the alert
    var successAlertText: String? { get }
    /// If the view should be dismissed after pressing OK.
    var shouldDismissViewAfterSuccessOk: Bool { get }
}

extension SuccessAlertDataProviding {
    var successAlertTitle: String? {
        return nil
    }

    var successAlertText: String? {
        return nil
    }
}

class ChangePasswordCoordinator: GenericSuccessCoordinator<ChangePasswordViewController>, NavigatingChildCoordinator {

    // MARK: - Properties
    // MARK: NavigatingChildCoordinator
    var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: Inherited
    override func dismissAfterSuccessOk() {
        parentNavigatingCoordinator?.popChildCoordinator()
    }
}

class ChangePasswordViewModel: InputValidatingViewModel, SuccessAlertDataProviding, TitleProviding, APIErrorProducing, UserErrorProducing {

    // MARK: - Properties
    let sessionHandler: UserSessionHandler

    var oldPassword = ""
    var newPassword = ""
    var newPassword2 = ""

    /// `true` if this was the first appearance of the view
    var isFirstAppearance = true

    let loadingModel = LoadingModel()

    // MARK: TitleProviding
    var title: String {
        return "Password"
    }

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: UserErrorFailable
    typealias UserError = ChangePasswordUserError
    var onUserError: ((ChangePasswordUserError) -> Void)?

    // MARK: SuccessAlertDataProviding
    var onSuccess: (() -> Void)?
    var shouldDismissViewAfterSuccessOk: Bool {
        return true
    }

    var successAlertText: String? {
        return "You have successfully changed your password!"
    }

    // MARK: - Initialization
    init(sessionHandler: UserSessionHandler) {
        self.sessionHandler = sessionHandler
        super.init()
    }

    // MARK: - Public
    func saveNewPassword() {
        guard allComponentsValidated, !loadingModel.isLoading else { return }
        loadingModel.toggle()

        sessionHandler.notifireProtectedApiManager.change(oldPassword: oldPassword, to: newPassword2) { [weak self] result in
            guard let `self` = self else { return }
            self.loadingModel.toggle()
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if let payload = response.payload {
                    self.sessionHandler.updateUserSession(
                        refreshToken: payload.refreshToken,
                        accessToken: payload.accessToken
                    )
                    self.onSuccess?()
                } else if let userError = response.error {
                    self.onUserError?(userError.code)
                }
            }
        }
    }
}

class ChangePasswordViewController: VMViewController<ChangePasswordViewModel>, NotifireAlertPresenting, CenterStackViewPresenting, UserErrorResponding, APIErrorResponding, APIErrorPresenting {

    // MARK: - Properties
    lazy var textFields: [UITextField] = [
        oldPasswordTextInput.textField, newPasswordTextInput.textField, newPassword2TextInput.textField
    ]

    lazy var textFieldReturnChainer = TextFieldReturnChainer(textFields: textFields)

    // MARK: Text inputs
    lazy var oldPasswordTextInput: ValidatableTextInput = {
        let passwordTextField = BottomBarTextField()
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .password
        passwordTextField.setPlaceholder(text: "Current password")
        let input = ValidatableTextInput(textField: passwordTextField)
        input.rules = ComponentRule.passwordRules
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.oldPassword)
        return input
    }()

    lazy var newPasswordTextInput: ValidatableTextInput = {
        let passwordTextField = BottomBarTextField()
        passwordTextField.isSecureTextEntry = true
        if #available(iOS 12.0, *) {
            passwordTextField.textContentType = .newPassword
        } else {
            passwordTextField.textContentType = .password
        }
        passwordTextField.setPlaceholder(text: "New password")
        let input = ValidatableTextInput(textField: passwordTextField)
        input.rules = ComponentRule.passwordRules + [
            ComponentRule(kind: .notEqualToComponent(oldPasswordTextInput), showIfBroken: true, brokenRuleDescription: "New password must be different.")
        ]
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.newPassword)
        return input
    }()

    lazy var newPassword2TextInput: ValidatableTextInput = {
        let passwordTextField = BottomBarTextField()
        passwordTextField.isSecureTextEntry = true
        if #available(iOS 12.0, *) {
            passwordTextField.textContentType = .newPassword
        } else {
            passwordTextField.textContentType = .password
        }
        passwordTextField.returnKeyType = .done
        passwordTextField.setPlaceholder(text: "New password, again")
        let input = ValidatableTextInput(textField: passwordTextField)
        input.rules = ComponentRule.passwordRules + [
            ComponentRule(kind: .notEqualToComponent(oldPasswordTextInput), showIfBroken: true, brokenRuleDescription: "New password must be different."),
            ComponentRule(kind: .equalToComponent(newPasswordTextInput), showIfBroken: true, brokenRuleDescription: "New passwords are different")
        ]
        input.validatingViewModelBinder = ValidatingViewModelBinder(viewModel: viewModel, for: \.newPassword2)
        return input
    }()

    // MARK: NavBar buttons
    lazy var saveBarButton: UIBarButtonItem = {
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didSelectSaveNewPassword))
        saveButton.tintColor = .primary
        saveButton.isEnabled = false
        saveButton.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .semibold)], for: .normal)
        return saveButton
    }()

    lazy var spinnerBarButton: UIBarButtonItem = {
        let style: UIActivityIndicatorView.Style
        if #available(iOS 13.0, *) {
            style = .medium
        } else {
            style = .gray
        }
        let spinner = UIActivityIndicatorView(style: style)
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        return UIBarButtonItem(customView: spinner)
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        title = viewModel.title
        view.backgroundColor = .compatibleSystemBackground

        // Navbar buttons
        updateRightBarButtonItem(animated: false)

        // Text Fields 'return'
        textFieldReturnChainer.onFinalReturn = { [weak self] in
            self?.viewModel.saveNewPassword()
        }

        setupSubviews()
        prepareViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard viewModel.isFirstAppearance else { return }
        viewModel.isFirstAppearance = false
        oldPasswordTextInput.textField.becomeFirstResponder()
    }

    private func setupSubviews() {
        let stackView = insertStackView(arrangedSubviews: [oldPasswordTextInput, newPasswordTextInput, newPassword2TextInput], spacing: Size.textFieldSpacing)
        stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.textFieldSpacing).isActive = true
    }

    private func prepareViewModel() {
        viewModel.createComponentValidator(with: [oldPasswordTextInput, newPasswordTextInput, newPassword2TextInput])

        viewModel.afterValidation = { [weak self] success in
            self?.saveBarButton.isEnabled = success
        }
        viewModel.loadingModel.onLoadingChange = { [weak self] loading in
            self?.textFields.forEach { $0.isEnabled = !loading }
            self?.updateRightBarButtonItem()
        }

        setViewModelOnError()
        setViewModelOnUserError()
    }

    private func updateRightBarButtonItem(animated: Bool = true) {
        if viewModel.loadingModel.isLoading {
            navigationItem.setRightBarButton(spinnerBarButton, animated: animated)
        } else {
            navigationItem.setRightBarButton(saveBarButton, animated: animated)
        }
    }

    // MARK: - Event Handlers
    @objc private func didSelectSaveNewPassword() {
        viewModel.saveNewPassword()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController(forPresented: presented)
    }
}
