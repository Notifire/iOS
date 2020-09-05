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

    }
}

extension ForgotPasswordCoordinator: ForgotPasswordViewControllerDelegate {
    func shouldDisplaySuccessfulEmailSend() {
        let alertVC = NotifireAlertViewController(alertTitle: nil, alertText: nil)
        alertVC.add(action: NotifireAlertAction(title: "OK", style: .positive, handler: { _ in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        alertVC.alertTitle = forgotPasswordViewController.viewModel.onSendEmailSuccessTitle
        alertVC.alertText = forgotPasswordViewController.viewModel.onSendEmailSuccessText
        forgotPasswordViewController.present(alert: alertVC, animated: true, completion: nil)
    }
}
