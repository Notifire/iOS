//
//  UserSessionManager+UserSessionHandler.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension UserSessionManager {
    /// Return the session handler if a previous session is availalble. Othewrise return nil.
    public func getUserSessionHandler() -> UserSessionHandler? {
        guard let session = previousUserSession() else { return nil }
        // previous session found
        guard let sessionHandler = UserSessionHandler(session: session) else {
            // remove the session if the realm configuration file doesn't open
            removeSession(userSession: session)
            return nil
        }
        return sessionHandler
    }
}
