//
//  ServiceWebSocketManager.swift
//  Notifire
//
//  Created by David Bielik on 24/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import Starscream
import Network

protocol ServiceWebSocketManagerDelegate: class {
    /// Invoked whenever the websocket server enforces the client to do a new connect operation (not reconnect)
    /// e.g. `expiredSessionID`
    func didRequestFreshConnect()
    /// Called when ServiceWebSocketManager receives service event data.
    func didReceiveServiceEvent(data: NotifireWebSocketServiceEventData)
    /// Called when ServiceWebSocketManager receives replay event data.
    func didReceiveReplayEvent(data: NotifireWebSocketReplayEventData)
}

/// Class reponsible for connecting to the websocket and observing Services changes
/// create / update / delete
class ServiceWebSocketManager: WebSocketDelegate, WebSocketOperationSending {

    // MARK: - Properties
    let socket: WebSocket
    let apiManager: NotifireProtectedAPIManager
    /// networkMonitor has type `NWPathMonitor` but `AnyObject` is used to avoid iOS 11 unavailability
    weak var networkMonitor: AnyObject?

    weak var delegate: ServiceWebSocketManagerDelegate?

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

    // MARK: Static
    static let reconnectDelay: TimeInterval = 1

    // MARK: Heartbeat
    lazy var heartbeatManager = WebSocketHeartbeatManager(socketWriter: self)

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

        // Add network connectivity observer
        if #available(iOS 12, *), networkMonitor == nil {
            let monitor = NWPathMonitor()
            monitor.pathUpdateHandler = { [weak self] path in
                if path.status != .satisfied {
                    self?.disconnect(code: .noInternetConnection)
                }
            }
            monitor.start(queue: DispatchQueue.global(qos: .background))
            self.networkMonitor = monitor
        }

        webSocketConnectionStatus = .connecting

        // Attempt to connect
        socket.connect()
    }

    func disconnect(code: WebSocketErrorCode = .noInternetConnection) {
        // Make sure we're not disconnected right now
        guard !isDisconnected else { return }

        // Change the status
        webSocketConnectionStatus = .disconnected(context: .disconnect(reason: "No internet connection", code: code))

        // Actually disconnect
        socket.disconnect()
    }

    // MARK: - Private
    /// Parse string received from the websocket and handle an appropriate event.
    private func parseAndHandle(text: String) {
        let decoder = JSONDecoder()
        let jsonData = Data(text.utf8)

        do {
            // Get the event type
            let eventType = try decoder.decode(NotifireWebSocketEventType.self, from: jsonData)
            // Handle the event
            switch eventType.event {
            case .ready:
                let readyEvent = try decoder.decode(NotifireWebSocketReadyEvent.self, from: jsonData)
                handle(ready: readyEvent)
            case .serviceEvent:
                let serviceEvent = try decoder.decode(NotifireWebSocketServiceEvent.self, from: jsonData)
                handle(service: serviceEvent)
            case .replay:
                let replayEvent = try decoder.decode(NotifireWebSocketReplayEvent.self, from: jsonData)
                handle(replay: replayEvent)
            case .error:
                let errorEvent = try decoder.decode(NotifireWebSocketErrorEvent.self, from: jsonData)
                handle(error: errorEvent)
            }
        } catch let error {
            Logger.log(.default, "\(self) event handling error: <\(error.localizedDescription)>. Ignoring event with jsonData=\(jsonData)")
        }
    }

    // MARK: Operations
    func send(operationType: WebSocketOperationType) {
        if !shouldGenerateNewAccessToken, let authorizationToken = apiManager.userSession.accessToken {
            switch operationType {
            case .identify:
                let operation = WebSocketConnectOperation(authorizationToken: authorizationToken)
                send(operation: operation)
            case .identifyReconnect:
                guard let sessionID = lastSessionID else {
                    Logger.logNetwork(.fault, "\(self) aborting operationType=<\(operationType)> is not available.")
                    // Rather do a fresh connect as the last session ID or timestamp isn't available
                    send(operationType: .identify)
                    return
                }
                let operation = WebSocketReconnectOperation(authorizationToken: authorizationToken, sessionID: sessionID)
                send(operation: operation)
            case .heartbeat:
                let operation = WebSocketHeartbeatOperation()
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

    /// Convenience function for encoding operations into socket writeable objects.
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
            if #available(iOS 12, *), let nwError = error as? NWError, nwError == .posix(.ECONNABORTED) {
                webSocketConnectionStatus = .disconnected(context: .disconnect(reason: "App went to foreground inactive", code: .appWillResignActive))
            } else {
                webSocketConnectionStatus = .disconnected(context: .error(error))
            }
        case .binary, .cancelled, .ping, .pong, .viabilityChanged, .reconnectSuggested:
            break
        }
    }

    // MARK: Ready Event
    func handle(ready event: NotifireWebSocketReadyEvent) {
        Logger.logNetwork(.debug, "\(self) handling ready event=<\(event)>")

        // Update connection status to Authorized
        guard isConnected else { return }
        webSocketConnectionStatus = .authorized(sessionID: event.data.sessionID)

        heartbeatManager.startSendingHeartbeat(interval: event.data.heartbeatInterval)
    }

    // MARK: Service Event
    func handle(service event: NotifireWebSocketServiceEvent) {
        Logger.logNetwork(.debug, "\(self) handling service event=<\(event)>")

        guard isAuthorized else { return }

        // Callback
        delegate?.didReceiveServiceEvent(data: event.data)
    }

    // MARK: Replay Event
    func handle(replay event: NotifireWebSocketReplayEvent) {
        Logger.logNetwork(.debug, "\(self) handling replay event=<\(event)>")

        guard isAuthorized else { return }
        // Callback
        delegate?.didReceiveReplayEvent(data: event.data)
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
                    delegate?.didRequestFreshConnect()
                case .invalidAccessToken:
                    shouldGenerateNewAccessToken = true
                case .noInternetConnection, .appWillResignActive, .invalidFormat, .unknown:
                    break
                }
            case .error: break
            }

            heartbeatManager.stopSendingHeartbeat()

            // Reconnect after some delay
            DispatchQueue.main.asyncAfter(deadline: .now() + ServiceWebSocketManager.reconnectDelay) { [weak self] in
                guard let `self` = self, self.isDisconnected else { return }
                self.connect()
            }
        default:
            break
        }

        // Notify observers
        let change = WebSocketConnectionStatus.Change(old: old, new: new)
        NotificationCenter.default.post(name: .didChangeWebSocketConnectionStatus, object: nil, userInfo: [ExtendedNotificationObserver.userInfoDataKey: change])
    }

}

// MARK: - Notification
extension Notification.Name {
    /// Posted when ServiceWebSocketManager changes its connection status
    static let didChangeWebSocketConnectionStatus = Notification.Name("didChangeWebSocketConnectionStatus")
}
