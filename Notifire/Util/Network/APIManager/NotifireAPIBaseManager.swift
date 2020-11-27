//
//  NotifireAPIBaseManager.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class NotifireAPIBaseManager {

    typealias Callback<ResponseBody: Decodable> = (ManagerResult<ResponseBody>) -> Void

    // MARK: - Result Values
    enum ManagerResult<ResponseBody: Decodable> {
        case error(NotifireAPIError)
        case success(ResponseBody)
    }

    // MARK: - Properties
    // MARK: Static
    static let requestTimeout: TimeInterval = 20

    let apiHandler: APIHandler

    // MARK: - Initialization
    init(apiHandler: APIHandler? = nil) {
        if let handler = apiHandler {
            self.apiHandler = handler
        } else {
            self.apiHandler = URLSession(configuration: .default, delegate: PublicKeyPinnedURLSessionTaskResolver(), delegateQueue: nil)
        }
    }

    // MARK: - Open
    open func createAPIRequest<Body: Encodable>(endpoint: CustomStringConvertible, method: HTTPMethod, body: Body?, queryItems: [URLQueryItem]? = nil) -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = Config.apiUrlString
        urlComponents.path = endpoint.description
        if let parameters = queryItems {
            urlComponents.queryItems = parameters
        }
        let url = urlComponents.url ?? URL(string: Config.apiUrlString)!
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: NotifireAPIBaseManager.requestTimeout)
        request.httpMethod = method.rawValue
        if let requestBody = body {
            request.addBody(requestBody)
        }
        request.timeoutInterval = 10
        return request
    }

    // MARK: - Internal
    func createApiCompletionHandler<ResponseBody: Decodable>(managerCompletion: @escaping Callback<ResponseBody>) -> ((NotifireAPIResponseContext<ResponseBody>) -> Void) {
        return { responseContext in
            switch responseContext {
            case .error(let context):
                managerCompletion(.error(context.error))
            case .response(let body):
                managerCompletion(.success(body))
            }
        }
    }

    func perform<ResponseBody: Decodable>(requestContext: URLRequestContext<ResponseBody>, managerCompletion: @escaping Callback<ResponseBody>) {
        let apiCompletionHandler = createApiCompletionHandler(managerCompletion: managerCompletion)
        apiHandler.perform(requestContext: requestContext, completionHandler: apiCompletionHandler)
    }
}
