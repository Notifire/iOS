//
//  NotifireAPIManagerBase.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

typealias NotifireAPIManagerCallback<Response: NotifireAPIDecodable> = (NotifireAPIManagerBase.ManagerResult<Response>) -> Void

class NotifireAPIManagerBase {

    // MARK: - Result Values
    enum ManagerResultError: Error {
        case network
        case server
    }

    enum ManagerResult<ResponseBody: NotifireAPIDecodable> {
        case error(ManagerResultError)
        case success(ResponseBody)
    }

    // MARK: - Properties
    // MARK: Static
    static let requestTimeout: TimeInterval = 20
    static let baseURL = URL(string: Config.shared.apiUrlString)!

    let apiHandler: NotifireAPIHandler

    // MARK: - Initialization
    init(apiHandler: NotifireAPIHandler = URLSession.shared) {
        self.apiHandler = apiHandler
    }

    // MARK: - Open
    open func notifireApiRequest<Body>(endpoint: CustomStringConvertible, method: HTTPMethod, body: Body?, parameters: HTTPParameters?) -> NotifireAPIRequest where Body: NotifireAPIEncodable {
        var url = URL(string: endpoint.description, relativeTo: NotifireAPIManager.baseURL) ?? NotifireAPIManager.baseURL
        if let requestParameters = parameters {
            for parameter in requestParameters {
                url = url.append(parameter.key, value: parameter.value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed))
            }
        }
        var request = NotifireAPIRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: NotifireAPIManagerBase.requestTimeout)
        request.httpMethod = method.rawValue
        if let requestBody = body {
            request.addBody(requestBody)
        }
        request.timeoutInterval = 10
        return request
    }

    // MARK: - Internal
    func createApiCompletionHandler<Response: NotifireAPIDecodable>(managerCompletion: @escaping NotifireAPIManagerCallback<Response>) -> ((NotifireAPIResponseContext<Response>) -> Void) {
        return { responseContext in
            if let error = responseContext.errorContext?.error {
                switch error {
                case .invalidStatusCode, .invalidResponseBody, .responseDataIsNil, .urlResponseNotCreated, .unknown:
                    managerCompletion(.error(.server))
                case .urlsession:
                    managerCompletion(.error(.network))
                }
                return
            }
            guard let response = responseContext.response else {
                managerCompletion(.error(.server))
                return
            }
            managerCompletion(.success(response))
        }
    }

    func perform<Response: NotifireAPIDecodable>(requestContext: NotifireAPIRequestContext<Response>, managerCompletion: @escaping NotifireAPIManagerCallback<Response>) {
        let apiCompletionHandler = createApiCompletionHandler(managerCompletion: managerCompletion)
        apiHandler.perform(requestContext: requestContext, completionHandler: apiCompletionHandler)
    }
}
