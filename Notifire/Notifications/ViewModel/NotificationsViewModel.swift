//
//  NotificationsViewModel.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

typealias NotificationDetailConfiguration = CellConfiguration<NotificationTableViewCell, DefaultCellAppearance>
typealias NotificationCompactConfiguration = CellConfiguration<ServiceNotificationTableViewCell, DefaultCellAppearance>

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

    func title() -> String {
        return "Notifications"
    }

    func emptyTitle() -> String {
        return "👍"
    }

    func emptyText() -> String {
        return "None of your services are having trouble. Check back later."
    }

    func cellConfiguration(for index: Int) -> CellConfiguring {
        return NotificationDetailConfiguration(item: collection[index])
    }

    class var configurationType: CellConfiguring.Type {
        return NotificationDetailConfiguration.self
    }

    // MARK: Callback
    var onViewStateChange: ((ViewState) -> Void)?

    // MARK: - Initialization
    override init(realmProvider: RealmProviding) {
        super.init(realmProvider: realmProvider)
        setupResultsTokenIfNeeded()
    }

    override func resultsSortOptions() -> RealmCollectionViewModel<LocalNotifireNotification>.SortOptions? {
        return SortOptions(keyPath: LocalNotifireNotification.sortByDateKeyPath, ascending: false)
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

    func swapNotificationReadUnread(notification: LocalNotifireNotification) {
        guard let token = resultsToken else { return }
        realmProvider.realm.beginWrite()
        notification.isRead = !notification.isRead
        try? realmProvider.realm.commitWrite(withoutNotifying: [token])
    }
}

class ServiceNotificationsViewModel: NotificationsViewModel {
    let service: LocalService

    init(realmProvider: RealmProviding, service: LocalService) {
        self.service = service
        super.init(realmProvider: realmProvider)
    }

    override func resultsFilterPredicate() -> NSPredicate? {
        return NSPredicate(format: "ANY service.id = %@", service.id)
    }

    override func title() -> String {
        return service.name
    }

    override func emptyTitle() -> String {
        return ""
    }

    override func emptyText() -> String {
        return "\(service.name) didn't send any notifications."
    }

    override func cellConfiguration(for index: Int) -> CellConfiguring {
        return NotificationCompactConfiguration(item: collection[index])
    }

    override class var configurationType: CellConfiguring.Type {
        return NotificationCompactConfiguration.self
    }

}
