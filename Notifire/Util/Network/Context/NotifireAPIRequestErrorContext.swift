//
//  URLRequestErrorContext.swift
//  Notifire
//
//  Created by David Bielik on 12/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

struct URLRequestErrorContext<ResponseBody: Decodable> {
    let error: NotifireAPIError
    let requestContext: URLRequestContext<ResponseBody>
    let statusCode: HTTPStatusCode?
    let responseBodyString: String?
}

extension URLRequestErrorContext: CustomStringConvertible {
    var description: String {
        return "[URLRequestErrorContext] { error={\(error.description)} | requestContext={\(requestContext.description)} | statusCode={\(statusCode ?? -1)} | responseBodyString={\(responseBodyString ?? "nil")} }"
    }
}
