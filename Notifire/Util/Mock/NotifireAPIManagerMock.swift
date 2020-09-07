//
//  NotifireAPIManagerMock.swift
//  Notifire
//
//  Created by David Bielik on 13/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

protocol NotifireAPIManagerMocking {}

extension NotifireAPIManagerMocking {
    fileprivate func returnSuccessAfter<Response: NotifireAPIDecodable>(duration: TimeInterval = 1.5, completion: @escaping NotifireAPIManagerCallback<Response>, response: Response) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion(.success(response))
        }
    }

    fileprivate func returnPlainSuccessResponseAfter(duration: TimeInterval = 1.5, completion: @escaping NotifireAPIManagerCallback<NotifireAPIPlainSuccessResponse>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            completion(.success(NotifireAPIPlainSuccessResponse(success: true)))
        }
    }
}

class NotifireAPIManagerMock: NotifireAPIManager, NotifireAPIManagerMocking {

    // MARK: - Inherited
    override func register(username: String, email: String, password: String, completion: @escaping NotifireAPIManagerCallback<RegisterResponse>) {
        returnPlainSuccessResponseAfter(duration: 0.3, completion: completion)
    }

    override func resendConfirmEmail(usernameOrEmail: String, completion: @escaping NotifireAPIManagerCallback<ResendConfirmResponse>) {
        returnPlainSuccessResponseAfter(completion: completion)
    }

    override func confirmAccount(emailToken: String, completion: @escaping NotifireAPIManagerCallback<VerifyAccountResponse>) {
        returnSuccessAfter(completion: completion, response: VerifyAccountResponse(success: true, payload: VerifyAccountSuccessResponse(email: "testtest", refreshToken: "testtestRefreshToken", accessToken: "jwt"), error: nil))
    }

    override func checkValidity(option: CheckValidityOption, input: String, completion: @escaping NotifireAPIManagerCallback<CheckValidityResponse>) {
        returnSuccessAfter(duration: 0.3, completion: completion, response: CheckValidityResponse(valid: true))
    }

    override func login(usernameOrEmail: String, password: String, completion: @escaping NotifireAPIManagerCallback<LoginResponse>) {
        returnSuccessAfter(completion: completion, response: LoginResponse(success: true, payload: LoginSuccessResponse(email: "xDD", refreshToken: "LUL", accessToken: "ojgsdljgksjdfg"), error: nil))
    }

    override func login(token: String, ssoProvider: SSOAuthenticationProvider, completion: @escaping NotifireAPIManagerCallback<SSOLoginResponse>) {
        returnSuccessAfter(completion: completion, response: SSOLoginResponse(email: "testicek@testicek.testicek", refreshToken: "xdddddd", accessToken: "KEKW"))
    }

    override func sendResetPassword(email: String, completion: @escaping NotifireAPIManagerCallback<SendResetPasswordResponse>) {
        returnPlainSuccessResponseAfter(completion: completion)
    }
}

class NotifireProtectedAPIManagerMock: NotifireProtectedAPIManager, NotifireAPIManagerMocking {

    override func register(deviceToken: String, completion: @escaping NotifireAPIManagerCallback<RegisterDeviceResponse>) {
        returnSuccessAfter(completion: completion, response: RegisterDeviceResponse())
    }

    override func logout(deviceToken: String, completion: @escaping NotifireAPIManagerCallback<RegisterDeviceResponse>) {
        returnSuccessAfter(completion: completion, response: RegisterDeviceResponse())
    }

    override func services(completion: @escaping NotifireAPIManagerCallback<ServicesResponse>) {
        let services: [Service] = [Service(name: "dvdblk.com", uuid: "1", levels: Service.Levels(info: true, warning: false, error: false), apiKey: "w9z$C&F)H@McQfTjWnZr4u7x!A%D*G-KaNdRgUkXp2s5v8y/B?E(H+MbQeShVmYq3t6w9z$C&F)J@NcRfUjWnZr4u7x!A%D*G-KaPdSgVkYp2s5v8y/B?E(H+MbQeThW", updatedAt: Date()),
                        Service(name: "Service 2", uuid: "2", levels: Service.Levels(info: false, warning: false, error: false), apiKey: "key 2", updatedAt: Date())]
        returnSuccessAfter(duration: 0.5, completion: completion, response: services)
    }

    override func createService(name: String, image: String, completion: @escaping NotifireAPIManagerCallback<ServiceCreationResponse>) {
        returnSuccessAfter(completion: completion, response: Service(name: "New Service", uuid: "3", levels: Service.Levels(info: true, warning: true, error: true), apiKey: "key 3", updatedAt: Date()))
    }

    override func changeApiKey(for service: LocalService, password: String, completion: @escaping NotifireAPIManagerCallback<APIKeyChangeResponse>) {
        returnSuccessAfter(duration: 0.5, completion: completion, response: Service(name: service.name, uuid: service.uuid, levels: Service.Levels(info: true, warning: true, error: true), apiKey: "\(Date())", updatedAt: Date()))
    }

    override func delete(service: LocalService, completion: @escaping NotifireAPIManagerCallback<EmptyRequestBody>) {
        returnSuccessAfter(completion: completion, response: EmptyRequestBody())
    }
}
