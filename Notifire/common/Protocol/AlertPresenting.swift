//
//  AlertPresenting.swift
//  Notifire
//
//  Created by David Bielik on 06/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

// MARK: - AlertPresenting
/// Describes classes that present `UIAlertController` objects
protocol AlertPresenting {
    /// The viewController that will present the alert when `presentAlert(:)` is called.
    var alertPresentingViewController: UIViewController { get }
}

extension AlertPresenting where Self: ChildCoordinator {
    var alertPresentingViewController: UIViewController {
        return viewController
    }
}

// MARK: - OKAlertPresenting
protocol OKAlertPresenting: AlertPresenting {
    /// Presents alert that contains one OK button that dismisses the alert.
    func presentOKAlert(title: String?, message: String?, preferredStyle: UIAlertController.Style)
}

extension OKAlertPresenting {
    func presentOKAlert(title: String?, message: String?, preferredStyle alertStyle: UIAlertController.Style) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        alertPresentingViewController.present(alert, animated: true, completion: nil)
    }
}

// MARK: - OKCancelAlertPresenting
// swiftlint:disable function_parameter_count
protocol OKCancelAlertPresenting: AlertPresenting {
    /// Presents alert that contains one OK button that dismisses the alert.
    func presentOKCancelAlert(title: String?, message: String?, preferredStyle alertStyle: UIAlertController.Style, okTitle: String, cancelTitle: String, onOK: (() -> Void)?, onCancel: (() -> Void)?)
}

extension OKCancelAlertPresenting {
    func presentOKCancelAlert(title: String?, message: String?, preferredStyle alertStyle: UIAlertController.Style, okTitle: String, cancelTitle: String, onOK: (() -> Void)?, onCancel: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: alertStyle)
        let okAction = UIAlertAction(title: okTitle, style: .cancel) { _ in
            alert.dismiss(animated: true, completion: onOK)
        }
        let cancelAction = UIAlertAction(title: cancelTitle, style: .default) { _ in
            alert.dismiss(animated: true, completion: onCancel)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alertPresentingViewController.present(alert, animated: true, completion: nil)
    }
}
