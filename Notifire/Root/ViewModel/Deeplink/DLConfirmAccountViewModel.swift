//
//  DLConfirmAccountViewModel.swift
//  Notifire
//
//  Created by David Bielik on 18/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class DLConfirmAccountViewModel: DeeplinkViewModelRepresenting {

    // MARK: - Properties
    let apiManager: NotifireAPIManager
    let token: String

    let stateModel = StateModel(defaultValue: DeeplinkViewState.initial)

    // MARK: UI
    var headerText: String { return "Account verification" }

    // MARK: UserSessionCreating
    weak var sessionDelegate: UserSessionCreationDelegate?

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: UserErrorProducing
    typealias UserError = EmailTokenError
    var onUserError: ((EmailTokenError) -> Void)?

    // MARK: - Initialization
    required init(apiManager: NotifireAPIManager, token: String) {
       self.apiManager = apiManager
       self.token = token
    }

    // MARK: - Methods
    /// Confirm email change
    func apiRequestFunction() -> ((String, @escaping NotifireAPIBaseManager.Callback<NotifireAPISuccessResponseWithLoginData>) -> Void) {
        return apiManager.confirmAccount(emailToken:completion:)
    }
}
