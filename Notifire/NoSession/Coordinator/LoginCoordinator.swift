//
//  LoginCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class LoginCoordinator: NavigatingChildCoordinator {

    // MARK: - Properties
    let loginViewController: LoginViewController

    // MARK: ChildCoordinator
    var viewController: UIViewController {
        return loginViewController
    }

    // MARK: NavigatingChildCoordinator
    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: - Initialization
    init(loginViewController: LoginViewController) {
        self.loginViewController = loginViewController
    }

    // MARK: - Coordinator
    func start() {
        loginViewController.onForgotPassword = { [weak self] in
            self?.startForgotPasswordFlow()
        }
    }

    func startForgotPasswordFlow() {
        let forgotPWVM = ForgotPasswordViewModel(maybeEmail: loginViewController.emailTextInput.validatableInput)
        let forgotPWVC = ForgotPasswordViewController(viewModel: forgotPWVM)
        let forgotPWCoordinator = ForgotPasswordCoordinator(forgotPasswordViewController: forgotPWVC)
        parentNavigatingCoordinator?.push(childCoordinator: forgotPWCoordinator)
    }
}
