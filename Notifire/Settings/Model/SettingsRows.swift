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
enum SettingsSectionRow: Int, TableViewRowDescribing {
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
    case deviceTokenStatus
    case notificationPrefixSetting
    case applicationUpdateAlert

    // MARK: General
    case frequentlyAskedQuestions
    case applicationVersion
    case termsOfService
    case contact

    var rowText: String? {
        switch self {
        // User
        case .accountProvider: return "Logged in via"
        case .accountProviderEmail: return "Email"
        case .changeEmail: return "Change your email"
        case .changePassword: return "Change your password"
        // Logout
        case .logout: return "Logout"
        // Notifications
        case .deviceTokenStatus: return "Notifications enabled"
        case .applicationUpdateAlert: return "Application Update Alerts"
        case .notificationPrefixSetting: return "Prefix notification title with service name"
        // General
        case .frequentlyAskedQuestions: return "FAQ"
        case .applicationVersion: return "Version"
        case .termsOfService: return "Terms of service"
        case .contact: return "Contact us"
        }
    }
}
