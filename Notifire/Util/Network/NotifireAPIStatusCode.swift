//
//  NotifireAPIStatusCode.swift
//  Notifire
//
//  Created by David Bielik on 08/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

enum NotifireAPIStatusCode: HTTPStatusCode {
    case success = 200
    case accepted = 202
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case methodNotAllowed = 405
    case internalServerError = 500
}
