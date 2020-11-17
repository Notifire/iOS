//
//  ConfirmEmailViewModel.swift
//  Notifire
//
//  Created by David Bielik on 18/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ConfirmEmailViewModel: ViewModelRepresenting, APIErrorProducing, UserErrorProducing {

    typealias UserError = VerifyAccountUserError

    // MARK: - Properties
    // MARK: APIErrorProducing
    let notifireApiManager: NotifireAPIManager
    var onError: ((NotifireAPIError) -> Void)?
    var onUserError: ((VerifyAccountUserError) -> Void)?

    // MARK: Model
    let token: String

    var loading: Bool = false {
        didSet {
            guard oldValue != loading else { return }
            onLoadingChange?(loading)
        }
    }

    // MARK: Callbacks
    var onLoadingChange: ((Bool) -> Void)?
    var onConfirmation: ((UserSession) -> Void)?

    // MARK: - Initialization
    init(notifireApiManager: NotifireAPIManager = NotifireAPIFactory.createAPIManager(), token: String) {
        self.notifireApiManager = notifireApiManager
        self.token = token
    }

    // MARK: - Methods
    func confirmAccount(_ btn: UIButton) {
        loading = true
        notifireApiManager.confirmAccount(emailToken: token) { [weak self] result in
            guard let `self` = self else { return }
            self.loading = false
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if let userError = response.error {
                    self.onUserError?(userError.code)
                } else if let verifyAccountSuccessResponse = response.payload {
                    let providerData = AuthenticationProviderData(provider: .email, email: verifyAccountSuccessResponse.email, userID: nil)
                    let session = UserSession(refreshToken: verifyAccountSuccessResponse.refreshToken, providerData: providerData)
                    session.accessToken = verifyAccountSuccessResponse.accessToken
                    self.onConfirmation?(session)
                } else {
                    self.onError?(.unknown)
                }
            }
        }
    }
}
