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

    let callbackQueue: DispatchQueue

    var airplaneMode = false

    init(queue callbackQueue: DispatchQueue) {
        self.callbackQueue = callbackQueue
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
            callbackQueue.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.delegate?.didReceive(event: .disconnected("airplane mode", 1000))
            }
            return
        }
        callbackQueue.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.delegate?.didReceive(event: .connected(["Sec-WebSocket-Accept": "oF/XqxDC2AFqVQX1ZV2Twxt2oWU="]))
        }
    }

    func stop(closeCode: UInt16) {
        callbackQueue.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.delegate?.didReceive(event: .disconnected("{\"error_code\":0,\"verbose_error\":\"Missing authorization header\"}", closeCode))
        }
    }

    func forceStop() {

    }

    func write(data: Data, opcode: FrameOpCode, completion: (() -> Void)?) {
        let readyEventDictionary: [String: Any] = ["d": ["sessionID": "1", "pingInterval": 30], "event": "ready"]
        guard
            let encodedData = try? JSONSerialization.data(withJSONObject: readyEventDictionary),
            let readyEventStringData = String(data: encodedData, encoding: .utf8)
        else { return }

        if (try? JSONDecoder().decode(WebSocketConnectOperation.self, from: data)) != nil {
            // Connect
            callbackQueue.async { [unowned self] in
                self.delegate?.didReceive(event: .text(readyEventStringData))
            }
        } else if (try? JSONDecoder().decode(WebSocketReconnectOperation.self, from: data)) != nil {
            // Reconnect
            callbackQueue.async { [unowned self] in
                self.delegate?.didReceive(event: .text(readyEventStringData))
            }
        }
    }

    func write(string: String, completion: (() -> Void)?) {

    }
}
