//
//  DLChangeEmailViewModel.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class DLChangeEmailViewModel: DeeplinkViewModelRepresenting {

    // MARK: - Properties
    let apiManager: NotifireAPIManager
    let token: String

    let stateModel = StateModel(defaultValue: DeeplinkViewState.initial)

    // MARK: UI
    var headerText: String { return "Change e-mail" }

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
        return apiManager.changeEmail(token:completion:)
    }
}
