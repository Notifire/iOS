//
//  APIHandler.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

protocol APIHandler {
    /// Perform a normal data network request.
    func perform<ResponseBody: Decodable>(requestContext: URLRequestContext<ResponseBody>, completionHandler: @escaping ((NotifireAPIResponseContext<ResponseBody>) -> Void))
}

extension APIHandler {

    /// The completion callback type
    typealias CompletionCallback<ResponseBody: Decodable> = (NotifireAPIResponseContext<ResponseBody>) -> Void

    /// Finish a request with the appropriate completion result
    static func finish<ResponseBody: Decodable>(_ maybeResponseBody: ResponseBody?, _ maybeError: NotifireAPIError?, statusCode: HTTPStatusCode? = nil, responseBodyString: String? = nil, requestContext: URLRequestContext<ResponseBody>, completion: @escaping CompletionCallback<ResponseBody>) {
        if let notifireAPIError = maybeError {
            let errorContext = URLRequestErrorContext(error: notifireAPIError, requestContext: requestContext, statusCode: statusCode, responseBodyString: responseBodyString)
            Logger.logNetwork(.default, "\(self) errorContext=<\(errorContext)>")
            DispatchQueue.main.async {
                completion(.error(context: errorContext))
            }
        } else if let responseBody = maybeResponseBody {
            DispatchQueue.main.async {
                completion(.response(body: responseBody))
            }
        }
    }
}

// MARK: NotifireAPIHandler
extension URLSession: APIHandler {

    // swiftlint:disable function_body_length
    func perform<ResponseBody: Decodable>(requestContext: URLRequestContext<ResponseBody>, completionHandler: @escaping ((NotifireAPIResponseContext<ResponseBody>) -> Void)) {
        let taskCompletionHandler: ((Data?, URLResponse?, Error?) -> Void) = {data, urlResponse, maybeError in
            // Error
            if let error = maybeError {
                URLSession.finish(nil, .urlSession(error: error), requestContext: requestContext, completion: completionHandler)
                return
            }
            // Data
            guard let data = data, let stringData = String(bytes: data, encoding: .utf8) else {
                URLSession.finish(nil, .responseDataIsNil, requestContext: requestContext, completion: completionHandler)
                return
            }
            // Status Code
            guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                URLSession.finish(nil, .urlResponseNotCreated, responseBodyString: stringData, requestContext: requestContext, completion: completionHandler)
                return
            }
            guard let statusCode = NotifireAPIStatusCode(rawValue: httpURLResponse.statusCode) else {
                URLSession.finish(nil, .invalidStatusCode(httpURLResponse.statusCode, nil), statusCode: httpURLResponse.statusCode, responseBodyString: stringData, requestContext: requestContext, completion: completionHandler)
                return
            }
            let decoder = JSONDecoder()
            switch statusCode {
            case .success:
                decoder.dateDecodingStrategy = .timestampStrategy
                guard let response = try? decoder.decode(requestContext.responseBodyType, from: data) else {
                    URLSession.finish(
                        nil,
                        .invalidResponseBody(requestContext.responseBodyType, stringData),
                        statusCode: httpURLResponse.statusCode,
                        responseBodyString: stringData,
                        requestContext: requestContext,
                        completion: completionHandler
                    )
                    return
                }
                URLSession.finish(
                    response,
                    nil,
                    statusCode: statusCode.rawValue,
                    responseBodyString: stringData,
                    requestContext: requestContext,
                    completion: completionHandler
                )
            case .accepted:
                let emptyJsonData = Data(_: [0x7B, 0x7D]) // "{}" empty json data
                guard let response = try? decoder.decode(requestContext.responseBodyType, from: emptyJsonData) else {
                    URLSession.finish(
                        nil,
                        .invalidResponseBody(requestContext.responseBodyType, stringData),
                        statusCode: statusCode.rawValue,
                        responseBodyString: stringData,
                        requestContext: requestContext,
                        completion: completionHandler
                    )
                    return
                }
                URLSession.finish(
                    response,
                    nil,
                    statusCode: statusCode.rawValue,
                    responseBodyString: stringData,
                    requestContext: requestContext,
                    completion: completionHandler
                )
            case .unauthorized, .methodNotAllowed, .badRequest:
                guard let clientErrorResponse = try? decoder.decode(ClientError.self, from: data) else {
                    // Fallthrough to the last 'default' case in case the decoding fails.
                    fallthrough
                }
                URLSession.finish(
                    nil,
                    .clientError(clientErrorResponse),
                    statusCode: statusCode.rawValue,
                    responseBodyString: stringData,
                    requestContext: requestContext,
                    completion: completionHandler
                )
            default:
                URLSession.finish(
                    nil,
                    .invalidStatusCode(statusCode.rawValue, stringData),
                    statusCode: statusCode.rawValue,
                    responseBodyString: stringData,
                    requestContext: requestContext,
                    completion: completionHandler
                )
            }
        }

        // Create a task
        let task: URLSessionDataTask
        switch requestContext.requestTaskType {
        case .dataTask:
            task = dataTask(with: requestContext.apiRequest, completionHandler: taskCompletionHandler)
        case .uploadTask(let data):
            task = uploadTask(with: requestContext.apiRequest, from: data, completionHandler: taskCompletionHandler)
        }
        // Start it
        task.resume()
    }
    // swiftlint:enable function_body_length
}
