//
//  DeeplinkHandler.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class DeeplinkHandler {

    var currentDeeplink: Deeplink?
    weak var appCoordinator: AppCoordinator?

    func switchToAppropriateDeeplink(from url: URL) -> Bool {
        var comp = url.pathComponents
        guard !comp.isEmpty else {
            return false
        }

        let token = comp.removeLast()
        switch comp {
        case ["/", "account", "confirm"]:
            switchTo(deeplinkOption: .emailConfirmation(token: token))
        case ["/", "account", "reset", "email"]:
            switchTo(deeplinkOption: .resetEmail(token: token))
        case ["/", "account", "reset", "password"]:
            switchTo(deeplinkOption: .resetPassword(token: token))
        default:
            // unknown url format
            return false
        }
        return true
    }

    func switchTo(deeplinkOption: Deeplink.Option) {
        // dismiss any presented deeplink
        if let activeDeeplink = currentDeeplink {
            activeDeeplink.deeplinkPresenter.presentedViewController?.dismiss(animated: false, completion: nil)
            currentDeeplink = nil
        }
        // handle the new deeplink option
        let newDeeplink = Deeplink(option: deeplinkOption)
        let deeplinkViewController: UIViewController
        switch deeplinkOption {
        case .emailConfirmation(let token):
            let confirmEmailViewModel = ConfirmEmailViewModel(token: token)
            let confirmEmailViewController = ConfirmEmailViewController(viewModel: confirmEmailViewModel)
            confirmEmailViewController.delegate = appCoordinator
            confirmEmailViewController.sessionDelegate = appCoordinator
            deeplinkViewController = confirmEmailViewController
        case .resetEmail, .resetPassword:
            // TODO: add vcs
            deeplinkViewController = UIViewController()
        }
        newDeeplink.deeplinkPresenter.present(deeplinkViewController, animated: true, completion: nil)
        self.currentDeeplink = newDeeplink
    }

    func finishDeeplink(completion: (() -> Void)? = nil) {
        guard let activeDeeplink = currentDeeplink else { return }
        activeDeeplink.deeplinkPresenter.presentedViewController?.dismiss(animated: true, completion: {
            self.currentDeeplink = nil
            completion?()
        })
    }
}
