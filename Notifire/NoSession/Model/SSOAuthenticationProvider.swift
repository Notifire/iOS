//
//  SSOAuthenticationProvider.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

enum SSOAuthenticationProvider: String, CaseIterable, Equatable, CustomStringConvertible {
    case apple, google
    // case github, twitter

    var description: String {
        switch self {
        case .apple, .google: return rawValue.capitalized
        // case .twitter: return rawValue.capitalized
        // case .github: return "GitHub"
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
}
