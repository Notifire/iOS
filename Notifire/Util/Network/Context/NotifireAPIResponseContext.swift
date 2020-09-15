//
//  NotifireAPIResponseContext.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

enum NotifireAPIResponseContext<ResponseBody: Decodable> {
    case error(context: URLRequestErrorContext<ResponseBody>)
    case response(body: ResponseBody)
}
