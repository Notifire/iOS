//
//  Encodable.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

struct EmptyRequestBody: Encodable, Decodable {}

struct RegisterRequestBody: Encodable {
    let email: String
    let password: String
}

struct ResendConfirmRequestBody: Encodable {
    let email: String
}

struct ConfirmAccountRequestBody: Encodable {
    let token: String
}

struct RegisterDeviceRequestBody: Encodable {
    let deviceToken: String
}

struct GenerateAccessTokenRequestBody: Encodable {
    let refreshToken: String
}

struct LoginRequestBody: Encodable {
    let email: String
    let password: String
}

struct LoginProviderRequestBody: Encodable {
    let idToken: String
}

struct ServiceCreationBody: Encodable {
    let name: String
    let image: String
    let levels = Service.Levels(info: true, warning: true, error: true)
}

struct PasswordValidationRequestBody: Encodable {
    let password: String
}

struct ServiceRequestBody: Encodable {
    let name: String
    let uuid: String
    let levels: Service.Levels
}

struct ChangeServiceKeyBody: Encodable {
    let service: Service
    let password: String
}

struct PaginationData {
    let mode: Mode
    let id: String

    /// Pagination mode
    enum Mode: String {
        case before
        case after
        case around
    }

    var asURLQueryItem: URLQueryItem {
        return URLQueryItem(name: mode.rawValue, value: id)
    }
}

struct ChangePasswordRequestBody: Encodable {
    let oldPassword: String
    let newPassword: String
}
