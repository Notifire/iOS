//
//  AuthenticationProvider.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Enumeration that contains login / register providers
enum AuthenticationProvider: Hashable, CustomStringConvertible {

    case sso(SSOAuthenticationProvider)
    case email

    // MARK: - Initialization
    init?(providerString: String) {
        if let ssoProvider = SSOAuthenticationProvider(rawValue: providerString) {
            self = .sso(ssoProvider)
        } else if providerString == Self.email.description {
            self = .email
        } else {
            return nil
        }
    }

    init(ssoProvider: SSOAuthenticationProvider) {
        self = .sso(ssoProvider)
    }

    // MARK: - Properties
    /// Returns all providers
    static var providers: [AuthenticationProvider] {
        var result = SSOAuthenticationProvider.safeProviders.map { AuthenticationProvider.sso($0) }
        result.append(.email)
        return result
    }

    var requiresExternalSSO: Bool {
        switch self {
        case .sso: return true
        case .email: return false
        }
    }

    // MARK: CustomStringConvertible
    var description: String {
        switch self {
        case .sso(let provider): return provider.description
        case .email: return "e-mail"
        }
    }

    // MARK: - Functions
    /// Returns the SSO provider if it is available.
    func getExternalSSOProvider() -> SSOAuthenticationProvider? {
        switch self {
        case .sso(let provider): return provider
        case .email: return nil
        }
    }
}
