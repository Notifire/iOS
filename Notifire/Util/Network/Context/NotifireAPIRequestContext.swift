//
//  NotifireAPIRequestContext.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

struct NotifireAPIRequestContext<ResponseBody: NotifireAPIDecodable> {
    let responseBodyType: ResponseBody.Type
    let notifireAPIRequest: NotifireAPIRequest
}

extension NotifireAPIRequestContext: CustomStringConvertible {
    var description: String {
        return "body type: \(responseBodyType) \n request: \(notifireAPIRequest)"
    }
}

struct NotifireAPIRequestErrorContext<ResponseBody: NotifireAPIDecodable> {
    let error: NotifireAPIError
    let requestContext: NotifireAPIRequestContext<ResponseBody>
}

extension NotifireAPIRequestErrorContext: CustomStringConvertible {
    var description: String {
        return "[NotifireAPIRequestErrorContext] Err: \(error.description) for requestContext: \(requestContext.description)"
    }
}
