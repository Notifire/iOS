//
//  LoginCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class LoginCoordinator: NavigationCoordinator<GenericCoordinator<LoginViewController>> {

    // MARK: - Properties
    weak var parentCoordinator: NoSessionCoordinator?

    var loginViewController: LoginViewController {
        return rootChildCoordinator.rootViewController
    }

    // MARK: - Initialization
    override init(rootChildCoordinator: GenericCoordinator<LoginViewController>, navigationController: UINavigationController = UINavigationController()) {
        super.init(rootChildCoordinator: rootChildCoordinator, navigationController: LoginNavigationController())
    }

    // MARK: - Coordinator
    override func start() {
        super.start()

        loginViewController.onForgotPassword = { [weak self] in
            self?.startForgotPasswordFlow()
        }
    }

    func startForgotPasswordFlow() {
        let forgotPWVM = ForgotPasswordViewModel(maybeEmail: loginViewController.emailTextInput.validatableInput)
        let forgotPWVC = ForgotPasswordViewController(viewModel: forgotPWVM)
        let forgotPWCoordinator = ForgotPasswordCoordinator(forgotPasswordViewController: forgotPWVC)
        add(childCoordinator: forgotPWCoordinator, push: true )
    }
}
