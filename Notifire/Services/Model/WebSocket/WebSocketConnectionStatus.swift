//
//  WebSocketConnectionStatus.swift
//  Notifire
//
//  Created by David Bielik on 30/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

enum WebSocketConnectionStatus: Equatable {
    case disconnected(context: WebSocketDisconnectContext)
    case connecting
    case connected(headers: [String: String])
    case authorized(sessionID: String)
}
