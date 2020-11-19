//
//  ForgotPasswordViewModel.swift
//  Notifire
//
//  Created by David Bielik on 03/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

final class ForgotPasswordViewModel: InputValidatingViewModel, APIErrorProducing {

    // MARK: - Properties
    var email: String

    var loading: Bool = false {
        didSet {
            guard oldValue != loading else { return }
            onLoadingChange?(loading)
        }
    }

    var onLoadingChange: ((Bool) -> Void)?
    var onSendEmailSuccess: (() -> Void)?

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: - Initialization
    init(maybeEmail: String, notifireAPIManager: NotifireAPIManager = NotifireAPIFactory.createAPIManager()) {
        self.email = Self.isEmail(string: maybeEmail) ? maybeEmail : ""
        super.init(apiManager: notifireAPIManager)
    }

    // MARK: - Private
    /// Determines if the string param is a valid email.
    private static func isEmail(string: String) -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", Regex.email).evaluate(with: string)
    }

    // MARK: - Methods
    /// Sends a request for password reset email.
    func sendResetPasswordEmail() {
        guard componentValidator?.allComponentsValid ?? false else { return }
        loading = true
        apiManager.sendResetPassword(email: email) { [weak self] result in
            guard let `self` = self else { return }
            self.loading = false
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if response.success {
                    self.onSendEmailSuccess?()
                }
            }
        }
    }

    // MARK: - Public
    let onSendEmailSuccessTitle: String = "Check your inbox!"
    let onSendEmailSuccessText: String = "If there is an account associated with this email address, you will receive a link that will let you reset your password."
}
