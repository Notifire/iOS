//
//  ChangeEmailViewModel.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class ChangeEmailViewModel: InputValidatingViewModel, TitleProviding, SuccessAlertDataProviding, APIErrorProducing {

    // MARK: - Properties
    let userSession: UserSession
    let protectedApiManager: NotifireProtectedAPIManager

    var email: String = ""

    var isFirstAppearance = true

    let loadingModel = LoadingModel()

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?
    /// Called when the onSendChange requests returns a valid response.
    /// - Parameter bool: `true` if the request was succesful.
    var onSendChangeEmailResult: ((Bool) -> Void)?

    // MARK: TitleProviding
    var title: String {
        return "Email"
    }

    // MARK: SuccessAlertDataProviding
    var onSuccess: (() -> Void)?

    var successAlertText: String? {
        return "You have successfully changed your password!"
    }

    // MARK: - Initialization
    init(sessionHandler: UserSessionHandler) {
        self.protectedApiManager = sessionHandler.notifireProtectedApiManager
        self.userSession = sessionHandler.userSession
        super.init()
    }

    // MARK: - Methods
    func sendChangeEmail() {
        guard allComponentsValidated, !loadingModel.isLoading else { return }
        loadingModel.toggle()

        protectedApiManager.sendChangeEmail(to: email) { [weak self] result in
            guard let `self` = self else { return }
            self.loadingModel.toggle()
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                self.onSendChangeEmailResult?(response.success)
            }
        }
    }
}
