//
//  NotifireAPIError.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

enum NotifireAPIError: Error, CustomStringConvertible {
    case unknown
    case urlResponseNotCreated
    case responseDataIsNil
    case invalidStatusCode(Int)
    case invalidResponseBody(NotifireAPIDecodable.Type)
    case urlsession(error: Error)

    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .urlResponseNotCreated: return "Url response couldn't be created"
        case .responseDataIsNil: return "Response data was nil"
        case .invalidStatusCode(let statusCode): return "Invalid status code: \(statusCode)"
        case .invalidResponseBody(let bodyType): return "Couldn't match response body with \(bodyType)"
        case .urlsession(let underlyingError): return "URLSession error: \(underlyingError)"
        }
    }
}
