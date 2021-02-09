//
//  ServiceNotificationsObserver.swift
//  Notifire
//
//  Created by David Bielik on 25/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class ServiceNotificationsObserver {

    private let observer: RealmCollectionObserver<LocalNotifireNotification>

    init(realmProvider: RealmProviding, serviceID: Int) {
        self.observer = RealmCollectionObserver<LocalNotifireNotification>(
            realmProvider: realmProvider,
            sortOptions: nil,
            filterPredicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "serviceSnippet.id == %d OR service.id == %d", serviceID, serviceID),
                LocalNotifireNotification.isUnreadPredicate
            ]))
        observer.onCollectionChange = { [weak self] change in
            switch change {
            case .update:
                self?.onNumberNotificationsChange?(serviceID)
            case .error, .initial:
                break
            }
        }
    }

    /// Called when the number of notifications changes.
    /// - Parameters:
    ///     - Int: the serviceID that changed its notification unread count.
    var onNumberNotificationsChange: ((Int) -> Void)?
}
