//
//  LoginViewModel.swift
//  Notifire
//
//  Created by David Bielik on 28/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

final class LoginViewModel: InputValidatingViewModel, APIErrorProducing, UserErrorProducing {

    typealias UserError = LoginUserError

    // MARK: - Properties
    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?
    // MARK: UserErrorFailable
    var onUserError: ((LoginUserError) -> Void)?

    var loading: Bool = false {
        didSet {
            guard oldValue != loading else { return }
            onLoadingChange?(loading)
        }
    }

    var onLogin: ((UserSession) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    // MARK: Model
    var email: String = ""
    var password: String = ""

    // MARK: - Methods
    func login() {
        guard allComponentsValidated else { return }
        loading = true
        apiManager.login(email: email, password: password) { [weak self] result in
            guard let `self` = self else { return }
            self.loading = false
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if let loginSuccessResponse = response.payload {
                    let session = UserSessionManager.createEmailSession(loginSuccessResponse: loginSuccessResponse)
                    self.onLogin?(session)
                } else if let loginErrorResponse = response.error {
                    self.onUserError?(loginErrorResponse.code)
                }
            }
        }
    }

    func resendEmail() {
        apiManager.sendConfirmEmail(to: email) { _ in }
    }

    func shouldHandleManually(userError: UserError) -> Bool {
        switch userError {
        case .accountNotVerified: return true
        case .wrongPasswordOrAccountNotExist, .emailAlreadyExistsInTheSystem: return false
        }
    }
}
