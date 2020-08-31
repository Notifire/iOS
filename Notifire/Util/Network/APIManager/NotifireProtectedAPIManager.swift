//
//  NotifireProtectedAPIManager.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation


class NotifireProtectedAPIManager: NotifireAPIManagerBase {
    
    // MARK: - Properties
    let userSession: NotifireUserSession
    
    // MARK: Callback
    // invoked when the refresh token is no longer valid
    var onRefreshTokenInvalidation: (() -> Void)?
    
    // MARK: - Initialization
    init(session: NotifireUserSession) {
        userSession = session
        super.init()
    }
    
    // MARK: - Private
    private func getNewAccessToken(completion: @escaping NotifireAPIManagerCallback<GenerateAccessTokenResponse>) {
        let body = GenerateAccessTokenRequestBody(refreshToken: userSession.refreshToken)
        let request = notifireApiRequest(endpoint: NotifireProtectedAPIEndpoint.generateAccessToken, method: .post, body: body, parameters: nil)
        let requestContext = NotifireAPIRequestContext(responseBodyType: GenerateAccessTokenResponse.self, notifireAPIRequest: request)
        perform(requestContext: requestContext, managerCompletion: completion)
    }
    
    private static func createAuthorizedRequestContext<Response: NotifireAPIDecodable>(request: NotifireAPIRequest, accessToken: String, responseType: Response.Type) -> NotifireAPIRequestContext<Response> {
        var mutableRequest = request
        mutableRequest.add(header: HTTPHeader(field: "Authorization", value: accessToken))
        let requestContext = NotifireAPIRequestContext(responseBodyType: responseType, notifireAPIRequest: mutableRequest)
        return requestContext
    }
    
    /// Adds a valid access token to a protected request, if no token is available the function generates it beforehand and performs the original request afterwards
    private func performProtected<Response: NotifireAPIDecodable>(request: NotifireAPIRequest, responseType: Response.Type, completion: @escaping NotifireAPIManagerCallback<Response>) {
        let generateAccessTokenCompletion: (NotifireAPIManagerCallback<GenerateAccessTokenResponse>) = { [weak self] responseContext in
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
            let requestContext = NotifireProtectedAPIManager.createAuthorizedRequestContext(request: request, accessToken: currentAccessToken, responseType: responseType)
            apiHandler.perform(requestContext: requestContext) { [weak self] responseContext in
                guard let error = responseContext.errorContext?.error, case .invalidStatusCode(let statusCode) = error, case .unauthorized? = NotifireAPIStatusCode(rawValue: statusCode) else {
                    self?.createApiCompletionHandler(managerCompletion: completion)(responseContext)
                    return
                }
                self?.getNewAccessToken(completion: generateAccessTokenCompletion)
            }
        } else {
            getNewAccessToken(completion: generateAccessTokenCompletion)
        }
    }

    // MARK: - Requests
    // MARK: /account/device
    func register(deviceToken: String, completion: @escaping NotifireAPIManagerCallback<RegisterDeviceResponse>) {
        let body = RegisterDeviceRequestBody(deviceToken: deviceToken, enabled: true)
        let request = notifireApiRequest(
            endpoint: NotifireProtectedAPIEndpoint.registerDevice,
            method: .post,
            body: body,
            parameters: nil
        )
        performProtected(request: request, responseType: RegisterDeviceResponse.self, completion: completion)
    }
    
    func logout(deviceToken: String, completion: @escaping NotifireAPIManagerCallback<RegisterDeviceResponse>) {
        let body = RegisterDeviceRequestBody(deviceToken: deviceToken, enabled: false)
        let request = notifireApiRequest(
            endpoint: NotifireProtectedAPIEndpoint.registerDevice,
            method: .post,
            body: body,
            parameters: nil
        )
        performProtected(request: request, responseType: RegisterDeviceResponse.self, completion: completion)
    }
    
    // MARK: /services
    func services(completion: @escaping NotifireAPIManagerCallback<ServicesResponse>) {
        let request = notifireApiRequest(endpoint: NotifireProtectedAPIEndpoint.services, method: .get, body: nil as EmptyRequestBody?, parameters: nil)
        performProtected(request: request, responseType: ServicesResponse.self, completion: completion)
    }
    
    // MARK: /service
    private func change(service: LocalService, method: HTTPMethod, completion: @escaping NotifireAPIManagerCallback<NotifireAPIPlainSuccessResponse>) {
        let serviceRequestBody = service.asServiceRequestBody
        let request = notifireApiRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: method, body: serviceRequestBody, parameters: nil)
        performProtected(request: request, responseType: NotifireAPIPlainSuccessResponse.self, completion: completion)
    }
    
    func createService(name: String, image: String, completion: @escaping NotifireAPIManagerCallback<ServiceCreationResponse>) {
        let body = ServiceCreationBody(name: name, image: image)
        let request = notifireApiRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: .post, body: body, parameters: nil)
        performProtected(request: request, responseType: ServiceCreationResponse.self, completion: completion)
    }
    
    func update(service: LocalService, completion: @escaping NotifireAPIManagerCallback<ServiceUpdateResponse>) {
        let request = notifireApiRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: .put, body: service.asServiceRequestBody, parameters: nil)
        performProtected(request: request, responseType: ServiceUpdateResponse.self, completion: completion)
    }
    
    func delete(service: LocalService, completion: @escaping NotifireAPIManagerCallback<EmptyRequestBody>) {
        let request = notifireApiRequest(endpoint: NotifireProtectedAPIEndpoint.service, method: .delete, body: service.asServiceRequestBody, parameters: nil)
        performProtected(request: request, responseType: EmptyRequestBody.self, completion: completion)
    }
    
    func changeApiKey(for service: LocalService, password: String, completion: @escaping NotifireAPIManagerCallback<APIKeyChangeResponse>) {
        let body = ChangeServiceKeyBody(service: service.asService, password: password)
        let request = notifireApiRequest(endpoint: NotifireProtectedAPIEndpoint.serviceKey, method: .post, body: body, parameters: nil)
        performProtected(request: request, responseType: APIKeyChangeResponse.self, completion: completion)
    }
}
