//
//  LoginRegisterSplitterViewModel.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class LoginRegisterSplitterViewModel: ViewModelRepresenting, APIErrorProducing, UserErrorProducing {

    // MARK: - Properties
    let notifireApiManager: NotifireAPIManager
    weak var authenticationProvidersVM: AuthenticationProvidersViewModel?

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: UserErrorFailable
    typealias UserError = SSOAuthenticationAttempt.SSOAuthenticationError
    var onUserError: ((SSOAuthenticationAttempt.SSOAuthenticationError) -> Void)?

    // MARK: Actions
    /// Invoked when a NotifireUserSession becomes available.
    /// (whenever the user logs in somehow)
    var onLogin: ((UserSession) -> Void)?

    // MARK: Private
    private var loginInProgress = false

    // MARK: - Initialization
    init(notifireApiManager: NotifireAPIManager = NotifireAPIFactory.createAPIManager()) {
        self.notifireApiManager = notifireApiManager
    }

    // MARK: - Methods
    func login(token: String, ssoProvider: SSOAuthenticationProvider, completion: @escaping (() -> Void)) {
        guard !loginInProgress else { return }
        loginInProgress = true

        notifireApiManager.login(token: token, ssoProvider: ssoProvider) { [weak self] result in
            guard let `self` = self else { return }
            self.loginInProgress = false
            completion()
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                let provider = AuthenticationProvider(ssoProvider: ssoProvider)
                let providerData = AuthenticationProviderData(provider: provider, email: response.payload.email, userID: token)
                let session = UserSession(refreshToken: response.payload.refreshToken, providerData: providerData)
                session.accessToken = response.payload.accessToken
                self.onLogin?(session)
            }
        }
    }
}

// MARK: - SSOManagerDelegate
extension LoginRegisterSplitterViewModel: SSOManagerDelegate {

    func willStart(authenticationAttempt: SSOAuthenticationAttempt) {

    }

    func didStart(authenticationAttempt: SSOAuthenticationAttempt) {

    }

    func didFinish(authenticationAttempt: SSOAuthenticationAttempt) {
        switch authenticationAttempt.state {
        case .authenticating:
            authenticationProvidersVM?.finishAuthenticationFlow(with: authenticationAttempt.provider)
        case .error(let userError):
            authenticationProvidersVM?.finishAuthenticationFlow(with: authenticationAttempt.provider)
            // Delay the user error alert for UI smoothness
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { [weak self] in
                // check if alerting is still relevant
                guard !(self?.authenticationProvidersVM?.ssoManager.attemptInProgress ?? true) else { return }
                // alert the user of his error
                self?.onUserError?(userError)
            }
        case .finished(let idToken):
            login(token: idToken, ssoProvider: authenticationAttempt.provider) { [weak self] in
                self?.authenticationProvidersVM?.finishAuthenticationFlow(with: authenticationAttempt.provider)
            }
        }
    }
}
