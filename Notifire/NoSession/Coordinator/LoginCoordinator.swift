//
//  LoginCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

final class ForgotPasswordViewModel: BindableInputValidatingViewModel, APIFailable {

    // MARK: - Properties
    var email: String

    var loading: Bool = false {
        didSet {
            guard oldValue != loading else { return }
            onLoadingChange?(loading)
        }
    }

    var onLoadingChange: ((Bool) -> Void)?
    var onSendEmailSuccess: (() -> Void)?

    // MARK: InputValidatingBindable
    func keyPath(for value: KeyPaths) -> ReferenceWritableKeyPath<ForgotPasswordViewModel, String> {
        return \.email
    }

    enum KeyPaths: InputValidatingBindableEnum {
        case email
    }

    typealias EnumDescribingKeyPaths = KeyPaths

    // MARK: APIFailable
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: - Initialization
    init(maybeEmail: String, notifireAPIManager: NotifireAPIManager = NotifireAPIManagerFactory.createAPIManager()) {
        self.email = Self.isEmail(string: maybeEmail) ? maybeEmail : ""
        super.init(notifireApiManager: notifireAPIManager)
    }

    // MARK: - Private
    /// Determines if the string param is a valid email.
    private static func isEmail(string: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", Regex.email).evaluate(with: string)
    }

    // MARK: - Methods
    /// Sends a request for password reset email.
    func sendResetPasswordEmail() {
        guard componentValidator?.allComponentsValid ?? false else { return }
        loading = true
        notifireApiManager.sendResetPassword(email: email) { [weak self] result in
            guard let `self` = self else { return }
            self.loading = false
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if response.success {
                    self.onSendEmailSuccess?()
                }
            }
        }
    }

    // MARK: - Public
    let onSendEmailSuccessTitle: String = "Check your inbox!"
    let onSendEmailSuccessText: String = "If there is an account associated with this email address, you will receive a link that will let you reset your password."
}

class LoginCoordinator: NavigationCoordinator<LoginViewController>, ChildCoordinator {

    // MARK: - Properties
    weak var parentCoordinator: NoSessionCoordinator?

    // MARK: ChildCoordinator
    var viewController: UIViewController {
        return navigationController
    }

    // MARK: - Initialization
    override init(rootChildViewController: LoginViewController, navigationController: UINavigationController = UINavigationController()) {
        super.init(rootChildViewController: rootChildViewController, navigationController: LoginNavigationController())
    }

    // MARK: - Coordinator
    override func start() {
        super.start()

        rootViewController.onForgotPassword = { [weak self] in
            self?.startForgotPasswordFlow()
        }
    }

    func startForgotPasswordFlow() {
        let forgotPWVM = ForgotPasswordViewModel(maybeEmail: rootViewController.emailTextInput.validatableInput)
        let forgotPWVC = ForgotPasswordViewController(viewModel: forgotPWVM)
        let forgotPWCoordinator = ForgotPasswordCoordinator(forgotPasswordViewController: forgotPWVC)
        forgotPWVC.delegate = forgotPWCoordinator
        add(childCoordinator: forgotPWCoordinator, push: true )
    }
}
