//
//  NotifireAPIDecodable.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

typealias NotifireAPIDecodable = Decodable      // represents decodable ResponseBody


// MARK: - Success Response

struct NotifireAPIPlainSuccessResponse: NotifireAPIDecodable {
    let success: Bool
}

/// A type that conforms to this protocol is able to represent some sort of error (used by different enums for each request)
protocol UserErroRepresenting: NotifireAPIDecodable, CustomStringConvertible {}

struct NotifireAPIUserError<RequestSpecificError: UserErroRepresenting>: NotifireAPIDecodable {
    let code: RequestSpecificError
    let message: String
}

struct NotifireAPISuccessResponse<Payload: NotifireAPIDecodable, RequestSpecificError: UserErroRepresenting>: NotifireAPIDecodable {
    let success: Bool
    let payload: Payload?
    let error: NotifireAPIUserError<RequestSpecificError>?
}

// MARK: - /register
typealias RegisterResponse = NotifireAPIPlainSuccessResponse

// MARK: - /register/confirm
struct VerifyAccountSuccessResponse: NotifireAPIDecodable {
    let username: String
    let refreshToken: String
    let accessToken: String
}

enum VerifyAccountUserError: Int, UserErroRepresenting {
    case alreadyVerified = 1
    case expired = 2
    
    var description: String {
        switch self {
        case .alreadyVerified: return "This account is verified already!"
        case .expired: return "The verification link has expired."
        }
    }
}

typealias VerifyAccountResponse = NotifireAPISuccessResponse<VerifyAccountSuccessResponse, VerifyAccountUserError>

// MARK: - /account/send/confirm
typealias ResendConfirmResponse = NotifireAPIPlainSuccessResponse

// MARK: - /check
struct CheckValidityResponse: NotifireAPIDecodable {
    let valid: Bool
}

// MARK: - /access
struct GenerateAccessTokenResponse: NotifireAPIDecodable {
    let accessToken: String?
}

// MARK: - /register/device
typealias RegisterDeviceResponse = EmptyRequestBody

// MARK: - /login
struct LoginSuccessResponse: NotifireAPIDecodable {
    let username: String
    let refreshToken: String
    let accessToken: String
}

enum LoginUserError: Int, UserErroRepresenting {
    case invalidUsernameOrEmail = 1
    case invalidPassword = 2
    case notVerified = 3
    
    var description: String {
        switch self {
        case .invalidUsernameOrEmail: return "Username or email you've entered was not recognized by the server."
        case .invalidPassword: return "The password you've entered was invalid."
        case .notVerified: return "Your account is not verified yet! Check your email."
        }
    }
}

typealias LoginResponse = NotifireAPISuccessResponse<LoginSuccessResponse, LoginUserError>

// MARK: - /services
typealias ServicesResponse = [Service]

typealias ServiceCreationResponse = Service

enum ServiceUpdateError: Int {
    case oldLocalUpdatedAt
    case serviceDoesntExist
}

typealias ServiceUpdateResponse = Service

typealias APIKeyChangeResponse = Service
