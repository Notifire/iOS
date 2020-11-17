//
//  SettingsSection.swift
//  Notifire
//
//  Created by David Bielik on 15/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Represents each section in the Settings View Controller.
enum SettingsSection: Int, TableViewSection {
    /// The User Settings section
    case user
    case userLogout
    /// The Notifications section
    case notifications
    /// The general section (e.g. app build version / nr)
    case general
    /// The general section (e.g. TOS, Contact
    case generalLast

    var sectionHeaderText: String? {
        switch self {
        case .user: return "User"
        case .userLogout: return nil
        case .notifications: return "Notifications"
        case .general: return "General"
        case .generalLast: return nil
        }
    }
}
