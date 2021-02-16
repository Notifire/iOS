//
//  ServiceNotificationsUnreadCountObserver.swift
//  Notifire
//
//  Created by David Bielik on 25/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class NotificationsUnreadCountObserver {

    // MARK: - Properties
    private let observer: RealmCollectionObserver<LocalNotifireNotification>

    /// Return the current unread notifications count.
    var currentUnreadCount: Int {
        return observer.collection.count
    }

    // MARK: - Initialization
    init(realmProvider: RealmProviding, predicates: [NSPredicate] = []) {
        let totalPredicates = predicates + [LocalNotifireNotification.isUnreadPredicate]
        self.observer = RealmCollectionObserver<LocalNotifireNotification>(
            realmProvider: realmProvider,
            sortOptions: nil,
            filterPredicate: NSCompoundPredicate(andPredicateWithSubpredicates: totalPredicates)
        )
        observer.onCollectionChange = { [weak self] change in
            guard let `self` = self else { return }
            switch change {
            case .update:
                self.onNumberNotificationsChange?(self.currentUnreadCount)
            case .error, .initial:
                break
            }
        }
    }

    /// Called when the number of notifications changes.
    /// - Parameters:
    ///     - Int: the current unread notifications count
    var onNumberNotificationsChange: ((Int) -> Void)?
}

class ServiceNotificationsUnreadCountObserver: NotificationsUnreadCountObserver {

    init(realmProvider: RealmProviding, serviceID: Int) {
        super.init(realmProvider: realmProvider, predicates: [
            NSPredicate(format: "serviceSnippet.id == %d OR service.id == %d", serviceID, serviceID)
        ])
    }
}
