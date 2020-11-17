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
    /// The request resulted in an invalid status code
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
        case .unknown: return "Unknown error has occured while communicating with the server."
        case .urlResponseNotCreated: return "URL response couldn't be created."
        case .responseDataIsNil: return "Response data was nil."
        case .invalidStatusCode(let statusCode, _): return "Invalid status code: \(statusCode)"
        case .invalidResponseBody: return "Unexpected response data."
        case .urlSession(let underlyingError):
            let error = underlyingError as NSError
            if error.domain == NSURLErrorDomain {
                return error.localizedDescription
            }
            return "URLSession error: \(underlyingError)"
        }
    }
}

extension NotifireAPIError: Equatable {
    static func == (lhs: NotifireAPIError, rhs: NotifireAPIError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown): return true
        case (.urlResponseNotCreated, .urlResponseNotCreated): return true
        case (.responseDataIsNil, .responseDataIsNil): return true
        case (.invalidStatusCode(let codeL, _), .invalidStatusCode(let codeR, _)): return codeL == codeR
        case (.invalidResponseBody(let typeL, let responseStringL), .invalidResponseBody(let typeR, let responseStringR)): return typeL == typeR && responseStringL == responseStringR
        case (.urlSession(let errorL), .urlSession(let errorR)): return errorL.localizedDescription == errorR.localizedDescription
        case (_, _): return false
        }
    }
}
