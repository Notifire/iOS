//
//  SettingsRows.swift
//  Notifire
//
//  Created by David Bielik on 15/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Contains all rows for all sections in Settings.
/// The rows that belong to each section can be found in `SettingsSection`
enum SettingsSectionRow: Int {
    // MARK: User
    /// The current (logged in) account provider (e.g. Google, Apple, Email...)
    case accountProvider
    /// The currently used email.
    case accountProviderEmail
    case changeEmail
    case changePassword

    // MARK: User Logout
    case logout

    // MARK: Notifications
    case notificationPermissionStatus
    case goToSettingsButton
    case notificationPrefixSetting

    // MARK: General
    case applicationVersion
    case applicationUpdateAlert
    case openLinksWarningSetting

    case privacyPolicy
    case contact
}
