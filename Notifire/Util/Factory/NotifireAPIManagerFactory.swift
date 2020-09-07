//
//  NotifireAPIManagerFactory.swift
//  Notifire
//
//  Created by David Bielik on 13/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

struct NotifireAPIManagerFactory {

    static func createAPIManager() -> NotifireAPIManager {
        #if API_MOCK
            return NotifireAPIManagerMock()
        #else
            return NotifireAPIManager()
        #endif
    }

    static func createProtectedAPIManager(session: UserSession) -> NotifireProtectedAPIManager {
        #if API_MOCK
            return NotifireProtectedAPIManagerMock(session: session)
        #else
            return NotifireProtectedAPIManager(session: session)
        #endif
    }
}
