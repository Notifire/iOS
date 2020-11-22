//
//  NotifireAPIEndpoint.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

/// Enumeration of unprotected endpoints
enum NotifireAPIEndpoint: String, CustomStringConvertible, CaseIterable {
    case version = "/version"
    case register = "/account/register"
    case check = "/account/check"
    case resendConfirm = "/account/send/confirm"
    case confirmAccount = "/account/confirm"
    case login = "/account/login"
    case resetPassword = "/account/reset/password"
    case sendResetPassword = "/account/send/reset/password"
    case changeEmail = "/account/change/email"
    case revertEmail = "/account/revert/email"

    var description: String {
        return rawValue
    }

    /// Return the endpoint string for each `SSOAuthenticationProvider`
    static func login(ssoProvider: SSOAuthenticationProvider) -> String {
        return Self.login.description + "/" + ssoProvider.rawValue
    }
}

enum NotifireProtectedAPIEndpoint: String, CustomStringConvertible {
    case generateAccessToken = "/account/access"
    case registerDevice = "/account/register/device"
    case logout = "/account/logout"
    case services = "/services"
    case service = "/service"
    case servicesSync = "/services/sync"
    case serviceKey = "/service/key"
    case password = "/account/password"
    case sendChangeEmail = "/account/send/change/email"

    var description: String {
        return rawValue
    }

    /// Return the endpoint string for a GET /service request
    static func service(id: Int) -> String {
        return Self.service.description + "/id/" + "\(id)"
    }
}
