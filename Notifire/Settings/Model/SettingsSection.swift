//
//  SettingsSection.swift
//  Notifire
//
//  Created by David Bielik on 15/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Represents each section in the Settings View Controller.
enum SettingsSection: Int {
    /// The User Settings section
    case user
    case userLogout
    /// The Notifications section
    case notificationStatus
    case notifications
    /// The general section (e.g. app build version / nr)
    case general
    /// The general section (e.g. TOS, Contact
    case generalLast

    // MARK: - SubSection
    enum SubSection {
        // User
        case userMain
        case userLogout
        // Notifications
        case notificationPermissionStatus
        case notificationsMain
        // General
        case generalMain
        case generalLast
    }

//    var subsections: [SubSection] {
//        switch self {
//        case .user: return [.userMain, .userLogout]
//        case .notifications: return [.notificationPermissionStatus, .notificationsMain]
//        case .general: return [.generalMain, .generalLast]
//        }
//    }
}
