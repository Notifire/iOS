//
//  DLResetPasswordViewModel.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class DLResetPasswordViewModel: InputValidatingViewModel, UserSessionCreating, DeeplinkResponding, APIErrorProducing, UserErrorProducing {

    // MARK: - Properties
    /// Token from the deeplink.
    let token: String
    var newPassword: String = ""

    let loadingModel = LoadingModel()

    weak var sessionDelegate: UserSessionCreationDelegate?

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: UserErrorProducing
    typealias UserError = EmailTokenError
    var onUserError: ((UserError) -> Void)?

    // MARK: UI
    var headerText: String {
        return "Reset your password"
    }

    var placeholderText: String {
        return "Enter a new password"
    }

    var confirmText: String {
        return "Confirm change"
    }

    // MARK: - Initialization
    required init(apiManager: NotifireAPIManager = NotifireAPIFactory.createAPIManager(), token: String) {
        self.token = token
        super.init(apiManager: apiManager)
    }

    // MARK: - Methods
    func resetPassword() {
        guard allComponentsValidated, !loadingModel.isLoading else { return }
        loadingModel.toggle()

        apiManager.resetPassword(password: newPassword, token: token) { [weak self] result in
            guard let `self` = self else { return }
            self.loadingModel.toggle()

            switch result {
            case .error(.clientError(let clientError)):
                if let emailTokenError = EmailTokenError(rawValue: clientError.code) {
                    self.onUserError?(emailTokenError)
                } else {
                    self.onError?(NotifireAPIError.clientError(clientError))
                }
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                guard response.success, let payload = response.payload else {
                    self.onError?(.unknown)
                    return
                }
                let session = UserSessionManager.createEmailSession(loginSuccessResponse: payload)
                self.sessionDelegate?.didCreate(session: session)
            }
        }
    }
}
