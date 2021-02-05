//
//  WebSocketErrorCode.swift
//  Notifire
//
//  Created by David Bielik on 01/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Represents the error code returned when a `WebSocket` session closes.
enum WebSocketErrorCode: Int {
    /// The user's network interface contains 0 elements.
    /// Invoked on Airplane Mode or when the user has no internet connection.
    case noInternetConnection = 1
    /// Formatting error, usually invoked from Cerberus.
    case invalidFormat = 1000
    /// User's access token is no longer valid.
    case invalidAccessToken = 1001
    /// Session id has expired.
    case expiredSessionID = 1002

    /// Catch-all for other potential error codes.
    case unknown = -1

    // MARK: - Initialization
    init(code: Int) {
        self = WebSocketErrorCode(rawValue: code) ?? .unknown
    }
}
