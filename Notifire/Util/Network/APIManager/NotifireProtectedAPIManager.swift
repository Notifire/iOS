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
    init(session: UserSession) {
        userSession = session
        super.init()
    }

    // MARK: - Private
    private func getNewAccessToken(completion: @escaping Callback<GenerateAccessTokenResponse>) {
        let body = GenerateAccessTokenRequestBody(refreshToken: userSession.refreshToken)
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.generateAccessToken, method: .post, body: body, parameters: nil)
        let requestContext = URLRequestContext(responseBodyType: GenerateAccessTokenResponse.self, apiRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }

    private static func createAuthorizedRequestContext<Response: Decodable>(request: URLRequest, accessToken: String, responseType: Response.Type) -> URLRequestContext<Response> {
        var mutableRequest = request
        mutableRequest.add(header: HTTPHeader(field: "Authorization", value: accessToken))
        let requestContext = URLRequestContext(responseBodyType: responseType, apiRequest: mutableRequest)
        return requestContext
    }

    /// Adds a valid access token to a protected request, if no token is available the function generates it beforehand and performs the original request afterwards
    private func performProtected<Response: Decodable>(request: URLRequest, responseType: Response.Type, completion: @escaping Callback<Response>) {
        let generateAccessTokenCompletion: (Callback<GenerateAccessTokenResponse>) = { [weak self] responseContext in
            guard let `self` = self else { return }
            switch responseContext {
            case .error(let err):
                completion(.error(err))
            case .success(let accessTokenResponse):
                if let newAccessToken = accessTokenResponse.accessToken {
                    // save the new access token
                    self.userSession.accessToken = newAccessToken
                    // perform request
                    let requestContext = NotifireProtectedAPIManager.createAuthorizedRequestContext(request: request, accessToken: newAccessToken, responseType: responseType)
                    self.perform(requestContext: requestContext, managerCompletion: completion)
                } else {
                    // logout
                    self.onRefreshTokenInvalidation?()
                }
            }
        }
        if let currentAccessToken = userSession.accessToken {
            // We have an access token available in the User's session
            let requestContext = NotifireProtectedAPIManager.createAuthorizedRequestContext(request: request, accessToken: currentAccessToken, responseType: responseType)
            apiHandler.perform(requestContext: requestContext) { [weak self] responseContext in
                if case .error(let errorContext) = responseContext, case .invalidStatusCode(let statusCode, _) = errorContext.error, case .unauthorized? = NotifireAPIStatusCode(rawValue: statusCode) {
                    self?.getNewAccessToken(completion: generateAccessTokenCompletion)
                } else {
                    self?.createApiCompletionHandler(managerCompletion: completion)(responseContext)
                }
            }
        } else {
            getNewAccessToken(completion: generateAccessTokenCompletion)
        }
    }

    // MARK: - Requests
    // MARK: /account/device
    func register(deviceToken: String, completion: @escaping Callback<RegisterDeviceResponse>) {
        let body = RegisterDeviceRequestBody(deviceToken: deviceToken)
        let request = createAPIRequest(
            endpoint: NotifireProtectedAPIEndpoint.registerDevice,
            method: .post,
            body: body,
            parameters: nil
        )
        performProtected(request: request, responseType: RegisterDeviceResponse.self, completion: completion)
    }

    func logout(deviceToken: String, completion: @escaping Callback<RegisterDeviceResponse>) {
        let body = RegisterDeviceRequestBody(deviceToken: deviceToken)
        let request = createAPIRequest(
            endpoint: NotifireProtectedAPIEndpoint.logout,
            method: .post,
            body: body,
            parameters: nil
        )
        performProtected(request: request, responseType: RegisterDeviceResponse.self, completion: completion)
    }

    // MARK: /services
    func services(completion: @escaping Callback<ServicesResponse>) {
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.services, method: .get, body: nil as EmptyRequestBody?, parameters: nil)
        performProtected(request: request, responseType: ServicesResponse.self, completion: completion)
    }

    // MARK: /service
    private func change(service: LocalService, method: HTTPMethod, completion: @escaping Callback<NotifireAPIPlainSuccessResponse>) {
        let serviceRequestBody = service.asServiceRequestBody
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: method, body: serviceRequestBody, parameters: nil)
        performProtected(request: request, responseType: NotifireAPIPlainSuccessResponse.self, completion: completion)
    }

    func createService(name: String, image: String, completion: @escaping Callback<ServiceCreationResponse>) {
        let body = ServiceCreationBody(name: name, image: image)
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: .post, body: body, parameters: nil)
        performProtected(request: request, responseType: ServiceCreationResponse.self, completion: completion)
    }

    func update(service: LocalService, completion: @escaping Callback<ServiceUpdateResponse>) {
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: .put, body: service.asServiceRequestBody, parameters: nil)
        performProtected(request: request, responseType: ServiceUpdateResponse.self, completion: completion)
    }

    func delete(service: LocalService, completion: @escaping Callback<EmptyRequestBody>) {
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: .delete, body: service.asServiceRequestBody, parameters: nil)
        performProtected(request: request, responseType: EmptyRequestBody.self, completion: completion)
    }

    func changeApiKey(for service: LocalService, password: String, completion: @escaping Callback<APIKeyChangeResponse>) {
        let body = ChangeServiceKeyBody(service: service.asService, password: password)
        let request = createAPIRequest(endpoint: NotifireProtectedAPIEndpoint.serviceKey, method: .post, body: body, parameters: nil)
        performProtected(request: request, responseType: APIKeyChangeResponse.self, completion: completion)
    }
}
