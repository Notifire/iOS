//
//  AuthenticationProvider.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

enum SSOAuthenticationProvider: String, CaseIterable, Equatable, CustomStringConvertible {
    case apple, google, github, twitter

    var description: String {
        switch self {
        case .apple, .google, .twitter: return rawValue.capitalized
        case .github: return "GitHub"
        }
    }

    /// Returns all SSO providers but takes into account the iOS version.
    /// (Ignores Apple Sign in pre iOS 13.0)
    static var safeProviders: [SSOAuthenticationProvider] {
        if #available(iOS 13.0, *) {
            return allCases
        } else {
            return allCases.filter { $0 != .apple }
        }
    }

    /// The image (icon) associated with this SSO provider
    var image: UIImage {
        switch self {
        case .apple: return #imageLiteral(resourceName: "default_service_image").resized(to: CGSize(equal: 18))
        case .github: return #imageLiteral(resourceName: "github_icon").resized(to: CGSize(equal: 18)).withRenderingMode(.alwaysTemplate)
        case .google: return #imageLiteral(resourceName: "google_icon").resized(to: CGSize(equal: 17))
        case .twitter: return #imageLiteral(resourceName: "twitter_icon").resized(to: CGSize(equal: 26))
        }
    }
}

/// Enumeration that contains login / register providers
enum AuthenticationProvider: Hashable, CustomStringConvertible {

    case sso(SSOAuthenticationProvider)
    case email

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

    /// UIImage used for this provider
    var providerImage: UIImage {
        switch self {
        case .sso(let provider): return provider.image
        case .email:
            let image = UIImage(imageLiteralResourceName: "envelope_symbol")
            return image.withRenderingMode(.alwaysTemplate)
        }
    }

    // MARK: CustomStringConvertible
    var description: String {
        switch self {
        case .sso(let provider): return provider.description
        case .email: return "e-mail"
        }
    }

    /// Returns the SSO provider if it is available.
    func getExternalSSOProvider() -> SSOAuthenticationProvider? {
        switch self {
        case .sso(let provider): return provider
        case .email: return nil
        }
    }
}
