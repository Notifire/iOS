//
//  APIFailable.swift
//  Notifire
//
//  Created by David Bielik on 13/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

// TODO: Rename to APIErrorPossible, same with UserErrorPossible
protocol APIFailable: class {
    var onError: ((NotifireAPIError) -> Void)? { get set }
}

// MARK: - Responding
protocol APIFailableResponding: class {
    associatedtype FailableViewModel: APIFailable

    var viewModel: FailableViewModel { get }
    var failableDisplaying: APIFailableDisplaying { get }

    func setViewModelOnError()
}

extension APIFailableResponding {
    func setViewModelOnError() {
        viewModel.onError = { [weak self] error in
            self?.failableDisplaying.present(error: error)
        }
    }
}

extension APIFailableResponding where Self: APIFailableDisplaying {
    var failableDisplaying: APIFailableDisplaying {
        return self
    }
}

// MARK: - Displaying
protocol APIFailableDisplaying {
    func present(error: NotifireAPIError)
}

extension APIFailableDisplaying where Self: UIViewController {
    func present(error: NotifireAPIError) {
        let message = error.userFriendlyMessage
        let alertController = UIAlertController(title: "Error encountered", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
}
