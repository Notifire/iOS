//
//  NotifireAPIManagerMock.swift
//  Notifire
//
//  Created by David Bielik on 13/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class NotifireAPIManagerMock: NotifireAPIManager, NotifireAPIManagerMocking {

    // MARK: - Inherited
    override func checkAppVersion(currentVersion: String = Config.appVersion, completion: @escaping NotifireAPIBaseManager.Callback<AppVersionResponse>) {
        returnSuccessAfter(completion: completion, response: AppVersionResponse(forceUpdate: false, latestVersion: "1.1.0"))
    }

    override func register(email: String, password: String, completion: @escaping Callback<RegisterResponse>) {
        returnPlainSuccessResponseAfter(duration: 0.3, completion: completion)
    }

    override func sendConfirmEmail(to email: String, completion: @escaping Callback<ResendConfirmResponse>) {
        returnPlainSuccessResponseAfter(completion: completion)
    }

    override func confirmAccount(emailToken: String, completion: @escaping Callback<VerifyAccountResponse>) {
        returnSuccessAfter(completion: completion, response: VerifyAccountResponse(success: true, payload: VerifyAccountSuccessResponse(email: "testtest", refreshToken: "testtestRefreshToken", accessToken: "jwt"), error: nil))
    }

    override func checkValidity(option: CheckValidityOption, input: String, completion: @escaping Callback<CheckValidityResponse>) {
        returnSuccessAfter(duration: 0.3, completion: completion, response: CheckValidityResponse(valid: true))
    }

    override func login(email: String, password: String, completion: @escaping Callback<LoginResponse>) {
        returnSuccessAfter(completion: completion, response: LoginResponse(success: true, payload: LoginSuccessResponse(email: "xDD", refreshToken: "LUL", accessToken: "ojgsdljgksjdfg"), error: nil))
    }

    override func login(token: String, ssoProvider: SSOAuthenticationProvider, completion: @escaping Callback<SSOLoginResponse>) {
        let response = SSOLoginResponse(success: true, payload: LoginSuccessResponse(email: "testicek@testicek.testicek", refreshToken: "xdddddd", accessToken: "KEKW"))
        returnSuccessAfter(completion: completion, response: response)
    }

    override func sendResetPassword(email: String, completion: @escaping Callback<SendResetPasswordResponse>) {
        returnPlainSuccessResponseAfter(completion: completion)
    }
}

class NotifireProtectedAPIManagerMock: NotifireProtectedAPIManager, NotifireAPIManagerMocking {

    private func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ in letters.randomElement()! })
    }

    private func randomServicesSnippets(count: Int = Int.random(in: 0...15)) -> [ServiceSnippet] {
        var services = [ServiceSnippet]()
        for i in 0..<count {
            let service = ServiceSnippet(
                name: "Service #\(i)",
                id: String(i),
                snippetImageURLString: "http://google.com"
            )
            services.append(service)
        }
        return services
    }

    lazy var services: [ServiceSnippet] = {
        return randomServicesSnippets(count: 110)
    }()

    var currentPageIndex = 0

    override func fetchNewAccessToken(completion: @escaping NotifireAPIBaseManager.Callback<String>) {
        let newAccessToken = "kekw"
        userSession.accessToken = newAccessToken
        returnSuccessAfter(completion: completion, response: newAccessToken)
    }

    override func register(deviceToken: String, completion: @escaping Callback<RegisterDeviceResponse>) {
        returnSuccessAfter(completion: completion, response: RegisterDeviceResponse())
    }

    override func change(oldPassword: String, to newPassword: String, completion: @escaping NotifireAPIBaseManager.Callback<ChangePasswordResponse>) {
        //returnSuccessAfter(completion: completion, response: ChangePasswordResponse(success: true, payload: ChangePasswordResponsePayload(refreshToken: "newrefreshtoken", accessToken: "newaccesstoken"), error: nil))
        returnSuccessAfter(completion: completion, response: ChangePasswordResponse(success: false, payload: nil, error: NotifireAPIUserError(code: .sameOldAndNewPassword, message: "")))
    }

    override func sendChangeEmail(to newEmail: String, completion: @escaping NotifireAPIBaseManager.Callback<SendChangeEmailResponse>) {
        returnSuccessAfter(completion: completion, response: SendChangeEmailResponse(success: false))
    }

    override func logout(deviceToken: String, completion: @escaping Callback<RegisterDeviceResponse>) {
        returnSuccessAfter(completion: completion, response: RegisterDeviceResponse())
    }

    override func get(service: ServiceSnippet, completion: @escaping NotifireAPIBaseManager.Callback<ServiceGetResponse>) {
        returnSuccessAfter(completion: completion, response: Service(name: service.name, imageURLString: nil, uuid: service.id, levels: Service.Levels(info: true, warning: true, error: false), apiKey: "test", updatedAt: Date()))
    }

    override func getServices(limit: Int, paginationData: PaginationData?, completion: @escaping NotifireAPIBaseManager.Callback<ServicesResponse>) {
        if currentPageIndex == 0 && services.count < limit {
            returnSuccessAfter(duration: 0.8, completion: completion, response: services)
        } else if currentPageIndex * limit > services.count {
            returnSuccessAfter(duration: 0.5, completion: completion, response: [])
        } else {
            let nextIndex = currentPageIndex + 1
            let nrServicesLeft = services.count - (currentPageIndex * limit)
            let servicesPage: ArraySlice<ServiceSnippet>
            if nrServicesLeft < limit {
                servicesPage = services[currentPageIndex * limit..<currentPageIndex * limit + nrServicesLeft]
            } else {
                servicesPage = services[currentPageIndex * limit..<nextIndex * limit]
            }
            currentPageIndex = nextIndex
            returnSuccessAfter(duration: 0.8, completion: completion, response: Array(servicesPage))
        }
    }

    override func sync(services: [Service], completion: @escaping NotifireAPIBaseManager.Callback<SyncServicesResponse>) {
        returnSuccessAfter(completion: completion, response: [])
    }

    override func createService(name: String, image: String, completion: @escaping Callback<ServiceCreationResponse>) {
        returnSuccessAfter(completion: completion, response: Service(name: "New Service", imageURLString: "test", uuid: "3", levels: Service.Levels(info: true, warning: true, error: true), apiKey: "key 3", updatedAt: Date()))
    }

    override func changeApiKey(for service: LocalService, password: String, completion: @escaping Callback<APIKeyChangeResponse>) {
        returnSuccessAfter(duration: 0.5, completion: completion, response: Service(name: service.name, imageURLString: "test", uuid: service.uuid, levels: Service.Levels(info: true, warning: true, error: true), apiKey: "\(Date())", updatedAt: Date()))
    }

    override func delete(service: LocalService, completion: @escaping Callback<EmptyRequestBody>) {
        returnSuccessAfter(completion: completion, response: EmptyRequestBody())
    }
}
