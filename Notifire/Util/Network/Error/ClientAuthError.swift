//
//  ClientAuthError.swift
//  Notifire
//
//  Created by David Bielik on 24/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

enum ClientAuthError: Int {
    case expired = 1
    case invalid = 2

    var description: String {
        switch self {
        case .invalid: return "Authorization token is invalid"
        case .expired: return "Authorization token has expired"
        }
    }
}
