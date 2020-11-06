//
//  RealmProviding.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmProviding {
    var realm: Realm { get }
}

class RealmProvider: RealmProviding {

    private let userConfiguration: Realm.Configuration

    init?(userSession: UserSession) {

        guard let configuration = RealmManager.createUserConfiguration(from: userSession) else {
            return nil
        }
        userConfiguration = configuration
        do {
            // double check if the realm configuration works.
            _ = try Realm(configuration: userConfiguration)
        } catch let error {
            // if it doesn't, cancel initialization of the session handler
            Logger.log(.error, "\(self) initialization error=<\(error.localizedDescription)>")
            return nil
        }
    }

    var realm: Realm {
        // swiftlint:disable force_try
        return try! Realm(configuration: userConfiguration)
        // swiftlint:enable force_try
    }
}

class NotificationReadUnreadManager {

    static func markNotificationAsRead(notification: LocalNotifireNotification, realm: Realm) {
        guard !notification.isRead else { return }
        swapNotificationReadStatus(notification: notification, realm: realm)
    }

    static func swapNotificationReadStatus(notification: LocalNotifireNotification, realm: Realm) {
        let isRead = notification.isRead
        try? realm.write {
            notification.isRead = !isRead
        }
    }
}
