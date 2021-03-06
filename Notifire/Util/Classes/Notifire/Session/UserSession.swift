//
//  UserSession.swift
//  Notifire
//
//  Created by David Bielik on 11/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class AuthenticationProviderData: NSObject {
    let provider: AuthenticationProvider
    @objc dynamic var email: String

    // The user id of the user returned by the external auth providers
    let userID: String?

    init(provider: AuthenticationProvider, email: String, userID: String? = nil) {
        self.provider = provider
        self.email = email
        self.userID = userID
    }
}

class UserSession {

    // MARK: - Properties
    /// The unique integer identifier of a user in the Notifire backend.
    let userID: Int
    /// Used to obtain the access token
    var refreshToken: String
    /// The data from the login provider (e.g. email / userID)
    var providerData: AuthenticationProviderData
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
    init(userID: Int, refreshToken: String, providerData: AuthenticationProviderData) {
        self.userID = userID
        self.refreshToken = refreshToken
        self.providerData = providerData
        self.settings = UserSessionSettings(identifier: String(userID))
    }
}
