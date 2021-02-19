//
//  NotificationsViewModel.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

typealias NotificationDetailConfiguration = CellConfiguration<NotificationTableViewCell, DefaultTappableCellAppearance>
typealias NotificationCompactConfiguration = CellConfiguration<ServiceNotificationTableViewCell, DefaultTappableCellAppearance>

class NotificationsViewModel: RealmCollectionViewModel<LocalNotifireNotification> {

    enum ViewState {
        case empty
        case notifications
    }

    // MARK: - Properties
    // MARK: Model
    var viewState: ViewState = .empty {
        didSet {
            guard oldValue != viewState else { return }
            onViewStateChange?(viewState)
        }
    }

    var notificationsFilterData = NotificationsFilterData() {
        didSet {
            // Check if the value has changed
            guard oldValue != notificationsFilterData else { return }
            onNotificationsFilterDataChange?()
            reloadCollection()
        }
    }

    func title() -> String {
        return "Notifications"
    }

    func emptyTitle() -> String {
        return notificationsFilterData.isDefaultFilterData ? "👍" : "No matches found."
    }

    func emptyText() -> String {
        if notificationsFilterData.isDefaultFilterData {
            return "None of your services are having trouble. Check back later."
        } else {
            return "You haven't received any notifications matching this filter."
        }
    }

    func cellConfiguration(for index: Int) -> CellConfiguring {
        return NotificationDetailConfiguration(item: collection[index])
    }

    class var configurationType: CellConfiguring.Type {
        return NotificationDetailConfiguration.self
    }

    // MARK: Callback
    /// Called when the viewState changes.
    var onViewStateChange: ((ViewState) -> Void)?
    /// Called when the notificationsFilterData changes.
    var onNotificationsFilterDataChange: (() -> Void)?

    // MARK: - Initialization
    override init(realmProvider: RealmProviding) {
        super.init(realmProvider: realmProvider)
        setupResultsTokenIfNeeded()
    }

    override func resultsSortOptions() -> RealmCollectionViewModel<LocalNotifireNotification>.SortOptions? {
        let ascending = notificationsFilterData.sorting == .ascending
        return SortOptions(keyPath: LocalNotifireNotification.sortByDateKeyPath, ascending: ascending)
    }

    override func resultsFilterPredicate() -> NSPredicate? {
        var compoundPredicates = [NSPredicate]()
        // Levels
        var levelPredicates = [NSPredicate]()
        for level in notificationsFilterData.levels.keys {
            levelPredicates.append(NSPredicate(format: "rawLevel == %@", level.rawValue))
        }
        let levelPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: levelPredicates)
        compoundPredicates.append(levelPredicate)
        // Date
        switch notificationsFilterData.arrivalTimeframe {
        case .interval(let interval):
            switch interval {
            case .allTime:
                break
            case .last24h:
                let yesterday = Date().addingTimeInterval(-86400)
                compoundPredicates.append(NSPredicate(format: "date >= %@", yesterday as NSDate))
            case .lastWeek:
                let lastWeek = Date().addingTimeInterval(-604800)
                compoundPredicates.append(NSPredicate(format: "date >= %@", lastWeek as NSDate))
            case .lastMonth:
                let lastMonth = Date().addingTimeInterval(-2419200)
                compoundPredicates.append(NSPredicate(format: "date >= %@", lastMonth as NSDate))
            case .lastYear:
                let lastYear = Date().addingTimeInterval(-29030400)
                compoundPredicates.append(NSPredicate(format: "date >= %@", lastYear as NSDate))
            }
        case .specific(let fromDate, let toDate):
            compoundPredicates.append(NSPredicate(format: "date >= %@ AND date <= %@", fromDate as NSDate, toDate as NSDate))
        }
        // URL
        if notificationsFilterData.containsURL {
            compoundPredicates.append(NSPredicate(format: "urlString != nil"))
        }
        // Additional text
        if notificationsFilterData.containsAdditionalText {
            compoundPredicates.append(NSPredicate(format: "text != nil"))
        }
        // Read
        switch notificationsFilterData.readUnreadState {
        case .all:
            break
        case .read:
            compoundPredicates.append(NSPredicate(format: "isRead == YES"))
        case .unread:
            compoundPredicates.append(LocalNotifireNotification.isUnreadPredicate)
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: compoundPredicates)
    }

    override open func onResults(change: RealmCollectionChange<Results<LocalNotifireNotification>>) {
        switch change {
        case .initial(let collection), .update(let collection, _, _, _):
            if collection.isEmpty {
                viewState = .empty
            } else {
                viewState = .notifications
            }
        case .error:
            break
        }
        super.onResults(change: change)
    }

    // MARK: - Public
    /// Swaps Read / Unread state of a `LocalNotifireNotification`
    public func swapNotificationReadUnread(notification: LocalNotifireNotification) {
        guard let token = resultsToken else { return }
        realmProvider.realm.beginWrite()
        notification.isRead = !notification.isRead
        if notificationsFilterData.readUnreadState == .all {
            // if the filters are disabled, don't notify the delegate
            try? realmProvider.realm.commitWrite(withoutNotifying: [token])
        } else {
            // Otherwise notify so that it reloads the view
            try? realmProvider.realm.commitWrite(withoutNotifying: [])
        }
    }

    /// Deletes the notification from the realm.
    public func delete(notification: LocalNotifireNotification) {
        // Make sure it's not deleted already
        guard let safeNotification = notification.safeReference else { return }
        let realm = realmProvider.realm
        try? realm.write {
            realm.delete(safeNotification)
        }
    }

    public func set(notificationsFilterData: NotificationsFilterData) {
        self.notificationsFilterData = notificationsFilterData
    }

    public func markAsRead(notification: LocalNotifireNotification) {
        NotificationReadUnreadManager.markNotificationAsRead(notification: notification, realm: realmProvider.realm)
    }
}

class ServiceNotificationsViewModel: NotificationsViewModel {

    let serviceID: Int
    var service: LocalService? {
        return realmProvider.realm.object(ofType: LocalService.self, forPrimaryKey: serviceID)
    }

    init(realmProvider: RealmProviding, serviceID: Int) {
        self.serviceID = serviceID
        super.init(realmProvider: realmProvider)
    }

    override func resultsFilterPredicate() -> NSPredicate? {
        var predicates = [NSPredicate(format: "service.id == %d OR serviceSnippet.id == %d", serviceID, serviceID)]
        if let filterPredicate = super.resultsFilterPredicate() {
            predicates.append(filterPredicate)
        }
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    override func title() -> String {
        return service?.safeReference?.name ?? ""
    }

    override func emptyTitle() -> String {
        if !notificationsFilterData.isDefaultFilterData {
            return super.emptyTitle()
        }
        return ""
    }

    override func emptyText() -> String {
        if !notificationsFilterData.isDefaultFilterData {
            return super.emptyText()
        }
        return "\(service?.safeReference?.name ?? "This service") didn't send any notifications."
    }

    override func cellConfiguration(for index: Int) -> CellConfiguring {
        return NotificationCompactConfiguration(item: collection[index])
    }

    override class var configurationType: CellConfiguring.Type {
        return NotificationCompactConfiguration.self
    }
}
