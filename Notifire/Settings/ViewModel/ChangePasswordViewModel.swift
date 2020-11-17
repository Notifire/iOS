//
//  ChangePasswordViewModel.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class ChangePasswordViewModel: InputValidatingViewModel, SuccessAlertDataProviding, TitleProviding, APIErrorProducing, UserErrorProducing {

    // MARK: - Properties
    let sessionHandler: UserSessionHandler

    var oldPassword = ""
    var newPassword = ""
    var newPassword2 = ""

    /// `true` if this was the first appearance of the view
    var isFirstAppearance = true

    let loadingModel = LoadingModel()

    // MARK: TitleProviding
    var title: String {
        return "Password"
    }

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: UserErrorFailable
    typealias UserError = ChangePasswordUserError
    var onUserError: ((ChangePasswordUserError) -> Void)?

    // MARK: SuccessAlertDataProviding
    var onSuccess: (() -> Void)?
    var shouldDismissViewAfterSuccessOk: Bool {
        return true
    }

    var successAlertText: String? {
        return "You have successfully changed your password!"
    }

    // MARK: - Initialization
    init(sessionHandler: UserSessionHandler) {
        self.sessionHandler = sessionHandler
        super.init()
    }

    // MARK: - Public
    func saveNewPassword() {
        guard allComponentsValidated, !loadingModel.isLoading else { return }
        loadingModel.toggle()

        sessionHandler.notifireProtectedApiManager.change(oldPassword: oldPassword, to: newPassword2) { [weak self] result in
            guard let `self` = self else { return }
            self.loadingModel.toggle()
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if let payload = response.payload {
                    self.sessionHandler.updateUserSession(
                        refreshToken: payload.refreshToken,
                        accessToken: payload.accessToken
                    )
                    self.onSuccess?()
                } else if let userError = response.error {
                    self.onUserError?(userError.code)
                }
            }
        }
    }
}
