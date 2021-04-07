//
//  AppCoordinator+NotifireUserSessionCreationDelegate.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension AppCoordinator: UserSessionCreationDelegate {
    /// called when the user logs in, either by confirming his email or by manually entering his id/pw
    func didCreate(session: UserSession) {
        Logger.log(.debug, "\(self) didCreate session=<\(session)>")

        guard let state = appState else {
            deeplinkHandler.finishDeeplink()
            return
        }

        switch state {
        case .noSession:
            guard switchTo(userSession: session) else { return }
            rootViewController.viewModel.save(new: session)
        case .sessionAvailable(let sessionCoordinator):
            // don't interrupt any logged in session, just update the values
            if sessionCoordinator.userSessionHandler.userSession.userID == session.userID {
                sessionCoordinator.userSessionHandler.updateUserSession(
                    refreshToken: session.refreshToken,
                    accessToken: session.accessToken,
                    email: session.email
                )
                deeplinkHandler.finishDeeplink()
            } else {
                // If the deeplink origin was from another account, just dismiss the deeplink.
                deeplinkHandler.finishDeeplink()
            }
        }
    }
}
