//
//  RootViewModel.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class RootViewModel {

    // MARK: - Properties
    // MARK: User Session Manager
    let sessionManager: UserSessionManager

    // MARK: - Initialization
    init(sessionManager: UserSessionManager = UserSessionManager()) {
        self.sessionManager = sessionManager
    }

    // MARK: - Public

    // MARK: Session
    /// Save the new user session in the manager object.
    public func save(new session: UserSession) {
        sessionManager.saveSession(userSession: session)
    }

    /// Remove the session passed in the parameter.
    public func remove(old session: UserSession) {
        sessionManager.removeSession(userSession: session)
        // Reset the number of notifications in the app icon badge
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
