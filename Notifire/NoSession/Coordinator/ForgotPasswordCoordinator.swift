//
//  ForgotPasswordCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 04/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class ForgotPasswordCoordinator: ChildCoordinator {

    // MARK: - Properties
    var viewController: UIViewController {
        return forgotPasswordViewController
    }

    let forgotPasswordViewController: ForgotPasswordViewController

    // MARK: - Initialization
    init(forgotPasswordViewController: ForgotPasswordViewController) {
        self.forgotPasswordViewController = forgotPasswordViewController
    }

    // MARK: - Coordinator
    func start() {
        forgotPasswordViewController.viewModel.onSendEmailCompletion = { [weak self] success in
            self?.presentEmailSendCompletionAlert(success: success)
        }
    }

    /// Present the NotifireAlertVC with a proper style and text depending on `success`
    func presentEmailSendCompletionAlert(success: Bool) {
        let alertStyle: NotifireAlertViewController.AlertStyle?
        let alertTitle: String
        let alertText: String

        if success {
            alertStyle = .success
            alertText = forgotPasswordViewController.viewModel.onSendEmailSuccessText
            alertTitle = forgotPasswordViewController.viewModel.onSendEmailSuccessTitle
        } else {
            alertStyle = nil
            alertText = forgotPasswordViewController.viewModel.onSendEmailFailText
            alertTitle = forgotPasswordViewController.viewModel.onSendEmailFailTitle
        }

        let alertVC = NotifireAlertViewController(alertTitle: alertTitle, alertText: alertText, alertStyle: alertStyle)
        alertVC.add(action: NotifireAlertAction(title: "OK", style: .positive, handler: { _ in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        forgotPasswordViewController.present(alert: alertVC, animated: true, completion: nil)
    }
}
