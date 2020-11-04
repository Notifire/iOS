//
//  WebsocketMockEngine.swift
//  Notifire
//
//  Created by David Bielik on 23/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import Starscream
import Network

class WebsocketMockEngine: Engine {
    weak var delegate: EngineDelegate?

    let monitorObject: AnyObject?

    var airplaneMode = false

    init() {
        if #available(iOS 12.0, *) {
            let monitor = NWPathMonitor()
            self.monitorObject = monitor
            monitor.pathUpdateHandler = { [weak self] path in
                if path.availableInterfaces.count == 0 {
                    self?.delegate?.didReceive(event: .disconnected("airplane mode", 1000))
                    self?.airplaneMode = true
                } else {
                    self?.airplaneMode = false
                }
            }

            let queue = DispatchQueue.global(qos: .background)
            monitor.start(queue: queue)
        } else {
            self.monitorObject = nil
        }
    }

    public func register(delegate: EngineDelegate) {
        self.delegate = delegate
    }

    func start(request: URLRequest) {
        guard !airplaneMode else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.delegate?.didReceive(event: .disconnected("airplane mode", 1000))
            }
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.delegate?.didReceive(event: .connected(["Sec-WebSocket-Accept": "oF/XqxDC2AFqVQX1ZV2Twxt2oWU="]))
        }
    }

    func stop(closeCode: UInt16) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.delegate?.didReceive(event: .disconnected("{\"error_code\":0,\"verbose_error\":\"Missing authorization header\"}", closeCode))
        }
    }

    func forceStop() {

    }

    func write(data: Data, opcode: FrameOpCode, completion: (() -> Void)?) {
        let readyEvent = NotifireWebSocketReadyEvent(data: NotifireWebSocketReadyEventData(sessionID: "1", timestamp: Date(), heartbeatInterval: 15))
        guard
            let encodedData = try? JSONEncoder().encode(readyEvent),
            let readyEventStringData = String(data: encodedData, encoding: .utf8)
        else { return }

        if (try? JSONDecoder().decode(WebSocketConnectOperation.self, from: data)) != nil {
            // Connect
            delegate?.didReceive(event: .text(readyEventStringData))
        } else if (try? JSONDecoder().decode(WebSocketReconnectOperation.self, from: data)) != nil {
            // Reconnect
            delegate?.didReceive(event: .text(readyEventStringData))
        }
    }

    func write(string: String, completion: (() -> Void)?) {

    }
}
