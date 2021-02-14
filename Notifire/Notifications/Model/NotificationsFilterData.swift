//
//  NotificationsFilterData.swift
//  Notifire
//
//  Created by David Bielik on 12/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import Foundation

/// Holds the data that describes the currently applied filtering options.
struct NotificationsFilterData: Equatable {

    // MARK: - Properties
    /// Whether to show Read || Unread || All notifications
    var readUnreadState: ReadUnreadState = .all
    /// The levels of notifications to show. e.g. Error + Info
    /// Note: This shouldn't be empty.
    var levels: [NotificationLevel: Bool] = [.info: true, .warning: true, .error: true]
    /// Whether to show notifications that only contain a URL.
    var containsURL: Bool = false
    /// Whether to show notifications that only contain additional text.
    var containsAdditionalText: Bool = false
    /// The timeframe of arrival of the notifications
    var arrivalTimeframe: NotificationArrivalTimeframe = .interval(.allTime)
    /// Sorting
    var sorting: SortOrder = .descending

    /// `true` if the filter data hasn't been changed from the default value (`NotificationsFilterData()`)
    var isDefaultFilterData: Bool {
        return self == NotificationsFilterData()
    }
}

// MARK: - ReadUnreadState
extension NotificationsFilterData {
    enum ReadUnreadState {
        case all
        case read
        case unread
    }
}

// MARK: - SortOrder
extension NotificationsFilterData {
    enum SortOrder: String, CaseIterable, Equatable {
        /// Newest first.
        case descending
        /// Oldest first.
        case ascending
    }
}

// MARK: NotificationArrivalTimeframe
/// Describes the timeframe the notification could have arrived
enum NotificationArrivalTimeframe: Equatable, CustomStringConvertible, CaseIterable {
    case interval(Interval)
    case specific(from: Date, to: Date)

    static var allCases: [NotificationArrivalTimeframe] {
        return [.interval(.allTime), .specific(from: Date(), to: Date())]
    }

    enum Interval: Equatable, CustomStringConvertible {
        case allTime
        case last24h
        case lastWeek
        case lastMonth
        case lastYear

        var description: String {
            switch self {
            case .allTime: return "Anytime"
            case .last24h: return "Last 24 hours"
            case .lastMonth: return "Last month"
            case .lastWeek: return "Last week"
            case .lastYear: return "Last year"
            }
        }
    }

    var description: String {
        switch self {
        case .interval(let interval): return interval.description
        case .specific(let fromDate, let toDate): return "\(fromDate.string(with: .completeDateFirst)) - \(toDate.string(with: .completeDateFirst))"
        }
    }

    var sectionTitle: String {
        switch self {
        case .interval: return "Frequently used"
        case .specific: return "Custom"
        }
    }
}
