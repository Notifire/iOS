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

    var notificationPermissionsObserver: NotificationObserver?
    lazy var shouldShowNotificationPermissionStatus: Bool = userSessionHandler.deviceTokenManager.isDeniedPermissionForPushNotifications

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

    // MARK: Callback
    /// Called when the tableView should be reloaded.
    public var shouldReloadData: (() -> Void)?

    // MARK: - Initialization
    init(sessionHandler: UserSessionHandler) {
        self.userSessionHandler = sessionHandler
        updateSections()
        notificationPermissionsObserver = NotificationObserver(notificationName: .didChangeNotificationPermissionsState, notificationHandler: { [weak self] _ in
            guard let `self` = self else { return }
            let newValue = self.userSessionHandler.deviceTokenManager.isDeniedPermissionForPushNotifications
            let permissionState = self.userSessionHandler.deviceTokenManager.stateModel.state
            guard
                newValue != self.shouldShowNotificationPermissionStatus,
                permissionState == .obtainedUserNotificationAuthorization(status: .authorized) || permissionState == .obtainedUserNotificationAuthorization(status: .denied)
            else { return }
            self.shouldShowNotificationPermissionStatus = newValue
            self.updateSections()
            self.shouldReloadData?()
        })
    }

    // MARK: - Methods
    /// Update the sections property of this ViewModel.
    func updateSections() {
        rowsAtSection = [:]
        var newRowsAtSection: [(SettingsSection, [SettingsSectionRow])] = []
        // User rows
        if userSession.isLoggedWithExternalProvider {
            newRowsAtSection.append((.user, [.accountProvider, .accountProviderEmail]))
        } else {
            newRowsAtSection.append((.user, [.accountProvider, .accountProviderEmail, .changePassword, .changeEmail]))
        }
        // User logout
        newRowsAtSection.append((.userLogout, [.logout]))
        // Notification Permissions
        if shouldShowNotificationPermissionStatus {
            newRowsAtSection.append((.notificationStatus, [.notificationPermissionStatus, .goToSettingsButton]))
        }
        // Notifications
        newRowsAtSection.append((.notifications, [.notificationPrefixSetting]))
        // General
        newRowsAtSection.append((.general, [.applicationVersion, .applicationUpdateAlert]))
        // General Last
        newRowsAtSection.append((.generalLast, [.frequentlyAskedQuestions, .privacyPolicy, .contact]))

        // Update rows
        rowsAtSection = newRowsAtSection.reduce(into: [SettingsSection: [SettingsSectionRow]](), {
            $0[$1.0] = $1.1
        })
        // Update sections
        sections = newRowsAtSection.map({ $0.0 })
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

    public func sectionHeaderText(at index: Int) -> String? {
        switch section(at: index) {
        case .user: return "User"
        case .general: return "General"
        case .notifications:
            return sections.contains(.notificationStatus) ? nil : "Notifications"
        case .notificationStatus:
            return "Notifications"
        default: return nil
        }
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
    // swiftlint:disable function_body_length
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
        case .notificationPermissionStatus:
            newConfiguration = SettingsWarningViewCellConfiguration(item: "")
        case .goToSettingsButton:
            newConfiguration = SettingsActionCellConfiguration(item: "Go to Settings")
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
    // swiftlint:enable function_body_length
}
