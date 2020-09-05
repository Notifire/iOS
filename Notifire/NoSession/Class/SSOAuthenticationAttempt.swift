//
//  SSOAuthenticationAttempt.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class SSOAuthenticationAttempt {

    enum SSOAuthenticationError: Error {
        case authenticationAlreadyInProgress(SSOAuthenticationAttempt)
        case userCancelled
        case userHasNotSignedIn
        case unableToRetrieveAccessToken
        case unknown
    }

    enum AuthenticationState {
        case authenticating
        case error(SSOAuthenticationError)
        case finished(accessToken: String)
    }

    let provider: AuthenticationProvider
    var state: AuthenticationState = .authenticating

    init(provider: AuthenticationProvider) {
        self.provider = provider
    }
}
