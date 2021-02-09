//
//  SettingsCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import MessageUI

class SettingsCoordinator: NSObject, NavigatingChildCoordinator, PresentingCoordinator {

    // MARK: - Properties
    let settingsViewController: SettingsViewController

    // MARK: NavigatingChildCoordinator
    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: TabbedCoordinator
    var viewController: UIViewController {
        return settingsViewController
    }

    // MARK: PresentingCoordinator
    var presentedCoordinator: ChildCoordinator?
    var presentingViewController: UIViewController {
        return viewController
    }
    var presentationDismissHandler: UIAdaptivePresentationDismissHandler?

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

    func didSelectPrivacyPolicyButton() {
        let privacyPolicyVC = PrivacyPolicyViewController()
        parentNavigatingCoordinator?.push(childCoordinator: GenericCoordinator(viewController: privacyPolicyVC))
    }

    func didSelectContactButton() {
        if MFMailComposeViewController.canSendMail() {
            // Get data to append
            let modelName = UIDevice.modelName
            let iOSVersion = UIDevice.current.systemVersion
            let appVersion = Config.appVersion

            let mailVC = MFMailComposeViewController()
            mailVC.view.tintColor = .primary
            mailVC.mailComposeDelegate = self
            mailVC.setToRecipients(["notifire.support@dvdblk.com"])
            mailVC.setMessageBody("\n\n\n---\nNotifire Version: \(appVersion)\niOS Version: \(iOSVersion)\nModel Name: \(modelName)", isHTML: false)

            present(viewController: mailVC, animated: true)
        } else {
            URLOpener.open(urlString: "https://notifire.dvdblk.com")
        }
    }
}

extension SettingsCoordinator: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismissPresentedCoordinator(animated: true)
    }
}
