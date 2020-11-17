//
//  SettingsViewModel.swift
//  Notifire
//
//  Created by David Bielik on 14/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class SettingsViewModel: ViewModelRepresenting {

    // MARK: - Properties
    let userSessionHandler: UserSessionHandler

    var userSession: UserSession {
        return userSessionHandler.userSession
    }

    // MARK: Public
    public var title: String {
        return "Preferences"
    }

    public var copyright: String {
        return "Copyright © 2020 Notifire"
    }

    public var sections: [SettingsSection] = []

    public var rowsAtSection: [SettingsSection: [SettingsSectionRow]] = [:]

    public var cellConfigurations: [SettingsSectionRow: CellConfiguring] = [:]

    // MARK: - Initialization
    init(sessionHandler: UserSessionHandler) {
        self.userSessionHandler = sessionHandler
        updateSections()
    }

    // MARK: - Methods
    /// Update the sections property of this ViewModel.
    func updateSections() {
        self.sections = SettingsSection.allCases
        // User rows
        if userSession.isLoggedWithExternalProvider {
            rowsAtSection[.user] = [.accountProvider, .accountProviderEmail]
        } else {
            rowsAtSection[.user] = [.accountProvider, .accountProviderEmail, .changePassword, .changeEmail]
        }
        // User logout
        rowsAtSection[.userLogout] = [.logout]
        // Notifications
        rowsAtSection[.notifications] = [.deviceTokenStatus, .notificationPrefixSetting]
        // General
        rowsAtSection[.general] = [.applicationVersion, .applicationUpdateAlert]
        // General Last
        rowsAtSection[.generalLast] = [.frequentlyAskedQuestions, .privacyPolicy, .contact]
    }

    // MARK: - Public Methods
    // MARK: Sections
    /// Return the number of sections in the SettingsVC
    public func numberOfSections() -> Int {
        return sections.count
    }

    /// Return the `SettingsSection` for a given section index
    public func section(at index: Int) -> SettingsSection {
        return sections[index]
    }

    // MARK: Rows
    public func row(at indexPath: IndexPath) -> SettingsSectionRow {
        let settingsSection = section(at: indexPath.section)
        return rowsAtSection[settingsSection]?[indexPath.row] ?? .applicationVersion
    }

    /// Return the number of rows for each section.
    public func numberOfRowsIn(section index: Int) -> Int {
        let settingsSection = section(at: index)
        return rowsAtSection[settingsSection]?.count ?? 0
    }

    /// Return a CellConfiguring instance for a specific row.
    /// - Note: This function caches the results for reuse.
    public func cellConfiguration(at indexPath: IndexPath) -> CellConfiguring {
        let settingsRow = row(at: indexPath)
        if let existingConfiguration = cellConfigurations[settingsRow] {
            // return existing configuration
            return existingConfiguration
        }
        let newConfiguration: CellConfiguring
        switch settingsRow {
        // User
        case .accountProvider:
            newConfiguration = SettingsDefaultCellConfiguration(item: ("Logged in via", userSession.providerData.provider.providerText))
        case .accountProviderEmail:
            newConfiguration = SettingsDefaultCellConfiguration(item: ("Email", userSession.providerData.email))
        case .changeEmail:
            newConfiguration = SettingsDisclosureCellConfiguration(item: ("Change your email", nil))
        case .changePassword:
            newConfiguration = SettingsDisclosureCellConfiguration(item: ("Change your password", nil))
        // Logout
        case .logout:
            newConfiguration = SettingsCenteredCellConfiguration(item: "Log out")
        // Notifications
        case .deviceTokenStatus:
            newConfiguration = SettingsDefaultCellConfiguration(item: ("Notifications enabled", "OK"))
        case .applicationUpdateAlert:
            let data = SettingsSwitchData(
                sessionFlagKeypath: \.appUpdateReminderEnabled,
                text: "Receive new version alerts",
                switchedOnDescriptionText: "You will receive in-app alerts when a new version of the app is available to download from the App Store.",
                switchedOffDescriptionText: "You won't receive in-app alerts for new versions of the application.",
                session: userSession
            )
            newConfiguration = SettingsSwitchCellConfiguration(item: data)
        case .notificationPrefixSetting:
            let data = SettingsSwitchData(
                sessionFlagKeypath: \.prefixNotificationTitleEnabled,
                text: "Add service name to notification titles",
                switchedOnDescriptionText: "All notifications you receive will be prefixed with the service name they belong to.",
                switchedOffDescriptionText: "Notification titles won't be changed.",
                session: userSession
            )
            newConfiguration = SettingsSwitchCellConfiguration(item: data)
        // General
        case .frequentlyAskedQuestions:
            newConfiguration = SettingsDisclosureCellConfiguration(item: ("FAQ", nil))
        case .applicationVersion:
            newConfiguration = SettingsDefaultCellConfiguration(item: ("Version", "\(Config.appVersion)"))
        case .privacyPolicy:
            newConfiguration = SettingsDisclosureCellConfiguration(item: ("Privacy policy", nil))
        case .contact:
            newConfiguration = SettingsDisclosureCellConfiguration(item: ("Contact us", nil))
        }
        // Save it for later
        cellConfigurations[settingsRow] = newConfiguration
        return newConfiguration
    }
}
