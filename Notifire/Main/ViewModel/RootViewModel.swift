//
//  RootViewModel.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/**
  ViewModel that is responsible for the main business logic of the app.
 Handles:
    - User session
    - Deeplinks
    - Notifications
 */
class RootViewModel {

    // MARK: - Properties
    // MARK: User Session Manager
    private let sessionManager: UserSessionManager

    // MARK: - Initialization
    init(sessionManager: UserSessionManager = UserSessionManager()) {
        self.sessionManager = sessionManager
    }

    // MARK: - Public
    /// Return the session handler if a previous session is availalble. Othewrise return nil.
    public func getSessionHandler() -> NotifireUserSessionHandler? {
        if let session = sessionManager.previousSession() {
            // previous session found
            guard let sessionHandler = NotifireUserSessionHandler(session: session) else {
                // remove the session if the realm configuration file doesn't open
                sessionManager.removeSession(userSession: session)
                return nil
            }
            return sessionHandler
        }
        return nil
    }

    // MARK: Session
    /// Save the new user session in the manager object.
    public func save(new session: NotifireUserSession) {
        sessionManager.saveSession(userSession: session)
    }

    /// Remove the session passed in the parameter.
    public func remove(old session: NotifireUserSession) {
        sessionManager.removeSession(userSession: session)
        // Reset the number of notifications in the app icon badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Unregister from notifications
        DeviceTokenManager().unregisterFromPushNotifications()
    }
}
