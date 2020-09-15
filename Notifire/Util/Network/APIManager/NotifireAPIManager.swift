//
//  NotifireAPIManager.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class NotifireAPIManager: NotifireAPIBaseManager {

    // MARK: - /register
    func register(email: String, password: String, completion: @escaping Callback<RegisterResponse>) {
        let body = RegisterRequestBody(email: email, password: password)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.register, method: .post, body: body, parameters: nil)
        let requestContext = URLRequestContext(responseBodyType: RegisterResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/send/confirm
    func sendConfirmEmail(to email: String, completion: @escaping Callback<ResendConfirmResponse>) {
        let parameters = [
            "email": email
        ]
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.resendConfirm, method: .get, body: nil as EmptyRequestBody?, parameters: parameters)
        let requestContext = URLRequestContext(responseBodyType: ResendConfirmResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/confirm
    func confirmAccount(emailToken: String, completion: @escaping Callback<VerifyAccountResponse>) {
        let body = ConfirmAccountRequestBody(token: emailToken)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.confirmAccount, method: .put, body: body, parameters: nil)
        let requestContext = URLRequestContext(responseBodyType: VerifyAccountResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/check
    func checkValidity(option: CheckValidityOption, input: String, completion: @escaping Callback<CheckValidityResponse>) {
        let parameters = [option.rawValue: input]
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.check, method: .get, body: nil as EmptyRequestBody?, parameters: parameters)
        let requestContext = URLRequestContext(responseBodyType: CheckValidityResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/login
    func login(email: String, password: String, completion: @escaping Callback<LoginResponse>) {
        let body = LoginRequestBody(email: email, password: password)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.login, method: .post, body: body, parameters: nil)
        let requestContext = URLRequestContext(responseBodyType: LoginResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/login/{provider}
    func login(token: String, ssoProvider: SSOAuthenticationProvider, completion: @escaping Callback<SSOLoginResponse>) {
        let body = LoginProviderRequestBody(idToken: token)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.login(ssoProvider: ssoProvider), method: .post, body: body, parameters: nil)
        let requestContext = URLRequestContext(responseBodyType: SSOLoginResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/send/reset/password
    func sendResetPassword(email: String, completion: @escaping Callback<SendResetPasswordResponse>) {
        let parameters = ["email": email]
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.sendResetPassword, method: .get, body: nil as EmptyRequestBody?, parameters: parameters)
        let requestContext = URLRequestContext(responseBodyType: SendResetPasswordResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }
}
