//
//  GenericSuccessCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// A GenericCoordinator that can present a success alert.
class GenericSuccessCoordinator<VC: UIViewController>: GenericCoordinator<VC> where VC: ViewModelled & NotifireAlertPresenting, VC.ViewModel: SuccessAlertDataProviding {

    override func start() {
        super.start()

        rootViewController.viewModel.onSuccess = { [weak self] in
            self?.presentSuccessAlert()
        }
    }

    func presentSuccessAlert() {
        let alertVC = NotifireAlertViewController(
            alertTitle: rootViewController.viewModel.successAlertTitle,
            alertText: rootViewController.viewModel.successAlertText,
            alertStyle: .success
        )
        alertVC.add(action: NotifireAlertAction(title: "OK", style: .positive, handler: { [weak self] _ in
            alertVC.dismiss(animated: true) { [weak self] in
                if self?.rootViewController.viewModel.shouldDismissViewAfterSuccessOk ?? false {
                    self?.dismissAfterSuccessOk()
                }
            }
        }))
        rootViewController.present(alert: alertVC, animated: true, completion: nil)
    }

    /// Dismisses the view.
    /// - Important: Subclasses should override this method to provide a custom implementation.
    func dismissAfterSuccessOk() {

    }
}
