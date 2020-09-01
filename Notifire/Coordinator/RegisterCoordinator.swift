//
//  RegisterCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class RegisterCoordinator: Coordinator {

    enum RegistrationState {
        case registering
        case success
    }

    // MARK: - Properties
    let navigationController: NotifireActionNavigationController
    let registerViewController: RegisterViewController
    var successViewController: RegisterSuccessViewController?
    weak var parentCoordinator: NoSessionCoordinator?

    var registrationState: RegistrationState = .registering

    // MARK: - Initialization
    init(apiManager: NotifireAPIManager) {
        registerViewController = RegisterViewController(viewModel: RegisterViewModel(notifireApiManager: apiManager))
        self.navigationController = NotifireActionNavigationController(rootViewController: registerViewController)
    }

    // MARK: - Private
    private func presentRegister() {
        guard successViewController != nil else { return }
        navigationController.popViewController(animated: true)
        successViewController = nil
    }

    private func presentSuccessVC() {
        guard successViewController == nil else { return }
        let registerSuccessViewModel = RegisterSuccessViewModel(apiManager: registerViewController.viewModel.notifireApiManager, email: registerViewController.viewModel.email)
        let registerSuccessViewController = RegisterSuccessViewController(viewModel: registerSuccessViewModel)
        successViewController = registerSuccessViewController
        registerSuccessViewController.delegate = self
        navigationController.pushViewController(registerSuccessViewController, animated: true)
    }

    // MARK: - Internal
    func start() {
        registerViewController.delegate = self
    }

    func finish() {
        parentCoordinator?.finishRegisterFlow()
    }
}

extension RegisterCoordinator: RegisterSuccessViewControllerDelegate {
    func didFinishRegister() {
        finish()
    }

    func shouldStartNewRegistration() {
        presentRegister()
    }
}

extension RegisterCoordinator: RegisterViewControllerDelegate {
    func shouldFinishRegistration() {
        finish()
    }

    func didRegisterSuccessfully() {
        presentSuccessVC()
    }
}
