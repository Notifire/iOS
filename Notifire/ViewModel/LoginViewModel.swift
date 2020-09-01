//
//  LoginViewModel.swift
//  Notifire
//
//  Created by David Bielik on 28/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

typealias BindableInputValidatingViewModel = InputValidatingViewModel & InputValidatingBindable

final class LoginViewModel: BindableInputValidatingViewModel, APIFailable, UserErrorFailable {

    typealias UserError = LoginUserError

    func keyPath(for value: KeyPaths) -> ReferenceWritableKeyPath<LoginViewModel, String> {
        switch value {
        case .username:
            return \.username
        case .password:
            return \.password
        }
    }

    enum KeyPaths: InputValidatingBindableEnum {
        case username
        case password
    }
    typealias EnumDescribingKeyPaths = KeyPaths

    // MARK: - Properties
    // MARK: APIFailable
    var onError: ((NotifireAPIManager.ManagerResultError) -> Void)?
    // MARK: UserErrorFailable
    var onUserError: ((LoginUserError) -> Void)?

    var loading: Bool = false {
        didSet {
            guard oldValue != loading else { return }
            onLoadingChange?(loading)
        }
    }

    var onLogin: ((NotifireUserSession) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    // MARK: Model
    var username: String = ""
    var password: String = ""

    // MARK: - Methods
    func login() {
        guard componentValidator?.allComponentsValid ?? false else { return }
        loading = true
        notifireApiManager.login(usernameOrEmail: username, password: password) { [weak self] result in
            guard let `self` = self else { return }
            self.loading = false
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if let loginSuccessResponse = response.payload {
                    let session = NotifireUserSession(refreshToken: loginSuccessResponse.refreshToken, username: loginSuccessResponse.username)
                    session.accessToken = loginSuccessResponse.accessToken
                    self.onLogin?(session)
                } else if let loginErrorResponse = response.error {
                    self.onUserError?(loginErrorResponse.code)
                }
            }
        }
    }

    func resendEmail() {
        notifireApiManager.resendConfirmEmail(usernameOrEmail: username) { _ in }
    }

    func canHandle(userError: LoginUserError) -> Bool {
        switch userError {
        case .notVerified: return true
        case .invalidPassword, .invalidUsernameOrEmail: return true
        }
    }

    func shouldHandleManually(userError: UserError) -> Bool {
        switch userError {
        case .notVerified: return true
        case .invalidPassword, .invalidUsernameOrEmail: return false
        }
    }
}
