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

// MARK: Login Data Response
struct LoginDataResponse: Decodable {
    let email: String
    let refreshToken: String
    let accessToken: String
}

struct NotifireAPISuccessResponseWithLoginData: Decodable {
    let success: Bool
    let payload: LoginDataResponse?
}

// MARK: - /version
struct AppVersionResponse: Codable, Equatable {
    let forceUpdate: Bool
    let latestVersion: String
}

// MARK: - /register
typealias RegisterResponse = NotifireAPIPlainSuccessResponse

// MARK: - /register/confirm
typealias ConfirmAccountResponse = NotifireAPISuccessResponseWithLoginData

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

// MARK: - /account/device
typealias RegisterDeviceResponse = EmptyRequestBody

// MARK: - /account/login
typealias LoginSuccessResponse = LoginDataResponse

enum LoginUserError: Int, DecodableUserErrorRepresenting {
    case wrongPasswordOrAccountNotExist = 1
    case accountNotVerified = 2
    /// This error can be triggered when a user attempts to log in with an SSO provider while already having an account created with his email.
    case emailAlreadyExistsInTheSystem = 3

    var description: String {
        switch self {
        case .wrongPasswordOrAccountNotExist: return "You have entered a wrong password or this account doesn't exist."
        case .accountNotVerified: return "Your account is not verified yet! Check the link we've sent to your email."
        case .emailAlreadyExistsInTheSystem: return "This email is already associated to an account provided by Notifire. Please log in with your password."
        }
    }
}

typealias LoginResponse = NotifireAPISuccessResponse<LoginSuccessResponse, LoginUserError>

// MARK: - /account/login/{provider}
typealias SSOLoginResponse = LoginResponse

// MARK: - /account/password
struct ChangePasswordResponsePayload: Decodable {
    let refreshToken: String
    let accessToken: String
}

enum ChangePasswordUserError: Int, DecodableUserErrorRepresenting {
    case wrongPassword = 1
    case sameOldAndNewPassword = 2

    var description: String {
        switch self {
        case .wrongPassword: return "Your current password was wrong. Please try again."
        case .sameOldAndNewPassword: return "Your new password must be different from your old one!"
        }
    }
}

typealias ChangePasswordResponse = NotifireAPISuccessResponse<ChangePasswordResponsePayload, ChangePasswordUserError>

// MARK: - /account/reset/password
typealias ResetPasswordResponse = NotifireAPISuccessResponseWithLoginData

// MARK: - /account/send/change/email
typealias SendChangeEmailResponse = NotifireAPIPlainSuccessResponse

// MARK: - /account/change/email
typealias ChangeEmailResponse = NotifireAPISuccessResponseWithLoginData

// MARK: - /account/send/reset/password
typealias SendResetPasswordResponse = NotifireAPIPlainSuccessResponse

// MARK: - /services
typealias ServicesResponse = [ServiceSnippet]

typealias SyncServicesResponse = [ServiceChangeEvent]

// MARK: - /service
struct ServiceGetResponse: Decodable {
    let success: Bool
    let service: Service?
}

typealias ServiceCreationResponse = Service

enum ServiceUpdateError: Int {
    case oldLocalUpdatedAt
    case serviceDoesntExist
}

typealias ServiceUpdateResponse = NotifireAPIPlainSuccessResponse

typealias APIKeyChangeResponse = Service
