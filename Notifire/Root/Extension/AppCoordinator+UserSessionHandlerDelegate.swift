//
//  AppCoordinator+UserSessionHandlerDelegate.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension AppCoordinator: UserSessionHandlerDelegate {

    func shouldRemoveUser(session: UserSession, reason: UserSessionRemovalReason) {
        // make sure there is a session state
        guard let state = appState, case .sessionAvailable(let coordinator) = state else { return }
        // prepare completion block
        let logoutBlock: (() -> Void) = { [unowned self] in
            self.rootViewController.viewModel.remove(old: session)
            self.switchToLoginFlow()
        }

        switch reason {
        case .userLoggedOut:
            // normal logout that the user has initiated manually
            logoutBlock()
        case let otherReason:
            // force the logout
            let alertController = UIAlertController(
                title: "Login required.",
                message: otherReason.reasonDescription(provider: session.providerData.provider),
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                logoutBlock()
            }))
            coordinator.activeCoordinator?.viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
