//
//  WebSocketDisconnectContext.swift
//  Notifire
//
//  Created by David Bielik on 01/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

enum WebSocketDisconnectContext: Equatable {
    /// The initial state of the websocket client.
    case initial
    /// Whenever an error occurs
    case error(Error?)
    /// When the server forcefully disconnects this client.
    /// - Parameters:
    ///     - reason (`String`): the human readable reason for the disconnect.
    ///     - code (`WebSocketErrorCode`): the code representing the disconnect reason.
    case disconnect(reason: String, code: WebSocketErrorCode)

    static func == (lhs: WebSocketDisconnectContext, rhs: WebSocketDisconnectContext) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial): return true
        case (.error(let error1), .error(let error2)): return error1 != nil && error2 != nil
        case (.disconnect(let reason1, let code1), .disconnect(let reason2, let code2)): return reason1 == reason2 && code1 == code2
        case (_, _): return false
        }
    }

}
