//
//  RegisterSuccessViewModel.swift
//  Notifire
//
//  Created by David Bielik on 16/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class RegisterSuccessViewModel: ViewModelRepresenting {

    enum ResendButtonState {
        case loading
        case finished
    }

    // MARK: - Properties
    let notifireApiManager: NotifireAPIManager
    let email: String
    var resendButtonState: ResendButtonState = .finished {
        didSet {
            onResendButtonStateChange?(resendButtonState)
        }
    }

    // MARK: Callback
    var onResendButtonStateChange: ((ResendButtonState) -> Void)?

    // MARK: - Initialization
    init(apiManager: NotifireAPIManager, email: String) {
        self.notifireApiManager = apiManager
        self.email = email
    }

    // MARK: - Methods
    func resendEmail() {
        guard case .finished = resendButtonState else { return }
        resendButtonState = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let email = self?.email else { return }
            self?.notifireApiManager.sendConfirmEmail(to: email) { _ in
                self?.resendButtonState = .finished
            }
        }
    }
}
