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
    /// The request resulted in a status code 400
    /// - Parameters:
    ///     - Int: the status code
    ///     - String?:  the response body containg the automated format error message
    case invalidStatusCode(Int, String?)
    case invalidResponseBody(Decodable.Type, String)
    case urlSession(error: Error)

    public var description: String {
        switch self {
        case .unknown: return "unknown"
        case .urlResponseNotCreated: return "urlResponseNotCreated"
        case .responseDataIsNil: return "responseDataIsNil"
        case .invalidStatusCode(let statusCode, let responseBody): return "invalidStatusCode statusCode={\(statusCode)} | responseBody={\(responseBody ?? "empty-response-body")}"
        case .invalidResponseBody(let bodyType, let actualData): return "invalidResponseBody expectedResponseBodyType={\(bodyType)} | actualResponseData={\(actualData)}"
        case .urlSession(let underlyingError): return "urlSessionError underlyingError={\(underlyingError)}"
        }
    }

    /// Returns a message that is displayed to the user if this error occurs
    public var userFriendlyMessage: String {
        switch self {
        case .unknown: return "unknown"
        case .urlResponseNotCreated: return "Url response couldn't be created"
        case .responseDataIsNil: return "Response data was nil"
        case .invalidStatusCode(let statusCode, let responseBody): return "Invalid status code: \(statusCode) | response body: \(responseBody ?? "empty-response-body")"
        case .invalidResponseBody(let bodyType, let actualData): return "Couldn't match \(actualData) with \(bodyType)"
        case .urlSession(let underlyingError): return "URLSession error: \(underlyingError)"
        }
    }

}
