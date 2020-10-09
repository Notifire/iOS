//
//  Decodable.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

// MARK: - Success Response
struct NotifireAPIPlainSuccessResponse: Decodable {
    let success: Bool
}

/// A type that conforms to this protocol is able to represent some sort of error (used by different enums for each request)
protocol UserErrorRepresenting: CustomStringConvertible {}
typealias DecodableUserErrorRepresenting = UserErrorRepresenting & Decodable

struct NotifireAPIUserError<RequestSpecificError: DecodableUserErrorRepresenting>: Decodable {
    let code: RequestSpecificError
    let message: String
}

struct NotifireAPISuccessResponse<Payload: Decodable, RequestSpecificError: DecodableUserErrorRepresenting>: Decodable {
    let success: Bool
    let payload: Payload?
    let error: NotifireAPIUserError<RequestSpecificError>?
}

// MARK: - /register
typealias RegisterResponse = NotifireAPIPlainSuccessResponse

// MARK: - /register/confirm
struct VerifyAccountSuccessResponse: Decodable {
    let email: String
    let refreshToken: String
    let accessToken: String
}

enum VerifyAccountUserError: Int, DecodableUserErrorRepresenting {
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
struct CheckValidityResponse: Decodable {
    let valid: Bool
}

// MARK: - /access
struct GenerateAccessTokenResponse: Decodable {
    let accessToken: String?
}

// MARK: - /register/device
typealias RegisterDeviceResponse = EmptyRequestBody

// MARK: - /account/login
struct LoginSuccessResponse: Decodable {
    let email: String
    let refreshToken: String
    let accessToken: String
}

enum LoginUserError: Int, DecodableUserErrorRepresenting {
    case invalidEmail = 1
    case invalidPassword = 2
    case notVerified = 3

    var description: String {
        switch self {
        case .invalidEmail: return "The email you've entered was not recognized by the server."
        case .invalidPassword: return "The password you've entered was invalid."
        case .notVerified: return "Your account is not verified yet! Check your email."
        }
    }
}

typealias LoginResponse = NotifireAPISuccessResponse<LoginSuccessResponse, LoginUserError>

// MARK: - /account/login/{provider}
struct SSOLoginResponse: Decodable {
    let success: Bool
    let payload: LoginSuccessResponse
}

// MARK: - /account/send/reset/password
typealias SendResetPasswordResponse = NotifireAPIPlainSuccessResponse

// MARK: - /services
typealias ServicesResponse = [ServiceSnippet]

typealias ServiceCreationResponse = Service

enum ServiceUpdateError: Int {
    case oldLocalUpdatedAt
    case serviceDoesntExist
}

typealias ServiceUpdateResponse = Service

typealias APIKeyChangeResponse = Service
