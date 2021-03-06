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
struct WebSocketOperation<OperationData: Codable>: Codable {

    private enum CodingKeys: String, CodingKey {
        case operation = "op", data = "d"
    }

    // MARK: Properties
    let operation: WebSocketOperationType
    let data: OperationData?

    // MARK: Initialization
    fileprivate init(operation: WebSocketOperationType, data: OperationData?) {
        self.operation = operation
        self.data = data
    }
}

// MARK: - WebSocketConnectOperation
/// The data sent along with the connect operation.
struct WebSocketConnectOperationData: Codable {
    /// User's access token. Used for authenticating the socket.
    let accessToken: String
}

typealias WebSocketConnectOperation = WebSocketOperation<WebSocketConnectOperationData>

extension WebSocketConnectOperation where OperationData == WebSocketConnectOperationData {
    init(authorizationToken: String) {
        self.init(operation: .identify, data: WebSocketConnectOperationData(accessToken: authorizationToken))
    }
}

// MARK: - WebSocketReconnectOperation
struct WebSocketReconnectOperationData: Codable {
    let accessToken: String
    let sessionID: String
}

typealias WebSocketReconnectOperation = WebSocketOperation<WebSocketReconnectOperationData>

extension WebSocketReconnectOperation where OperationData == WebSocketReconnectOperationData {
    init(authorizationToken: String, sessionID: String) {
        self.init(operation: .identifyReconnect, data: WebSocketReconnectOperationData(accessToken: authorizationToken, sessionID: sessionID))
    }
}

// MARK: - WebSocketHeartbeatOperation
typealias WebSocketHeartbeatOperation = WebSocketOperation<EmptyRequestBody>

extension WebSocketHeartbeatOperation where OperationData == EmptyRequestBody {
    init() {
        self.init(operation: .heartbeat, data: nil)
    }
}
