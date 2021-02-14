//
//  SettingsViewModel.swift
//  Notifire
//
//  Created by David Bielik on 14/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

import UIKit

protocol TableViewDataSourceDescribing {
    associatedtype TableViewViewModel: StaticTableViewViewModel

    init(tableViewViewModel: TableViewViewModel)
}

/// Implementation of a generic tableview datasource that works with a `StaticTableViewModel`.
class GenericTableViewDataSource<TableViewViewModel: StaticTableViewViewModel>: NSObject, UITableViewDataSource {

    // MARK: - Properties
    let tableViewViewModel: TableViewViewModel

    // MARK: - Initialization
    init(tableViewViewModel: TableViewViewModel) {
        self.tableViewViewModel = tableViewViewModel
    }

    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewViewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewViewModel.numberOfRowsIn(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configuration = tableViewViewModel.cellConfiguration(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: configuration).reuseIdentifier, for: indexPath)
        configuration.configure(cell: cell)
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewViewModel.titleForHeaderInSection(at: section)
    }

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableViewViewModel.titleForFooterInSection(at: section)
    }
}

class SettingsTableViewDataSource: GenericTableViewDataSource<SettingsViewModel> {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let preferencesCell = cell as? SettingsSwitchTableViewCell {
            preferencesCell.onCellHeightChange = {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
        cell.backgroundColor = .compatibleSystemBackground
        return cell
    }
}

protocol SectionAndRowRepresentable: ExpressibleByIntegerLiteral, Hashable {}
extension SectionAndRowRepresentable  where Self: RawRepresentable, Self.RawValue == Self.IntegerLiteralType {
    init(integerLiteral value: IntegerLiteralType) {
        self = Self.init(rawValue: value) ?? 0
    }
}

protocol StaticTableViewViewModel: class {
    /// The section Enum. (Each sectio in the static table view has one case)
    associatedtype Section: SectionAndRowRepresentable
    /// The row Enum. (Each row in the static table view has one case)
    associatedtype SectionRow: SectionAndRowRepresentable

    /// The sections of the table view
    var sections: [Section] { get set }
    /// The rows in each section
    var rowsAtSection: [Section: [SectionRow]] { get set }
    /// The cell configurations for each `SectionRow`.
    var cellConfigurations: [SectionRow: CellConfiguring] { get set }

    /// Creates the sections. This method is used in `updateSections`
    func createSectionsAndRows() -> [(Section, [SectionRow])]
    /// Update the sections property of this ViewModel.
    /// - Important: Don't provide a custom implementation for this method
    func updateSections()

    // MARK: Section
    /// Return the number of sections.
    func numberOfSections() -> Int
    /// Return the `Section` for a given section index
    func section(at index: Int) -> Section
    /// Return the section header title at section index.
    /// Default implementation returns `nil`.
    func titleForHeaderInSection(at index: Int) -> String?
    /// Return the section footer title at section index.
    /// Default implementation returns `nil`.
    func titleForFooterInSection(at index: Int) -> String?

    // MARK: SectionRow
    /// Return `SectionRow` at specified indexPath
    func row(at indexPath: IndexPath) -> SectionRow
    /// Return the number of rows for each section.
    func numberOfRowsIn(section index: Int) -> Int

    /// Return a CellConfiguring instance for a specific row.
    /// - Note: This function caches the results for reuse.
    func cellConfiguration(at indexPath: IndexPath) -> CellConfiguring
}

extension StaticTableViewViewModel {

    // MARK: Sections
    public func numberOfSections() -> Int {
        return sections.count
    }

    public func section(at index: Int) -> Section {
        return sections[index]
    }

    public func titleForHeaderInSection(at index: Int) -> String? {
        return nil
    }

    func titleForFooterInSection(at index: Int) -> String? {
        return nil
    }

    // MARK: Rows
    public func row(at indexPath: IndexPath) -> SectionRow {
        let settingsSection = section(at: indexPath.section)
        return rowsAtSection[settingsSection]?[indexPath.row] ?? 0
    }

    public func numberOfRowsIn(section index: Int) -> Int {
        let settingsSection = section(at: index)
        return rowsAtSection[settingsSection]?.count ?? 0
    }

    func updateSections() {
        // Reset these values
        rowsAtSection = [:]
        cellConfigurations = [:]

        // Get new sections
        let newRowsAtSection = createSectionsAndRows()

        // Update rows
        rowsAtSection = newRowsAtSection.reduce(into: [Section: [SectionRow]](), {
            $0[$1.0] = $1.1
        })
        // Update sections
        sections = newRowsAtSection.map({ $0.0 })
    }
}

class SettingsViewModel: ViewModelRepresenting, StaticTableViewViewModel {

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

    // MARK: StaticTableViewModel
    typealias Section = SettingsSection
    typealias SectionRow = SettingsSectionRow

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
        // Notification permissions Switch
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

    // MARK: - StaticTableViewModel
    func createSectionsAndRows() -> [(SettingsSection, [SettingsSectionRow])] {
        var newSections: [(SettingsSection, [SettingsSectionRow])] = []
        // User rows
        if userSession.isLoggedWithExternalProvider {
            newSections.append((.user, [.accountProvider, .accountProviderEmail]))
        } else {
            newSections.append((.user, [.accountProvider, .accountProviderEmail, .changePassword, .changeEmail]))
        }
        // User logout
        newSections.append((.userLogout, [.logout]))
        // Notification Permissions
        if shouldShowNotificationPermissionStatus {
            newSections.append((.notificationStatus, [.notificationPermissionStatus, .goToSettingsButton]))
        }
        // Notifications
        newSections.append((.notifications, [.notificationPrefixSetting]))
        // General
        newSections.append((.general, [.applicationVersion, .applicationUpdateAlert]))
        // General Last
        newSections.append((.generalLast, [.privacyPolicy, .contact]))
        return newSections
    }

    func titleForHeaderInSection(at index: Int) -> String? {
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

    func titleForFooterInSection(at index: Int) -> String? {
        if section(at: index) == .generalLast {
            return "Copyright © 2020 Notifire"
        } else {
            return nil
        }
    }

    /// Return a CellConfiguring instance for a specific row.
    /// - Note: This function caches the results for reuse.
    // swiftlint:disable function_body_length
    func cellConfiguration(at indexPath: IndexPath) -> CellConfiguring {
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
            newConfiguration = SettingsDisclosureCellConfiguration(item: "Change your email")
        case .changePassword:
            newConfiguration = SettingsDisclosureCellConfiguration(item: "Change your password")
        // Logout
        case .logout:
            newConfiguration = SettingsCenteredCellConfiguration(item: "Log out")
        // Notifications
        case .notificationPermissionStatus:
            newConfiguration = SettingsWarningViewCellConfiguration(item: "")
        case .goToSettingsButton:
            newConfiguration = SettingsActionCellConfiguration(item: "Go to Settings")
        case .notificationPrefixSetting:
            let data = SettingsSwitchData(
                sessionFlagKeypath: \.prefixNotificationTitleEnabled,
                shouldObserveFlag: false,
                text: "Add notification level to title",
                switchedOnDescriptionText: "All notifications will have their titles prefixed with their notification level.",
                switchedOffDescriptionText: "Notification titles will only contain their service name.",
                session: userSession
            )
            newConfiguration = SettingsSwitchCellConfiguration(item: data)
        // General
        case .applicationVersion:
            newConfiguration = SettingsDefaultCellConfiguration(item: ("Version", "\(Config.appVersion)"))
        case .applicationUpdateAlert:
            let data = SettingsSwitchData(
                sessionFlagKeypath: \.appUpdateReminderEnabled,
                shouldObserveFlag: true,
                text: "Receive new version alerts",
                switchedOnDescriptionText: "You will receive in-app alerts when a new version of the app is available to download from the App Store.",
                switchedOffDescriptionText: "You won't receive in-app alerts for new versions of the application.",
                session: userSession
            )
            newConfiguration = SettingsSwitchCellConfiguration(item: data)
        case .privacyPolicy:
            newConfiguration = SettingsDisclosureCellConfiguration(item: "Privacy policy")
        case .contact:
            newConfiguration = SettingsDisclosureCellConfiguration(item: "Contact us")
        }
        // Save it for later
        cellConfigurations[settingsRow] = newConfiguration
        return newConfiguration
    }
    // swiftlint:enable function_body_length
}
