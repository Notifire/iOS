//
//  ConfirmEmailViewModel.swift
//  Notifire
//
//  Created by David Bielik on 18/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class ConfirmEmailViewModel: ViewModelRepresenting, APIErrorProducing, UserErrorProducing, DeeplinkResponding, UserSessionCreating {

    typealias UserError = ConfirmAccountUserError

    // MARK: - Properties
    weak var sessionDelegate: UserSessionCreationDelegate?

    // MARK: APIErrorProducing
    let notifireApiManager: NotifireAPIManager
    var onError: ((NotifireAPIError) -> Void)?
    var onUserError: ((ConfirmAccountUserError) -> Void)?

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
    required init(apiManager: NotifireAPIManager, token: String) {
        self.token = token
        self.notifireApiManager = apiManager
    }

    // MARK: - Methods
    func confirmAccount() {
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
                } else if let confirmAccountSuccessResponse = response.payload {
                    let session = UserSessionManager.createEmailSession(loginSuccessResponse: confirmAccountSuccessResponse)
                    self.sessionDelegate?.didCreate(session: session)
                } else {
                    self.onError?(.unknown)
                }
            }
        }
    }
}
