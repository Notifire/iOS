//
//  UserSessionSettings.swift
//  Notifire
//
//  Created by David Bielik on 12/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class UserSessionSettings: NSObject {

    /// Enum describing keys used in the UserDefaults
    /// Note: User specific
    enum DefaultsKey: String, UserDefaultsKey {
        // MARK: Bool
        /// A boolean flag that is `true` if the user has  turned on app update alerts
        case appUpdateReminderEnabled
        /// A boolean flag that is `true` if user wants to receive prefixed titles.
        case prefixNotificationTitleWithServiceName
        /// A boolean flag that is `true` if user prefers URLs to open directly without warnings.
        case openLinksWarningEnabled

        // MARK: Int
        /// Used to prompt the user for an App Store review.
        case numberOfOpenedNotifications

        // MARK: String
        /// The string of the last version prompted for review
        case lastVersionPromptedForReview
    }

    // MARK: User Preferences
    @UserDefaultBool(key: DefaultsKey.appUpdateReminderEnabled, initialValue: true)
    @objc dynamic var appUpdateReminderEnabled: Bool

    @UserDefaultBool(key: DefaultsKey.prefixNotificationTitleWithServiceName, initialValue: true)
    var prefixNotificationTitleEnabled: Bool

    @UserDefaultInt(key: DefaultsKey.numberOfOpenedNotifications, initialValue: 0)
    var numberOfOpenedNotifications: Int

    @UserDefault<String, DefaultsKey>(key: .lastVersionPromptedForReview)
    var lastVersionPromptedForReview: String?

    // MARK: - Init
    /// - Important: Always set the `.identifier` of each `Bool` value.
    init(identifier: String) {
        self._appUpdateReminderEnabled.identifier = identifier
        self._prefixNotificationTitleEnabled.identifier = identifier
        self._numberOfOpenedNotifications.identifier = identifier
        self._lastVersionPromptedForReview.identifier = identifier

        // Don't touch. Need to keep this as is. For more information check `isFirstLaunchAfterLogin`
        self._isFirstLaunchAfterLogin.identifier = identifier
        super.init()
        setInitialValuesIfNeeded()
    }

    // MARK: - Private
    /// Sets the initial values if the user has logged in for the first time.
    private enum PrivateDefaultsKey: String, UserDefaultsKey {
        /// A boolean flag that is `true` if the user is launching the app for the first time
        case isFirstLaunchAfterLogin
    }

    private func setInitialValuesIfNeeded() {
        guard isFirstLaunchAfterLogin else { return }
        isFirstLaunchAfterLogin = false

        // continue only if the user has logged in for the first time
        Logger.log(.info, "\(self) initializing user defaults")

        let keyPaths: [ReferenceWritableKeyPath<UserSessionSettings, UserDefaultBool<DefaultsKey>>] = [
            \._appUpdateReminderEnabled, \._prefixNotificationTitleEnabled
        ]
        for keyPath in keyPaths {
            self[keyPath: keyPath].wrappedValue = self[keyPath: keyPath].initialValue
        }

        self._numberOfOpenedNotifications.wrappedValue = self._numberOfOpenedNotifications.initialValue
    }

    /// Used to set the default values for the User's settings.
    /// This is used here as a "user-specific" value so that we will have new values for each user.
    @UserDefaultBool(key: PrivateDefaultsKey.isFirstLaunchAfterLogin, negated: true)
    private var isFirstLaunchAfterLogin: Bool
}
