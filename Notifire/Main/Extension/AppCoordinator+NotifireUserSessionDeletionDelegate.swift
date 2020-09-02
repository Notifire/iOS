//
//  AppCoordinator+NotifireUserSessionDeletionDelegate.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension AppCoordinator: NotifireUserSessionDeletionDelegate {
    /// called when the session is explicitly deleted (user logs out) or when the session expires (the refresh token changes)
    func didDelete(session: NotifireUserSession, onPurpose: Bool) {
        guard let state = appState, case .sessionAvailable(let coordinator) = state else { return }
        let onCompletion: (() -> Void) = { [unowned self] in
            self.rootViewController.viewModel.remove(old: session)
            self.switchToLogin()
            coordinator.userSessionHandler.logout()
        }
        // Check if the logout was initiated by the user.
        guard onPurpose else {
            // If it hasn't, force the logout
            let alertController = UIAlertController(title: "Login required.", message: "Please login again!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                onCompletion()
            }))
            coordinator.activeCoordinator?.viewController.present(alertController, animated: true, completion: nil)
            return
        }
        // logout
        onCompletion()
    }
}
