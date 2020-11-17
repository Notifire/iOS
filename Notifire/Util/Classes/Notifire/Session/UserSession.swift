//
//  UserSession.swift
//  Notifire
//
//  Created by David Bielik on 11/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

struct AuthenticationProviderData {
    let provider: AuthenticationProvider
    let email: String

    // The user id of the user returned by the external auth providers
    let userID: String?
}

class UserSession {

    // MARK: - Properties
    /// The data from the login provider (e.g. email / userID)
    let providerData: AuthenticationProviderData
    /// Used to obtain the access token
    var refreshToken: String
    /// Current device token
    var deviceToken: String?
    /// Current access token
    var accessToken: String?
    /// Users preferences (`UserDefaults`)
    let settings: UserSessionSettings

    // MARK: Computed
    var email: String {
        // sugar
        return providerData.email
    }

    /// `true` if the user is logged in with an external SSO provider.
    var isLoggedWithExternalProvider: Bool {
        switch providerData.provider {
        case .email: return false
        case .sso: return true
        }
    }

    // MARK: - Initialization
    init(refreshToken: String, providerData: AuthenticationProviderData) {
        self.refreshToken = refreshToken
        self.providerData = providerData
        self.settings = UserSessionSettings(identifier: providerData.email)
    }
}
