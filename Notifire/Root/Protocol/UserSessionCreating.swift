//
//  UserSessionCreating.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// ViewModel that creates a `UserSession` thus needs to inform a sessionDelegate about it.
protocol UserSessionCreating: ViewModelRepresenting {
    var sessionDelegate: UserSessionCreationDelegate? { get set }
}
