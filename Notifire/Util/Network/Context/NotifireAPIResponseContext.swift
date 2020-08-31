//
//  NotifireAPIResponseContext.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

struct NotifireAPIResponseContext<ResponseBody: NotifireAPIDecodable> {
    let errorContext: NotifireAPIRequestErrorContext<ResponseBody>?
    let response: ResponseBody?
}
