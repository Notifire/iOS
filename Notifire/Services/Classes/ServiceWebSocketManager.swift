//
//  ServiceWebSocketManager.swift
//  Notifire
//
//  Created by David Bielik on 24/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import Starscream

/// Class reponsible for connecting to the websocket and observing Services changes
/// create / update / delete
class ServiceWebSocketManager: WebSocketDelegate {

    // MARK: - Properties
    let socket: WebSocket
    let apiManager: NotifireProtectedAPIManager

    // MARK: Model
    /// `true` if `webSocketConnectionStatus = .disconnected`
    private var isDisconnected: Bool {
        switch webSocketConnectionStatus {
        case .disconnected: return true
        case .connected, .authorized, .connecting: return false
        }
    }

    /// `true` if `webSocketConnectionStatus = .authorized`
    private var isAuthorized: Bool {
        guard case .authorized = webSocketConnectionStatus else { return false }
        return true
    }

    /// `true` if `webSocketConnectionStatus = .connected`
    private var isConnected: Bool {
        guard case .connected = webSocketConnectionStatus else { return false }
        return true
    }

    var webSocketConnectionStatus: WebSocketConnectionStatus = .disconnected(context: .initial) {
        didSet {
            guard oldValue != webSocketConnectionStatus else { return }
            webSocketConnectionStatusChanged(from: oldValue, to: webSocketConnectionStatus)
        }
    }

    var shouldGenerateNewAccessToken = false

    /// Stores the previous session's ID if the last connection was authorized.
    /// - Note: used for reconnecting to the socket.
    var lastSessionID: String?

    var lastServiceUpdatedAt: Date?

    // MARK: Callbacks
    var onWebSocketConnectionStatusChange: ((WebSocketConnectionStatus, WebSocketConnectionStatus) -> Void)?

    var onServiceEvent: ((NotifireWebSocketServiceEventData) -> Void)?

    var onReplayEvent: ((NotifireWebSocketReplayEventData) -> Void)?

    // MARK: Static
    static let reconnectDelay: TimeInterval = 1

    // MARK: - Initialization
    init(apiManager: NotifireProtectedAPIManager) {
        self.apiManager = apiManager
        let socket = NotifireAPIFactory.createWebSocket()
        self.socket = socket
        socket.delegate = self
    }

    // MARK: - Methods
    /// Connect to the websocket
    func connect() {
        guard isDisconnected else { return }

        webSocketConnectionStatus = .connecting

        // Attempt to connect
        socket.connect()
    }

    // MARK: - Private
    /// Parse string received from the websocket and handle an appropriate event.
    private func parseAndHandle(text: String) {
        let decoder = JSONDecoder()
        let jsonData = Data(text.utf8)

        if let readyEvent = try? decoder.decode(NotifireWebSocketReadyEvent.self, from: jsonData) {
            handle(ready: readyEvent)
        } else if let serviceEvent = try? decoder.decode(NotifireWebSocketServiceEvent.self, from: jsonData) {
            handle(service: serviceEvent)
        } else if let replayEvent = try? decoder.decode(NotifireWebSocketReplayEvent.self, from: jsonData) {
            handle(replay: replayEvent)
        } else if let errorEvent = try? decoder.decode(NotifireWebSocketErrorEvent.self, from: jsonData) {
            handle(error: errorEvent)
        } else {
            Logger.logNetwork(.default, "\(self) ignoring handling of event. textData=<\"\(text)>\"")
        }
    }

    // MARK: Operations
    private func send(operationType: WebSocketOperationType) {
        if !shouldGenerateNewAccessToken, let authorizationToken = apiManager.userSession.accessToken {
            switch operationType {
            case .identify:
                let operation = WebSocketConnectOperation(authorizationToken: authorizationToken)
                send(operation: operation)
            case .identifyReconnect:
                guard let sessionID = lastSessionID, let timestamp = lastServiceUpdatedAt else {
                    Logger.logNetwork(.fault, "\(self) aborting operationType=<\(operationType)>, timestamp=<\(String(describing: lastServiceUpdatedAt))> or lastSessionID=<\(String(describing: lastServiceUpdatedAt))> is not available.")
                    // Rather do a fresh connect as the last session ID or timestamp isn't available
                    send(operationType: .identify)
                    return
                }
                let operation = WebSocketReconnectOperation(authorizationToken: authorizationToken, sessionID: sessionID, timestamp: timestamp)
                send(operation: operation)
            }
        } else {
            Logger.logNetwork(.debug, "\(self) generating new access (authorization) token")
            apiManager.fetchNewAccessToken { [weak self] result in
                guard let `self` = self, self.isConnected else { return }
                switch result {
                case .error:
                    // Delay for next fetch
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.send(operationType: operationType)
                    }
                case .success:
                    self.shouldGenerateNewAccessToken = false
                    self.send(operationType: operationType)
                }

            }
        }
    }

    private func send<OperationData>(operation: WebSocketOperation<OperationData>) {
        let encoder = JSONEncoder()

        guard let jsonOperationData = try? encoder.encode(operation) else {
            Logger.logNetwork(.error, "\(self) couldn't encode and send operation=<\(operation)>")
            return
        }
        Logger.logNetwork(.debug, "\(self) sending operation=<\(operation)>")
        socket.write(stringData: jsonOperationData, completion: nil)
    }

    // MARK: - Event Handlers
    // MARK: WebSocket Events
    /// Handle websocket events
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        Logger.logNetwork(.debug, "\(self) didReceive event=<\(event)>")

        switch event {
        case .connected(let headers):
            webSocketConnectionStatus = .connected(headers: headers)
        case .disconnected(let reason, let code):
            webSocketConnectionStatus = .disconnected(context: .disconnect(reason: reason, code: WebSocketErrorCode(code: Int(code))))
        case .text(let string):
            parseAndHandle(text: string)
        case .error(let error):
            webSocketConnectionStatus = .disconnected(context: .error(error))
        case .binary, .cancelled, .ping, .pong, .viabilityChanged, .reconnectSuggested:
            break
        }
    }

    // MARK: Ready Event
    func handle(ready event: NotifireWebSocketReadyEvent) {
        Logger.logNetwork(.debug, "\(self) handling ready event=<\(event)>")

        // Update connection status to Authorized
        guard isConnected else { return }
        lastServiceUpdatedAt = event.data.timestamp
        webSocketConnectionStatus = .authorized(sessionID: event.data.sessionID)
    }

    // MARK: Service Event
    func handle(service event: NotifireWebSocketServiceEvent) {
        Logger.logNetwork(.debug, "\(self) handling service event=<\(event)>")

        guard isAuthorized else { return }

        if let updatedAt = event.data.service.updatedAt {
            lastServiceUpdatedAt = updatedAt
        }

        // Callback
        onServiceEvent?(event.data)
    }

    // MARK: Replay Event
    func handle(replay event: NotifireWebSocketReplayEvent) {
        Logger.logNetwork(.debug, "\(self) handling replay event=<\(event)>")

        guard isAuthorized else { return }
        onReplayEvent?(event.data)
    }

    // MARK: Error Event
    func handle(error event: NotifireWebSocketErrorEvent) {
        // Only log the error
        Logger.logNetwork(.debug, "\(self) handling error event=<\(event)>")
    }

    // MARK: Connection Status
    /// Handler for connection status changes.
    /// - Note: invokes the `onWebSocketConnectionStatusChange` callback
    func webSocketConnectionStatusChanged(from old: WebSocketConnectionStatus, to new: WebSocketConnectionStatus) {
        Logger.logNetwork(.debug, "\(self) webSocketConnectionStatus=<\(new)>")

        switch (old, new) {
        case (_, .connected):
            if lastSessionID != nil {
                // reconnect case
                send(operationType: .identifyReconnect)
            } else {
                // fresh connect case
                send(operationType: .identify)
            }
        case (_, .disconnected(let context)):
            switch context {
            case .initial: break
            case .disconnect(_, let code):
                switch code {
                case .expiredSessionID:
                    lastSessionID = nil
                case .invalidAccessToken:
                    shouldGenerateNewAccessToken = true
                case .invalidFormat, .unknown:
                    break
                }
            case .error: break
            }

            // Reconnect after some delay
            DispatchQueue.main.asyncAfter(deadline: .now() + ServiceWebSocketManager.reconnectDelay) { [weak self] in
                guard let `self` = self, self.isDisconnected else { return }
                self.connect()
            }
        default:
            break
        }

        // Notify the listener if needed
        onWebSocketConnectionStatusChange?(old, new)
    }

}
