//
//  ClientError.swift
//  Notifire
//
//  Created by David Bielik on 24/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Represent any 40x response body.
struct ClientError: Decodable, Equatable {
    let code: Int
    let message: String
    let errorType: ErrorType

    enum ErrorType: String, Decodable {
        case auth
        case email
    }

    private enum CodingKeys: String, CodingKey {
        case code = "errorCode", message = "errorMessage", errorType = "errorType"
    }
}
