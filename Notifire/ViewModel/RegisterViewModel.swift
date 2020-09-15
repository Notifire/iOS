//
//  RegisterViewModel.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

final class RegisterViewModel: BindableInputValidatingViewModel, APIFailable {

    // MARK: - Properties
    enum KeyPaths: InputValidatingBindableEnum {
        case email
        case password
    }

    typealias EnumDescribingKeyPaths = KeyPaths

    // MARK: APIFailable
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: Model
    var email: String = ""
    var password: String = ""

    var loading: Bool = false {
        didSet {
            guard oldValue != loading else { return }
            onLoadingChange?(loading)
        }
    }

    var onRegister: (() -> Void)?
    var onLoadingChange: ((Bool) -> Void)?

    // MARK: - Methods
    func register() {
        guard allComponentsValidated else { return }
        loading = true
        notifireApiManager.register(email: email, password: password) { [weak self] result in
            guard let `self` = self else { return }
            self.loading = false
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                self.onRegister?()
            }
        }
    }

    func keyPath(for value: KeyPaths) -> ReferenceWritableKeyPath<RegisterViewModel, String> {
        switch value {
        case .email:
            return \.email
        case .password:
            return \.password
        }
    }
}
