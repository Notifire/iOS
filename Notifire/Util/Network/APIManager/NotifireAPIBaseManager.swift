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
    static let baseURL = URL(string: Config.apiUrlString)!

    let apiHandler: APIHandler

    // MARK: - Initialization
    init(apiHandler: APIHandler = URLSession.shared) {
        self.apiHandler = apiHandler
    }

    // MARK: - Open
    open func createAPIRequest<Body: Encodable>(endpoint: CustomStringConvertible, method: HTTPMethod, body: Body?, queryItems: [URLQueryItem]? = nil) -> URLRequest {
        let url = URL(string: endpoint.description, relativeTo: NotifireAPIManager.baseURL) ?? NotifireAPIManager.baseURL
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        if let parameters = queryItems {
            urlComponents.queryItems = parameters
        }
        var request = URLRequest(url: urlComponents.url!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: NotifireAPIBaseManager.requestTimeout)
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
