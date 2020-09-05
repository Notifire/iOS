//
//  AuthenticationProvider.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Enumeration that contains login / register providers
enum AuthenticationProvider: String, CaseIterable, CustomStringConvertible {
    case apple, google, github, twitter, email

    /// Returns all providers but takes into account the iOS version.
    /// (Ignores Apple Sign in pre iOS 13.0)
    static var providers: [AuthenticationProvider] {
        if #available(iOS 13.0, *) {
            return allCases
        } else {
            return allCases.filter { $0 != .apple }
        }
    }

    var requiresExternalSSO: Bool {
        switch self {
        case .google, .github, .twitter: return true
        case .apple, .email: return false
        }
    }

    /// UIImage used for this provider
    var providerImage: UIImage {
        switch self {
        case .apple: return #imageLiteral(resourceName: "default_service_image").resized(to: CGSize(equal: 18))
        case .email:
            let image = UIImage(imageLiteralResourceName: "envelope_symbol")
            return image.withRenderingMode(.alwaysTemplate)
        case .github: return #imageLiteral(resourceName: "github_icon").resized(to: CGSize(equal: 18)).withRenderingMode(.alwaysTemplate)
        case .google: return #imageLiteral(resourceName: "google_icon").resized(to: CGSize(equal: 17))
        case .twitter: return #imageLiteral(resourceName: "twitter_icon").resized(to: CGSize(equal: 26))
        }
    }

    // MARK: CustomStringConvertible
    var description: String {
        switch self {
        case .apple, .google, .twitter: return rawValue.capitalized
        case .email: return "e-mail"
        case .github: return "GitHub"
        }
    }
}
