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

    static let sessionState: SessionState = .mockSession

    // MARK: - Inherited
    override class func previousUserSession() -> UserSession? {
        switch sessionState {
        case .mockSession:
            let providerData = AuthenticationProviderData(provider: .email, email: "testicek@testicek.com", userID: nil)
            return UserSession(userID: 1, refreshToken: "xDDD", providerData: providerData)
        case .noSession:
            return nil
        }
    }
}
