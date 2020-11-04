//
//  WebSocketOperationType.swift
//  Notifire
//
//  Created by David Bielik on 09/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// The operation type that the client sends to the server.
enum WebSocketOperationType: Int, Codable {
    /// Used for periodic liveness checks.
    case heartbeat = 0
    /// Used on connecting without a previous session.
    case identify = 1
    /// Used for reconnecting / resuming a previous session.
    case identifyReconnect
}
