//
//  NotificationsFilterViewModel.swift
//  Notifire
//
//  Created by David Bielik on 12/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import Foundation

enum NotificationsFilterSection: Int, SectionAndRowRepresentable, CaseIterable {
    /// Whether notification is read or unread
    case sortingOrder
    case levels
    case data
    case readState
    case reset
}

enum NotificationsFilterSectionRow: Int, SectionAndRowRepresentable {
    // MARK: ReadState
    case showAll
    case read
    case unread

    // MARK: Levels
    case info
    case warning
    case error

    // MARK: Notification Data
    case url
    case additionalText
    case timeframe

    // MARK: Sorting
    case newestFirst
    case oldestFirst

    // MARK: Reset
    case reset
}

class NotificationsFilterViewModel: ViewModelRepresenting, StaticTableViewViewModel {

    // MARK: StaticTableViewModel
    typealias Section = NotificationsFilterSection
    typealias SectionRow = NotificationsFilterSectionRow

    public var sections: [Section] = []
    public var rowsAtSection: [Section: [SectionRow]] = [:]
    public var cellConfigurations: [SectionRow: CellConfiguring] = [:]

    // MARK: - Properties
    let initialFilterData: NotificationsFilterData
    var notificationsFilterData: NotificationsFilterData {
        didSet {
            guard oldValue != notificationsFilterData else { return }
            // Check if the new filter is different than the initial filter
            onNotificationsFilterDataChange?(notificationsFilterData == initialFilterData)
        }
    }

    // MARK: Callback
    /// Called when the filter data changes. Parameter is `true` if the data is the same as `initialFilterData`.
    var onNotificationsFilterDataChange: ((Bool) -> Void)?

    // MARK: - Initialization
    init(filterData: NotificationsFilterData) {
        self.notificationsFilterData = filterData
        self.initialFilterData = filterData
        updateSections()
    }

    // MARK: Public
    public func resetFilterData() {
        notificationsFilterData = NotificationsFilterData()
    }

    // MARK: StaticTableViewViewModel
    func titleForHeaderInSection(at index: Int) -> String? {
        switch section(at: index) {
        case .readState: return "Read / Unread"
        case .levels: return "Levels"
        case .data: return "Additional data"
        case .sortingOrder: return "Order by"
        case .reset: return nil
        }
    }

    func createSectionsAndRows() -> [(NotificationsFilterSection, [NotificationsFilterSectionRow])] {
        var newSections: [(NotificationsFilterSection, [NotificationsFilterSectionRow])] = []

        for section in NotificationsFilterSection.allCases {
            let sectionRows: [NotificationsFilterSectionRow]
            switch section {
            case .readState: sectionRows = [.showAll, .read, .unread]
            case .levels: sectionRows = [.info, .warning, .error]
            case .data: sectionRows = [.timeframe, .url, .additionalText]
            case .sortingOrder: sectionRows = [.newestFirst, .oldestFirst]
            case .reset: sectionRows = [.reset]
            }
            newSections.append((section, sectionRows))
        }

        return newSections
    }

    func cellConfiguration(at indexPath: IndexPath) -> CellConfiguring {
        let filterRow = row(at: indexPath)
        if filterRow != .timeframe, let existingConfiguration = cellConfigurations[filterRow] {
            // return existing configuration
            return existingConfiguration
        }
        let newConfiguration: CellConfiguring
        switch filterRow {
        // Read
        case .showAll:
            newConfiguration = DefaultCellConfiguration(item: "Show all notifications")
        case .read:
            newConfiguration = DefaultCellConfiguration(item: "Only read notifications")
        case .unread:
            newConfiguration = DefaultCellConfiguration(item: "Only unread notifications")
        case .info:
            newConfiguration = NotificationLevelCellConfiguration(item: NotificationLevel.info)
        case .warning:
            newConfiguration = NotificationLevelCellConfiguration(item: NotificationLevel.warning)
        case .error:
            newConfiguration = NotificationLevelCellConfiguration(item: NotificationLevel.error)
        case .url:
            newConfiguration = DefaultImageTextCellConfiguration(item: ("Contains URL", #imageLiteral(resourceName: "link")))
        case .additionalText:
            newConfiguration = DefaultImageTextCellConfiguration(item: ("Contains additional text", #imageLiteral(resourceName: "doc.plaintext")))
        case .timeframe:
            let model = DateDisclosureCellModel(selectedDateString: notificationsFilterData.arrivalTimeframe.description, image: #imageLiteral(resourceName: "calendar"))
            newConfiguration = NotificationFilterDateCellConfiguration(item: model)
        case .newestFirst:
            newConfiguration = DefaultCellConfiguration(item: "Newest first")
        case .oldestFirst:
            newConfiguration = DefaultCellConfiguration(item: "Oldest first")
        case .reset:
            newConfiguration = PositiveCenteredCellConfiguration(item: "Reset filters")
        }

        // Save it for later
        cellConfigurations[filterRow] = newConfiguration
        return newConfiguration
    }
}

typealias DefaultCellConfiguration = CellConfiguration<UITableViewReusableCell, DefaultCellAppearance>
typealias DefaultImageTextCellConfiguration = CellConfiguration<UITableViewImageTextCell, DefaultCellAppearance>
typealias DefaultDisclosureCellConfiguration = CellConfiguration<UITableViewReusableCell, DisclosureCellAppearance>
typealias ImageTextDisclosureCellConfiguration = CellConfiguration<UITableViewImageTextCell, DisclosureCellAppearance>
typealias NotificationLevelCellConfiguration = CellConfiguration<UITableViewLevelCell, DefaultCellAppearance>
typealias PositiveCenteredCellConfiguration = CellConfiguration<UITableViewCenteredPositiveCell, DefaultTappableCellAppearance>
typealias NotificationFilterDateCellConfiguration = CellConfiguration<DateDisclosureTableViewCell, DisclosureCellAppearance>
