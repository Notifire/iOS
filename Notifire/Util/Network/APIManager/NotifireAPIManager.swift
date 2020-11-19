//
//  NotifireAPIManager.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class NotifireAPIManager: NotifireAPIBaseManager {

    // MARK: - /version?currentVersion=<version>
    func checkAppVersion(currentVersion: String = Config.appVersion, completion: @escaping Callback<AppVersionResponse>) {
        let params = [
            URLQueryItem(name: "currentVersion", value: currentVersion)
        ]
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.version, method: .get, body: nil as EmptyRequestBody?, queryItems: params)
        let requestContext = URLRequestContext(responseBodyType: AppVersionResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /register
    func register(email: String, password: String, completion: @escaping Callback<RegisterResponse>) {
        let body = RegisterRequestBody(email: email, password: password)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.register, method: .post, body: body, queryItems: nil)
        let requestContext = URLRequestContext(responseBodyType: RegisterResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/send/confirm
    func sendConfirmEmail(to email: String, completion: @escaping Callback<ResendConfirmResponse>) {
        let parameters = [
            URLQueryItem(name: "email", value: email)
        ]
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.resendConfirm, method: .get, body: nil as EmptyRequestBody?, queryItems: parameters)
        let requestContext = URLRequestContext(responseBodyType: ResendConfirmResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/confirm
    func confirmAccount(emailToken: String, completion: @escaping Callback<ConfirmAccountResponse>) {
        let body = ConfirmAccountRequestBody(token: emailToken)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.confirmAccount, method: .put, body: body, queryItems: nil)
        let requestContext = URLRequestContext(responseBodyType: ConfirmAccountResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/check
    func checkValidity(option: CheckValidityOption, input: String, completion: @escaping Callback<CheckValidityResponse>) {
        let parameters = [URLQueryItem(name: option.rawValue, value: input)]
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.check, method: .get, body: nil as EmptyRequestBody?, queryItems: parameters)
        let requestContext = URLRequestContext(responseBodyType: CheckValidityResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/login
    func login(email: String, password: String, completion: @escaping Callback<LoginResponse>) {
        let body = LoginRequestBody(email: email, password: password)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.login, method: .post, body: body, queryItems: nil)
        let requestContext = URLRequestContext(responseBodyType: LoginResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/login/{provider}
    func login(token: String, ssoProvider: SSOAuthenticationProvider, completion: @escaping Callback<SSOLoginResponse>) {
        let body = LoginProviderRequestBody(idToken: token)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.login(ssoProvider: ssoProvider), method: .post, body: body, queryItems: nil)
        let requestContext = URLRequestContext(responseBodyType: SSOLoginResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/send/reset/password
    func sendResetPassword(email: String, completion: @escaping Callback<SendResetPasswordResponse>) {
        let parameters = [
            URLQueryItem(name: "email", value: email)
        ]
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.sendResetPassword, method: .get, body: nil as EmptyRequestBody?, queryItems: parameters)
        let requestContext = URLRequestContext(responseBodyType: SendResetPasswordResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/reset/password
    func resetPassword(password: String, token: String, completion: @escaping Callback<ResetPasswordResponse>) {
        let body = ResetPasswordRequestBody(password: password, token: token)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.resetPassword, method: .put, body: body)
        let requestContext = URLRequestContext(responseBodyType: ResetPasswordResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/change/email
    func changeEmail(token: String, completion: @escaping Callback<ChangeEmailResponse>) {
        let body = ChangeEmailRequestBody(token: token)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.changeEmail, method: .put, body: body)
        let requestContext = URLRequestContext(responseBodyType: ChangeEmailResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/revert/email
    func revertEmail(token: String, completion: @escaping Callback<ChangeEmailResponse>) {
        let body = ChangeEmailRequestBody(token: token)
        let request = createAPIRequest(endpoint: NotifireAPIEndpoint.revertEmail, method: .post, body: body)
        let requestContext = URLRequestContext(responseBodyType: ChangeEmailResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }
}
