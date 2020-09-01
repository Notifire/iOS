//
//  NotifireAPIHandler.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

protocol NotifireAPIHandler {
    func perform<ResponseBody: NotifireAPIDecodable>(requestContext: NotifireAPIRequestContext<ResponseBody>, completionHandler: @escaping ((NotifireAPIResponseContext<ResponseBody>) -> Void))
}

// MARK: NotifireAPIHandler
extension URLSession: NotifireAPIHandler {
    func perform<ResponseBody: NotifireAPIDecodable>(requestContext: NotifireAPIRequestContext<ResponseBody>, completionHandler: @escaping ((NotifireAPIResponseContext<ResponseBody>) -> Void)) {
        func finish(_ response: ResponseBody?, _ error: NotifireAPIError?) {
            if let notifireAPIError = error {
                let errorContext = NotifireAPIRequestErrorContext(error: notifireAPIError, requestContext: requestContext)
                print("\(errorContext)")
                DispatchQueue.main.async {
                    completionHandler(NotifireAPIResponseContext(errorContext: errorContext, response: nil))
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler(NotifireAPIResponseContext(errorContext: nil, response: response))
                }
            }
        }
        let task = dataTask(with: requestContext.notifireAPIRequest) { data, urlResponse, maybeError in
            if let error = maybeError {
                finish(nil, .urlsession(error: error))
                return
            }
            guard let data = data else {
                finish(nil, .responseDataIsNil)
                return
            }
            guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                finish(nil, .urlResponseNotCreated)
                return
            }
            guard let statusCode = NotifireAPIStatusCode(rawValue: httpURLResponse.statusCode) else {
                finish(nil, .invalidStatusCode(httpURLResponse.statusCode))
                return
            }
            switch statusCode {
            case .success:
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .formatted(.yyyyMMdd)
                guard let response = try? decoder.decode(requestContext.responseBodyType, from: data) else {
                    finish(nil, .invalidResponseBody(requestContext.responseBodyType))
                    return
                }
                finish(response, nil)
            case .noContent:
                let emptyJsonData = Data(_: [0x7B, 0x7D]) // "{}" empty json data
                guard let response = try? JSONDecoder().decode(requestContext.responseBodyType, from: emptyJsonData) else {
                    finish(nil, .invalidResponseBody(requestContext.responseBodyType))
                    return
                }
                finish(response, nil)
            default:
                finish(nil, .invalidStatusCode(statusCode.rawValue))
            }
        }
        task.resume()
    }
}
