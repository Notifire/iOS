//
//  SettingsCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class SettingsCoordinator: NavigatingChildCoordinator {

    // MARK: - Properties
    let settingsViewController: SettingsViewController

    // MARK: NavigatingChildCoordinator
    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: TabbedCoordinator
    var viewController: UIViewController {
        return settingsViewController
    }

    // MARK: - Initialization
    init(settingsViewController: SettingsViewController) {
        self.settingsViewController = settingsViewController
    }

    // MARK: - Methods
    func start() {
        settingsViewController.delegate = self
    }
}

// MARK: - SettingsViewControllerDelegate
extension SettingsCoordinator: SettingsViewControllerDelegate {
    func didSelectChangeEmailButton() {
        let viewModel = ChangeEmailViewModel(sessionHandler: settingsViewController.viewModel.userSessionHandler)
        let changeEmailVC = ChangeEmailViewController(viewModel: viewModel)
        parentNavigatingCoordinator?.push(childCoordinator: GenericSuccessCoordinator(viewController: changeEmailVC))
    }

    func didSelectChangePasswordButton() {
        let viewModel = ChangePasswordViewModel(sessionHandler: settingsViewController.viewModel.userSessionHandler)
        let changePasswordVC = ChangePasswordViewController(viewModel: viewModel)
        parentNavigatingCoordinator?.push(childCoordinator: ChangePasswordCoordinator(viewController: changePasswordVC))
    }

    func didSelectLogoutButton() {
        settingsViewController.viewModel.userSessionHandler.exitUserSession(reason: .userLoggedOut)
    }

    func didSelectFAQButton() {
        let changeEmailVC = UIViewController()
        parentNavigatingCoordinator?.push(childCoordinator: GenericCoordinator(viewController: changeEmailVC))
    }

    func didSelectPrivacyPolicyButton() {
        let changeEmailVC = UIViewController()
        parentNavigatingCoordinator?.push(childCoordinator: GenericCoordinator(viewController: changeEmailVC))
    }

    func didSelectContactButton() {
        guard let url = URL(string: "https://google.com") else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
