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
    override func previousSession() -> NotifireUserSession? {
        switch sessionState {
        case .mockSession:
            return NotifireUserSession(refreshToken: "xDDD", username: "TestTestTest")
        case .noSession:
            return nil
        }
    }
}
