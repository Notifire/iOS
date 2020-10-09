//
//  NotifireAPIManagerFactory.swift
//  Notifire
//
//  Created by David Bielik on 13/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import Starscream

struct NotifireAPIFactory {

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

    static func createWebSocket() -> WebSocket {
        var request = URLRequest(url: URL(string: Config.wsUrlString)!)
        request.timeoutInterval = 5
        #if API_MOCK
            return WebSocket(request: request, engine: WebsocketMockEngine())
        #else
            return WebSocket(request: request)
        #endif
    }
}
