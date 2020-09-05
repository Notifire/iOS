//
//  LoginRegisterSplitterViewModel.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class LoginRegisterSplitterViewModel: APIFailable, UserErrorFailable {

    // MARK: - Properties
    let notifireApiManager: NotifireAPIManager
    weak var authenticationProvidersVM: AuthenticationProvidersViewModel?

    // MARK: APIFailable
    var onError: ((NotifireAPIManager.ManagerResultError) -> Void)?

    // MARK: UserErrorFailable
    typealias UserError = SSOAuthenticationAttempt.SSOAuthenticationError
    var onUserError: ((SSOAuthenticationAttempt.SSOAuthenticationError) -> Void)?

    // MARK: Actions
    /// Invoked when a NotifireUserSession becomes available.
    /// (whenever the user logs in somehow)
    var onLogin: ((NotifireUserSession) -> Void)?

    // MARK: Private
    private var loginInProgress = false

    // MARK: - Initialization
    init(notifireApiManager: NotifireAPIManager = NotifireAPIManagerFactory.createAPIManager()) {
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
                let session = NotifireUserSession(refreshToken: response.refreshToken, email: response.email)
                session.accessToken = response.accessToken
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
            onUserError?(userError)
        case .finished(let idToken):
            login(token: idToken, ssoProvider: authenticationAttempt.provider) { [weak self] in
                self?.authenticationProvidersVM?.finishAuthenticationFlow(with: authenticationAttempt.provider)
            }
        }
    }
}
