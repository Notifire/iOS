//
//  DeeplinkViewModelRepresenting.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// The ViewModel representing all ViewModels used in simple deeplinks.
protocol DeeplinkViewModelRepresenting: DeeplinkResponding, UserSessionCreating, APIErrorProducing, UserErrorProducing {

    /// The text that is used in headerLabel of the respective `DeeplinkedAutoVMViewController`
    var headerText: String { get }
    /// The text that is used in the loadingLabe
    var loadingText: String { get }
    /// Current ViewState information + callbacks.
    var stateModel: StateModel<DeeplinkViewState> { get }

    /// Start the main action of this deeplink ViewModel (e.g. do confirm account request)
    func startMainDeeplinkAction()

    /// The API request to call when using this viewModel
    func apiRequestFunction() -> ((String, @escaping NotifireAPIManager.Callback<NotifireAPISuccessResponseWithLoginData>) -> Void)
}

extension DeeplinkViewModelRepresenting {
    var loadingText: String {
        return "Confirming..."
    }
}

// MARK: Default implementation for startMainDeeplinkAction
// Use this in all Deeplink VMs (make sure to set UserError to EmailTokenError)
extension DeeplinkViewModelRepresenting where UserError == EmailTokenError {

    func startMainDeeplinkAction() {
        guard stateModel.state == .initial || stateModel.state == .failed else { return }
        stateModel.state = .confirming

        apiRequestFunction()(token) { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .error(.clientError(let clientError)):
                self.stateModel.state = .failed
                if clientError.errorType == .email, let emailTokenError = EmailTokenError(rawValue: clientError.code) {
                    self.onUserError?(emailTokenError)
                } else {
                    self.onError?(NotifireAPIError.clientError(clientError))
                }
            case .error(let error):
                self.stateModel.state = .failed
                self.onError?(error)
            case .success(let response):
                guard response.success, let payload = response.payload else {
                    self.onError?(.unknown)
                    return
                }
                let session = UserSessionManager.createEmailSession(loginSuccessResponse: payload)
                self.stateModel.state = .success
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                    self?.sessionDelegate?.didCreate(session: session)
                }
            }
        }
    }
}
