//
//  SSOAuthenticationAttempt.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class SSOAuthenticationAttempt {

    enum SSOAuthenticationError: Error, UserErrorRepresenting {
        case authenticationAlreadyInProgress(SSOAuthenticationAttempt)
        case userCancelled
        case userHasNotSignedIn
        case unableToRetrieveAccessToken
        case unknown

        var description: String {
            switch self {
            case .authenticationAlreadyInProgress: return "Another authentication attempt is already in progress."
            case .userCancelled: return "The user has cancelled the authentication request."
            case .userHasNotSignedIn: return "The user hasn't signed in."
            case .unableToRetrieveAccessToken: return "Unable to retrieve access token."
            case .unknown: return "Unkown error occured while authenticating with this SSO provider."
            }
        }
    }

    enum AuthenticationState {
        case authenticating
        case error(SSOAuthenticationError)
        case finished(accessToken: String)
    }

    let provider: SSOAuthenticationProvider
    var state: AuthenticationState = .authenticating

    init(provider: SSOAuthenticationProvider) {
        self.provider = provider
    }
}
