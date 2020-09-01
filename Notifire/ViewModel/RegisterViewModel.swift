//
//  RegisterViewModel.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class RegisterViewModel: InputValidatingViewModel, APIFailable {

    // MARK: - Properties
    // MARK: APIFailable
    var onError: ((NotifireAPIManager.ManagerResultError) -> Void)?

    // MARK: Model
    var username: String = ""
    var email: String = ""
    var password: String = ""

    enum RegisterResult {
        case success
        case failed
        case networkError
        case serverError
    }

    // MARK: - Methods
    func register(completionHandler: @escaping ((RegisterResult) -> Void)) {
        notifireApiManager.register(username: username, email: email, password: password) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success(let response):
                if response.success {
                    completionHandler(.success)
                } else {
                    completionHandler(.failed)
                }
            }
        }
    }
}
