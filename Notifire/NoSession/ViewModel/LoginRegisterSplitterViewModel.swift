//
//  LoginRegisterSplitterViewModel.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class LoginRegisterSplitterViewModel {

    // MARK: - Properties
    let notifireApiManager: NotifireAPIManager
    weak var authenticationProvidersVM: AuthenticationProvidersViewModel?

    // MARK: - Initialization
    init(notifireApiManager: NotifireAPIManager = NotifireAPIManagerFactory.createAPIManager()) {
        self.notifireApiManager = notifireApiManager
    }
}

extension LoginRegisterSplitterViewModel: SSOManagerDelegate {

    func willStart(authenticationAttempt: SSOAuthenticationAttempt) {

    }

    func didStart(authenticationAttempt: SSOAuthenticationAttempt) {

    }

    func didFinish(authenticationAttempt: SSOAuthenticationAttempt) {
        authenticationProvidersVM?.finishAuthenticationFlow(with: authenticationAttempt.provider)
    }
}
