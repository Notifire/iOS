//
//  APIErrorProducing.swift
//  Notifire
//
//  Created by David Bielik on 13/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

/// ViewModels that might produce a `NotifireAPIError` should conform to this protocol.
protocol APIErrorProducing: class {
    var onError: ((NotifireAPIError) -> Void)? { get set }
}

// MARK: - Responding
protocol APIErrorResponding: class {
    associatedtype APIErrorProducingViewModel: APIErrorProducing

    var viewModel: APIErrorProducingViewModel { get }
    var failableDisplaying: APIErrorPresenting { get }

    func setViewModelOnError()
}

extension APIErrorResponding {
    func setViewModelOnError() {
        viewModel.onError = { [weak self] error in
            self?.failableDisplaying.present(error: error)
        }
    }
}

extension APIErrorResponding where Self: APIErrorPresenting {
    var failableDisplaying: APIErrorPresenting {
        return self
    }
}

// MARK: - Presenting
protocol APIErrorPresenting {
    func present(error: NotifireAPIError)
}

extension APIErrorPresenting where Self: UIViewController {
    func present(error: NotifireAPIError) {
        let message = error.userFriendlyMessage
        let alertController = UIAlertController(title: "Network error encountered", message: message, preferredStyle: .alert)
        alertController.view.tintColor = .primary
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
}
