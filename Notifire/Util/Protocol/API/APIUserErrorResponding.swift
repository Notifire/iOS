//
//  APIUserErrorResponding.swift
//  Notifire
//
//  Created by David Bielik on 13/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol UserErrorFailable: class {
    associatedtype UserError: UserErrorRepresenting
    var onUserError: ((UserError) -> Void)? { get set }
    func shouldHandleManually(userError: UserError) -> Bool
}

extension UserErrorFailable {
    func shouldHandleManually(userError: UserError) -> Bool {
        return false
    }
}

// MARK: - Responding
protocol UserErrorFailableResponding: class, NotifirePoppablePresenting {
    associatedtype FailableViewModel: UserErrorFailable

    var viewModel: FailableViewModel { get }

    func setViewModelOnUserError()
    func dismissCompletion(error: FailableViewModel.UserError)
    func alertActions(for error: FailableViewModel.UserError, dismissCallback: @escaping (() -> Void)) -> [NotifireAlertAction]?
}

extension UserErrorFailableResponding where Self: UIViewController {
    func dismissCompletion(error: FailableViewModel.UserError) {}

    func setViewModelOnUserError() {
        viewModel.onUserError = { [weak self] error in
            self?.present(error: error)
        }
    }

    func present(error: FailableViewModel.UserError) {
        let alert = NotifireAlertViewController(alertTitle: "", alertText: error.description)
        let dismissCompletionClosure = {
            alert.dismiss(animated: true, completion: { [weak self] in
                self?.dismissCompletion(error: error)
            })
        }
        alert.add(action: NotifireAlertAction(title: "Ok", style: .neutral, handler: { _ in
            dismissCompletionClosure()
        }))
        if let alertActions = alertActions(for: error, dismissCallback: dismissCompletionClosure) {
            alertActions.forEach { alert.add(action: $0) }
        }
        present(alert: alert, animated: true, completion: nil)
    }

    func alertActions(for error: FailableViewModel.UserError, dismissCallback: @escaping (() -> Void)) -> [NotifireAlertAction]? {
        return nil
    }
}
