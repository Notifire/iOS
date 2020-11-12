//
//  UserSessionSettings.swift
//  Notifire
//
//  Created by David Bielik on 12/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class UserSessionSettings {

    /// Enum describing keys used in the UserDefaults
    /// Note: User specific
    private enum DefaultsKey: String, UserDefaultsKey, CaseIterable {
        /// A boolean flag that is `true` if the user is launching the app for the first time
        case isFirstLaunchAfterLogin
        /// A boolean flag that is `true` if the user has  turned off app update alerts.
        case appUpdateReminderDisabled
    }

    @UserDefault(key: DefaultsKey.appUpdateReminderDisabled)
    var appUpdateReminderDisabled: Bool?

    @UserDefault(key: DefaultsKey.isFirstLaunchAfterLogin)
    var isFirstLaunchAfterLogin: Bool?

    init(session: UserSession) {
        self._appUpdateReminderDisabled.identifier = session.email
        self._isFirstLaunchAfterLogin.identifier = session.email
    }
}
