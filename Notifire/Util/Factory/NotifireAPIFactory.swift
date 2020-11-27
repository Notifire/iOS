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

    static func createAPIManager(apiHandler: APIHandler? = nil) -> NotifireAPIManager {
        #if API_MOCK
            return NotifireAPIManagerMock()
        #else
            return NotifireAPIManager(apiHandler: apiHandler)
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
        let callbackQueue = DispatchQueue(label: "\(Config.bundleID).ServiceWebSocketManager.callbackQueue")
        #if API_MOCK
            let socket = WebSocket(request: request, engine: WebsocketMockEngine(queue: callbackQueue))
            socket.callbackQueue = callbackQueue
            return socket
        #else
            let socket = WebSocket(request: request)
            socket.callbackQueue = callbackQueue
            return socket
        #endif
    }
}
