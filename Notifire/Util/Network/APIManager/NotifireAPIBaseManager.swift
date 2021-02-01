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
        request.timeoutInterval = 15
        return request
    }

    open func createMultipartAPIRequest<Body: Encodable>(endpoint: CustomStringConvertible, method: HTTPMethod, imageData: Data?, imageFormat: ServiceImagePicker.ImageFormat?, body: Body, queryItems: [URLQueryItem]? = nil) -> (URLRequest, Data) {
        // Create normal request
        var request = createAPIRequest(endpoint: endpoint, method: method, body: nil as EmptyRequestBody?)
        let boundary = UUID().uuidString
        request.add(header: HTTPHeader(field: "Content-Type", value: "multipart/form-data; boundary=\(boundary)"))

        // FormData
        let boundaryData = "\r\n--\(boundary)\r\n".data(using: .utf8) ?? Data()
        var data = Data()
        // Image
        if let imageData = imageData, let fileExtension = imageFormat?.fileExtension {
            data.append(boundaryData)
            data.append("Content-Disposition: form-data; name=\"image\"; filename=\"svc.\(fileExtension)\"\r\n".data(using: .utf8) ?? Data())
            data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8) ?? Data())
            data.append(imageData)
        }

        // Body
        if let jsonData = try? JSONEncoder().encode(body) {
            data.append(boundaryData)
            data.append("Content-Disposition: form-data; name=\"data\"\r\n\r\n".data(using: .utf8) ?? Data())
            data.append(jsonData)
        }
        // Final boundary
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8) ?? Data())

        return (request, data)
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
