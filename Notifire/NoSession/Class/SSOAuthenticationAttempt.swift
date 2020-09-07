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
        case authorizationAlreadyInProgress(SSOAuthenticationAttempt)
        case userCancelled
        case userHasNotSignedIn
        case unableToRetrieveAccessToken
        case unableToRetrieveEmail
        case notHandled
        case failed
        case invalidResponse
        case unknown

        var description: String {
            switch self {
            case .authorizationAlreadyInProgress: return "Another authorization attempt is already in progress."
            case .userCancelled: return "You have cancelled the authorization request."
            case .userHasNotSignedIn: return "You haven't signed in to the external authorization provider."
            case .unableToRetrieveAccessToken: return "Unable to retrieve access token."
            case .unableToRetrieveEmail: return "Unable to retrieve email."
            case .notHandled: return "Authorization prompt wasn't handled."
            case .failed: return "Authorization failed."
            case .invalidResponse: return "Authorization returned invalid response."
            case .unknown: return "Unkown error occured while authorizing with this SSO provider."
            }
        }
    }

    enum AuthenticationState {
        case authenticating
        case error(SSOAuthenticationError)
        case finished(idToken: String, email: String)
    }

    let provider: SSOAuthenticationProvider
    var state: AuthenticationState = .authenticating

    init(provider: SSOAuthenticationProvider) {
        self.provider = provider
    }
}
