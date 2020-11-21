//
//  EmailTokenError.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

enum EmailTokenError: Int, UserErrorRepresenting {
    case invalid = 0
    case expired = 1

    var description: String {
        switch self {
        case .invalid: return "The link is invalid."
        case .expired: return "The link has expired."
        }
    }
}
