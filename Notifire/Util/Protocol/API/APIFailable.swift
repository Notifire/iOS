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
    var onError: ((NotifireAPIManager.ManagerResultError) -> Void)? { get set }
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
    func present(error: NotifireAPIManager.ManagerResultError)
}

extension APIFailableDisplaying where Self: UIViewController {
    func present(error: NotifireAPIManager.ManagerResultError) {
        let alertController = UIAlertController(title: "Error encountered", message: error == .server ? "server" : "network", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        present(alertController, animated: true, completion: nil)
    }
}
