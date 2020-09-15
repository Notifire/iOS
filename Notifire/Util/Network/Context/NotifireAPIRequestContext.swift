//
//  URLRequestContext.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

/// Each network request has it's own request context. It is defined by the type of the `ResponseBody` and a `URLRequest`.
struct URLRequestContext<ResponseBody: Decodable> {
    let responseBodyType: ResponseBody.Type
    let apiRequest: URLRequest
}

// MARK: - CustomStringConvertible
extension URLRequestContext: CustomStringConvertible {
    var description: String {
        return "responseBodyType={\(responseBodyType)} | apiRequest={\(apiRequest)}"
    }
}
