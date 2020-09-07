//
//  NotifireUserSessionManagerMock.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class NotifireUserSessionManagerMock: UserSessionManager {

    enum SessionState {
        case mockSession
        case noSession
    }

    let sessionState: SessionState

    // MARK: - Initialization
    init(sessionState: SessionState = .mockSession) {
        self.sessionState = sessionState
    }

    // MARK: - Inherited
    override func previousUserSession() -> UserSession? {
        switch sessionState {
        case .mockSession:
            let providerData = AuthenticationProviderData(provider: .email, email: "testicek@testicek.com", userID: nil)
            return UserSession(refreshToken: "xDDD", providerData: providerData)
        case .noSession:
            return nil
        }
    }
}
