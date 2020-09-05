//
//  NotifireUserSession.swift
//  Notifire
//
//  Created by David Bielik on 11/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireUserSession {
    var refreshToken: String
    let email: String
    var deviceToken: String?
    var accessToken: String?

    init(refreshToken: String, email: String) {
        self.refreshToken = refreshToken
        self.email = email
    }
}
