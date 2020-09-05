//
//  ConfirmEmailViewModel.swift
//  Notifire
//
//  Created by David Bielik on 18/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ConfirmEmailViewModel: APIFailable, UserErrorFailable {

    typealias UserError = VerifyAccountUserError

    // MARK: - Properties
    // MARK: APIFailable
    let notifireApiManager: NotifireAPIManager
    var onError: ((NotifireAPIManager.ManagerResultError) -> Void)?
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
    var onConfirmation: ((NotifireUserSession) -> Void)?

    // MARK: - Initialization
    init(notifireApiManager: NotifireAPIManager = NotifireAPIManagerFactory.createAPIManager(), token: String) {
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
                    let session = NotifireUserSession(refreshToken: verifyAccountSuccessResponse.refreshToken, username: verifyAccountSuccessResponse.username)
                    session.accessToken = verifyAccountSuccessResponse.accessToken
                    self.onConfirmation?(session)
                } else {
                    self.onError?(.server)
                }
            }
        }
    }
}
