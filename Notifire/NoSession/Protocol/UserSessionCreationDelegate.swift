//
//  UserSessionCreationDelegate.swift
//  Notifire
//
//  Created by David Bielik on 16/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol UserSessionCreationDelegate: class {
    func didCreate(session: UserSession)
}
