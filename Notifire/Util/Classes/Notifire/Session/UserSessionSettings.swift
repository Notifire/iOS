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
        /// A boolean flag that is `true` if the user has  turned on app update alerts
        case appUpdateReminderEnabled
        /// A boolean flag that is `true` if user wants to receive prefixed titles.
        case prefixNotificationTitleWithServiceName
    }

    // MARK: User Preferences
    @UserDefaultBool(key: DefaultsKey.appUpdateReminderEnabled, initialValue: true)
    var appUpdateReminderEnabled: Bool

    @UserDefaultBool(key: DefaultsKey.prefixNotificationTitleWithServiceName, initialValue: true)
    var prefixNotificationTitleEnabled: Bool

    // MARK: App Settings
    @UserDefaultBool(key: DefaultsKey.isFirstLaunchAfterLogin, negated: true)
    var isFirstLaunchAfterLogin: Bool

    // MARK: - Init
    init(identifier: String) {
        self._appUpdateReminderEnabled.identifier = identifier
        self._isFirstLaunchAfterLogin.identifier = identifier
        self._prefixNotificationTitleEnabled.identifier = identifier

        setInitialValuesIfNeeded()
    }

    // MARK: - Private
    /// Sets the initial values if the user has logged in for the first time.
    private func setInitialValuesIfNeeded() {
        guard isFirstLaunchAfterLogin else { return }
        isFirstLaunchAfterLogin = false

        // continue only if the user has logged in for the first time
        Logger.log(.info, "\(self) initializing user defaults")

        let keyPaths: [ReferenceWritableKeyPath<UserSessionSettings, UserDefaultBool<DefaultsKey>>] = [\._appUpdateReminderEnabled, \._prefixNotificationTitleEnabled]
        for keyPath in keyPaths {
            self[keyPath: keyPath].wrappedValue = self[keyPath: keyPath].initialValue
        }
    }
}
