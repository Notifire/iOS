//
//  APIUserErrorResponding.swift
//  Notifire
//
//  Created by David Bielik on 13/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol UserErrorProducing: class {
    /// The UserError associated with this UserErrorFailable
    associatedtype UserError: UserErrorRepresenting
    /// Called whenever the userError is encountered.
    var onUserError: ((UserError) -> Void)? { get set }
    /// Called before handling the error. `true` if the error has a custom handler. Default implementation returns `false` for all errors.
    func shouldHandleManually(userError: UserError) -> Bool
}

extension UserErrorProducing {
    func shouldHandleManually(userError: UserError) -> Bool {
        return false
    }
}

// MARK: - Responding
protocol UserErrorResponding: class, NotifireAlertPresenting {
    associatedtype UserErrorProducingViewModel: UserErrorProducing

    var viewModel: UserErrorProducingViewModel { get }

    func setViewModelOnUserError()
    func dismissCompletion(error: UserErrorProducingViewModel.UserError)
    func alertActions(for error: UserErrorProducingViewModel.UserError, dismissCallback: @escaping (() -> Void)) -> [NotifireAlertAction]?
}

extension UserErrorResponding where Self: UIViewController {
    func dismissCompletion(error: UserErrorProducingViewModel.UserError) {}

    func setViewModelOnUserError() {
        viewModel.onUserError = { [weak self] error in
            self?.present(error: error)
        }
    }

    func present(error: UserErrorProducingViewModel.UserError) {
        let alert = NotifireAlertViewController(alertTitle: nil, alertText: error.description, alertStyle: .fail)
        let dismissCompletionClosure = {
            alert.dismiss(animated: true, completion: { [weak self] in
                self?.dismissCompletion(error: error)
            })
        }
        alert.add(action: NotifireAlertAction(title: "OK", style: .positive, handler: { _ in
            dismissCompletionClosure()
        }))
        if let alertActions = alertActions(for: error, dismissCallback: dismissCompletionClosure) {
            alertActions.forEach { alert.add(action: $0) }
        }
        present(alert: alert, animated: true, completion: nil)
    }

    func alertActions(for error: UserErrorProducingViewModel.UserError, dismissCallback: @escaping (() -> Void)) -> [NotifireAlertAction]? {
        return nil
    }
}
