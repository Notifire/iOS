//
//  AppCoordinator+NotifireUserSessionCreationDelegate.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension AppCoordinator: NotifireUserSessionCreationDelegate {
    /// called when the user logs in, either by confirming his email or by manually entering his id/pw
    func didCreate(session: UserSession) {
        // don't interrupt any logged in session even when an account gets confirmed
        guard let state = appState, case .noSession = state else {
            // just dismiss the deeplink vc
            deeplinkHandler.finishDeeplink()
            return
        }
        guard switchTo(userSession: session) else { return }
        rootViewController.viewModel.save(new: session)
    }
}
