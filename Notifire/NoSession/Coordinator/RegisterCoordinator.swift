//
//  RegisterCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class RegisterCoordinator: NavigationCoordinator<GenericCoordinator<RegisterEmailViewController>> {

    // MARK: - Properties
    weak var parentCoordinator: NoSessionCoordinator?

    init() {
        let registerEmailVM = RegisterEmailViewModel(apiManager: NotifireAPIFactory.createAPIManager())
        let registerEmailVC = RegisterEmailViewController(viewModel: registerEmailVM)
        let registerEmailCoordinator = GenericCoordinator(viewController: registerEmailVC)
        super.init(
            rootChildCoordinator: registerEmailCoordinator,
            navigationController: NotifireNavigationController()
        )
    }

    override func start() {
        super.start()

        rootChildCoordinator.rootViewController.delegate = self
    }
}

extension RegisterCoordinator: RegisteringViewControllerDelegate {
    func shouldSignInInsteadOfRegister() {
        parentCoordinator?.finishRegisterOrLoginFlow()
    }
}

extension RegisterCoordinator: RegisterEmailViewControllerDelegate {
    func shouldContinueFromRegisterEmail(registerEmailViewController: RegisterEmailViewController) {
        let registerPasswordVM = RegisterPasswordViewModel(
            registerEmailViewModel: registerEmailViewController.viewModel
        )
        let registerPasswordVC = RegisterPasswordViewController(viewModel: registerPasswordVM)
        registerPasswordVC.delegate = self
        let registerPasswordCoordinator = GenericCoordinator(viewController: registerPasswordVC)
        push(childCoordinator: registerPasswordCoordinator, animated: true)
    }
}

extension RegisterCoordinator: RegisterPasswordViewControllerDelegate {
    func didRegisterSuccessfully(registerPasswordViewController: RegisterPasswordViewController) {
        let apiManager = registerPasswordViewController.viewModel.apiManager
        let email = registerPasswordViewController.viewModel.email
        let registerSuccessVM = RegisterSuccessViewModel(apiManager: apiManager, email: email)
        let registerSuccessVC = RegisterSuccessViewController(viewModel: registerSuccessVM)
        registerSuccessVC.delegate = self
        let registerSuccessCoordinator = GenericCoordinator(viewController: registerSuccessVC)
        push(childCoordinator: registerSuccessCoordinator, animated: true)
    }
}
