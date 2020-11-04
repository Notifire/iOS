//
//  WebSocketHeartbeatManager.swift
//  Notifire
//
//  Created by David Bielik on 04/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol WebSocketOperationSending: class {
    func send(operationType: WebSocketOperationType)
}

/// Encapsulates Heartbeat sending operations via websocket
class WebSocketHeartbeatManager {

    // MARK: - Properties
    let heartbeatQueue = DispatchQueue(label: "\(Config.bundleID).ServiceWebSocketManager.heartbeatQueue")
    var heartbeatTimer: RepeatingTimer?
    weak var socketWriter: WebSocketOperationSending?

    // MARK: - Initialization
    init(socketWriter: WebSocketOperationSending) {
        self.socketWriter = socketWriter
    }

    deinit {
        heartbeatTimer?.suspend()
    }

    // MARK: - Methods
    /// Starts sending the heartbeat.
    func startSendingHeartbeat(interval: TimeInterval) {
        // Check if an underlying timer already exists
        guard let existingTimer = heartbeatTimer else {
            let newTimer = RepeatingTimer(timeInterval: interval, queue: heartbeatQueue)
            newTimer.eventHandler = { [weak self] in
                self?.socketWriter?.send(operationType: .heartbeat)
            }
            newTimer.resume()
            heartbeatTimer = newTimer
            return
        }
        existingTimer.resume()
    }

    /// Stops sending the heartbeat.
    func stopSendingHeartbeat() {
        heartbeatTimer?.suspend()
        heartbeatTimer = nil
    }
}
