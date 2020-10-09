//
//  WebSocketOperation.swift
//  Notifire
//
//  Created by David Bielik on 01/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

// MARK: - WebSocketOperation
/// Represents the intended operation (command) of the WebSocket client.
/// - Note: encapsulates the operation message sent to the WebSocket server.
/// ```
///
///
///
struct WebSocketOperation<OperationData: Codable>: Codable {

    private enum CodingKeys: String, CodingKey {
        case operation = "op", data = "d"
    }

    // MARK: Properties
    let operation: WebSocketOperationType
    let data: OperationData

    // MARK: Initialization
    fileprivate init(operation: WebSocketOperationType, data: OperationData) {
        self.operation = operation
        self.data = data
    }
}

// MARK: - WebSocketConnectOperation
/// The data sent along with the connect operation.
struct WebSocketConnectOperationData: Codable {
    /// User's access token. Used for authenticating the socket.
    let token: String
}

typealias WebSocketConnectOperation = WebSocketOperation<WebSocketConnectOperationData>

extension WebSocketConnectOperation where OperationData == WebSocketConnectOperationData {
    init(authorizationToken: String) {
        self.init(operation: .identify, data: WebSocketConnectOperationData(token: authorizationToken))
    }
}

// MARK: - WebSocketReconnectOperation
struct WebSocketReconnectOperationData: Codable {
    let token: String
    let sessionID: String
    let timestamp: Date
}

typealias WebSocketReconnectOperation = WebSocketOperation<WebSocketReconnectOperationData>

extension WebSocketReconnectOperation where OperationData == WebSocketReconnectOperationData {
    init(authorizationToken: String, sessionID: String, timestamp: Date = Date()) {
        self.init(operation: .identifyReconnect, data: WebSocketReconnectOperationData(token: authorizationToken, sessionID: sessionID, timestamp: timestamp))
    }
}
