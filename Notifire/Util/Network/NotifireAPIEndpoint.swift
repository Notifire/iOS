//
//  NotifireAPIEndpoint.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

enum NotifireAPIEndpoint: String, CustomStringConvertible {
    case register = "/account/register"
    case check = "/account/check"
    case resendConfirm = "/account/resend"
    case confirmAccount = "/account/confirm"
    case login = "/account/login"
    case sendResetPassword = "/account/send/reset/password"

    var description: String {
        return rawValue
    }

    /// Return the endpoint for each provider
    static func login(ssoProvider: SSOAuthenticationProvider) -> String {
        return Self.login.description + "/" + ssoProvider.rawValue
    }
}

enum NotifireProtectedAPIEndpoint: String, CustomStringConvertible {
    case generateAccessToken = "/account/access"
    case registerDevice = "/account/device"
    case services = "/services"
    case service = "/service"
    case serviceKey = "/service/key"
    case password = "/password"

    var description: String {
        return rawValue
    }
}
