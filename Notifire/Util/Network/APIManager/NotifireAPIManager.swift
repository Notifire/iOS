//
//  NotifireAPIManager.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class NotifireAPIManager: NotifireAPIManagerBase {

    // MARK: - /account/register
    func register(username: String, email: String, password: String, completion: @escaping NotifireAPIManagerCallback<RegisterResponse>) {
        let body = RegisterRequestBody(username: username, email: email, password: password)
        let request = notifireApiRequest(endpoint: NotifireAPIEndpoint.register, method: .post, body: body, parameters: nil)
        let requestContext = NotifireAPIRequestContext(responseBodyType: RegisterResponse.self, notifireAPIRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/register/resend
    func resendConfirmEmail(usernameOrEmail: String, completion: @escaping NotifireAPIManagerCallback<ResendConfirmResponse>) {
        let body = ResendConfirmRequestBody(email: usernameOrEmail)
        let request = notifireApiRequest(endpoint: NotifireAPIEndpoint.resendConfirm, method: .post, body: body, parameters: nil)
        let requestContext = NotifireAPIRequestContext(responseBodyType: ResendConfirmResponse.self, notifireAPIRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/register/confirm
    func confirmAccount(emailToken: String, completion: @escaping NotifireAPIManagerCallback<VerifyAccountResponse>) {
        let body = ConfirmAccountRequestBody(token: emailToken)
        let request = notifireApiRequest(endpoint: NotifireAPIEndpoint.confirmAccount, method: .put, body: body, parameters: nil)
        let requestContext = NotifireAPIRequestContext(responseBodyType: VerifyAccountResponse.self, notifireAPIRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/check
    func checkValidity(option: CheckValidityOption, input: String, completion: @escaping NotifireAPIManagerCallback<CheckValidityResponse>) {
        let parameters = [option.rawValue: input]
        let request = notifireApiRequest(endpoint: NotifireAPIEndpoint.check, method: .get, body: nil as EmptyRequestBody?, parameters: parameters)
        let requestContext = NotifireAPIRequestContext(responseBodyType: CheckValidityResponse.self, notifireAPIRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/login
    func login(usernameOrEmail: String, password: String, completion: @escaping NotifireAPIManagerCallback<LoginResponse>) {
        let body = LoginRequestBody(username: usernameOrEmail, password: password)
        let request = notifireApiRequest(endpoint: NotifireAPIEndpoint.login, method: .post, body: body, parameters: nil)
        let requestContext = NotifireAPIRequestContext(responseBodyType: LoginResponse.self, notifireAPIRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    // MARK: - /account/send/reset/password
    func sendResetPassword(email: String, completion: @escaping NotifireAPIManagerCallback<SendResetPasswordResponse>) {
        let body = SendResetPasswordBody(email: email)
        let request = notifireApiRequest(endpoint: NotifireAPIEndpoint.sendResetPassword, method: .post, body: body, parameters: nil)
        let requestContext = NotifireAPIRequestContext(responseBodyType: SendResetPasswordResponse.self, notifireAPIRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }
}
