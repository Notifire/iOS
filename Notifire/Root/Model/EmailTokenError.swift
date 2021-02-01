//
//  EmailTokenError.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

enum EmailTokenError: Int, UserErrorRepresenting {
    case expired = 1
    case invalid = 2

    var description: String {
        switch self {
        case .expired: return "The link has expired."
        case .invalid: return "The link is invalid."
        }
    }
}
