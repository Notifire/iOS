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
    let username: String
    var deviceToken: String? = nil
    var accessToken: String? = nil
    
    init(refreshToken: String, username: String) {
        self.refreshToken = refreshToken
        self.username = username
    }
}
