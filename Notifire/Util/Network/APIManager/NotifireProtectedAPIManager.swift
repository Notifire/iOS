//
//  NotifireProtectedAPIManager.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class NotifireProtectedAPIManager: NotifireAPIBaseManager {

    // MARK: - Properties
    let userSession: UserSession

    // MARK: Callback
    // invoked when the refresh token is no longer valid
    var onRefreshTokenInvalidation: (() -> Void)?

    // MARK: - Initialization
    init(session: UserSession, apiHandler: APIHandler? = nil) {
        userSession = session
        super.init(apiHandler: apiHandler)
    }

    // MARK: - Private
    private static func createAuthorizedRequestContext<Response: Decodable>(request: URLRequest, requestTaskType: URLRequestContext<Response>.RequestTaskType, accessToken: String, responseType: Response.Type) -> URLRequestContext<Response> {
        var mutableRequest = request
        mutableRequest.add(header: HTTPHeader(field: "Authorization", value: accessToken))
        let requestContext = URLRequestContext(responseBodyType: responseType, apiRequest: mutableRequest, requestTaskType: requestTaskType)
        return requestContext
    }

    /// Adds a valid access token to a protected request, if no token is available the function generates it beforehand and performs the original request afterwards
    private func performProtected<Response: Decodable>(request: URLRequest, responseType: Response.Type, requestTaskType: URLRequestContext<Response>.RequestTaskType = .dataTask, completion: @escaping Callback<Response>) {
        let fetchAccessTokenCompletion: (Callback<String>) = { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .error(let err):
                completion(.error(err))
            case .success(let accessToken):
                let requestContext = NotifireProtectedAPIManager.createAuthorizedRequestContext(request: request, requestTaskType: requestTaskType, accessToken: accessToken, responseType: responseType)
                self.perform(requestContext: requestContext, managerCompletion: completion)
            }

        }
        if let currentAccessToken = userSession.accessToken {
            // We have an access token available in the User's session
            let requestContext = NotifireProtectedAPIManager.createAuthorizedRequestContext(request: request, requestTaskType: requestTaskType, accessToken: currentAccessToken, responseType: responseType)
            apiHandler.perform(requestContext: requestContext) { [weak self] responseContext in
                if case .error(let errorContext) = responseContext, case .invalidStatusCode(let statusCode, _) = errorContext.error, case .unauthorized? = NotifireAPIStatusCode(rawValue: statusCode) {
                    self?.fetchNewAccessToken(completion: fetchAccessTokenCompletion)
                } else {
                    self?.createApiCompletionHandler(managerCompletion: completion)(responseContext)
                }
            }
        } else {
            fetchNewAccessToken(completion: fetchAccessTokenCompletion)
        }
    }

    // MARK: - Access Token
    func fetchNewAccessToken(completion: @escaping Callback<String>) {
        let body = GenerateAccessTokenRequestBody(refreshToken: userSession.refreshToken)
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.generateAccessToken, method: .post, body: body, queryItems: nil)
        let requestContext = URLRequestContext(responseBodyType: GenerateAccessTokenResponse.self, apiRequest: request, requestTaskType: .dataTask)
        perform(requestContext: requestContext) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .error(let err):
                completion(.error(err))
            case .success(let accessTokenResponse):
                if let newAccessToken = accessTokenResponse.accessToken {
                    // save the new access token
                    self.userSession.accessToken = newAccessToken

                    // perform request
                    completion(.success(newAccessToken))
                } else {
                    // logout
                    self.onRefreshTokenInvalidation?()
                }
            }
        }
    }

    // MARK: - Account
    // MARK: Device
    func register(deviceToken: String, completion: @escaping Callback<RegisterDeviceResponse>) {
        let body = RegisterDeviceRequestBody(deviceToken: deviceToken)
        let request = createAPIRequest(
            endpoint: NotifireProtectedAPIEndpoint.registerDevice,
            method: .post,
            body: body,
            queryItems: nil
        )
        performProtected(request: request, responseType: RegisterDeviceResponse.self, completion: completion)
    }

    // MARK: Logout
    func logout(deviceToken: String, completion: @escaping Callback<RegisterDeviceResponse>) {
        let body = RegisterDeviceRequestBody(deviceToken: deviceToken)
        let request = createAPIRequest(
            endpoint: NotifireProtectedAPIEndpoint.logout,
            method: .post,
            body: body,
            queryItems: nil
        )
        performProtected(request: request, responseType: RegisterDeviceResponse.self, completion: completion)
    }

    // MARK: Password Change
    func change(oldPassword: String, to newPassword: String, completion: @escaping Callback<ChangePasswordResponse>) {
        let body = ChangePasswordRequestBody(oldPassword: oldPassword, newPassword: newPassword)
        let request = createAPIRequest(
            endpoint: NotifireProtectedAPIEndpoint.password,
            method: .put,
            body: body
        )
        performProtected(request: request, responseType: ChangePasswordResponse.self, completion: completion)
    }

    // MARK: Send Change Email
    func sendChangeEmail(to newEmail: String, completion: @escaping Callback<SendChangeEmailResponse>) {
        let params = [
            URLQueryItem(name: "email", value: newEmail)
        ]
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.sendChangeEmail, method: .get, body: nil as EmptyRequestBody?, queryItems: params)
        performProtected(request: request, responseType: SendChangeEmailResponse.self, completion: completion)
    }

    // MARK: - /services
    // MARK: GET
    func getServices(limit: Int = 25, paginationData: PaginationData? = nil, completion: @escaping Callback<ServicesResponse>) {
        var parameters = [
            URLQueryItem(name: "limit", value: String(limit))
        ]
        if let pagination = paginationData {
            parameters.append(pagination.asURLQueryItem)
        }
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.services, method: .get, body: nil as EmptyRequestBody?, queryItems: parameters)
        performProtected(request: request, responseType: ServicesResponse.self, completion: completion)
    }

    // MARK: Sync
    func sync(services: [Service], completion: @escaping Callback<SyncServicesResponse>) {
        let body = SyncServicesRequestBody(services: services)
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.servicesSync, method: .post, body: body, queryItems: nil)
        performProtected(request: request, responseType: SyncServicesResponse.self, completion: completion)
    }

    // MARK: /service
    // MARK: GET
    func get(service: ServiceSnippet, completion: @escaping Callback<ServiceGetResponse>) {
        let id = service.id
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.service(id: id), method: .get, body: nil as EmptyRequestBody?, queryItems: nil)
        performProtected(request: request, responseType: ServiceGetResponse.self, completion: completion)
    }

    // MARK: Create
    // FIXME: createService
    func createService(name: String, imageData: Data?, completion: @escaping Callback<NotifireAPIPlainSuccessResponse>) {
        let body = ServiceCreationBody(name: name)
        let multipartRequest = createMultipartAPIRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: .post, imageData: imageData, body: body)
        performProtected(request: multipartRequest.0, responseType: NotifireAPIPlainSuccessResponse.self, requestTaskType: .uploadTask(data: multipartRequest.1), completion: completion)
    }

    // MARK: Update
    func update(service: LocalService, completion: @escaping Callback<ServiceUpdateResponse>) {
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: .put, body: service.asServiceUpdateRequestBody, queryItems: nil)
        performProtected(request: request, responseType: ServiceUpdateResponse.self, completion: completion)
    }

    // MARK: Update With Image
    func update(serviceWithImage service: LocalService, imageData: Data?, completion: @escaping Callback<ServiceUpdateResponse>) {
        // TODO:

    }

    // MARK: Delete
    func delete(service: LocalService, completion: @escaping Callback<EmptyRequestBody>) {
        let body = ServiceDeletionBody(id: service.id)
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: .delete, body: body)
        performProtected(request: request, responseType: EmptyRequestBody.self, completion: completion)
    }

    // MARK: Change API Key
    func changeApiKey(for service: LocalService, password: String, completion: @escaping Callback<APIKeyChangeResponse>) {
        let body = ChangeServiceKeyBody(apiKey: service.serviceAPIKey, password: password)
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.serviceKey, method: .put, body: body, queryItems: nil)
        performProtected(request: request, responseType: APIKeyChangeResponse.self, completion: completion)
    }
}
