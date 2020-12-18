//
//  NotifireNotificationHandler.swift
//  Notifire
//
//  Created by David Bielik on 15/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UserNotifications
import UIKit

class NotifireNotificationsHandler: NSObject {

    var activeRealmProvider: RealmProviding?

    enum NotificationHandlingError: Error {
        case unknownContent
        case noActiveUserSession
    }

    enum NotificationHandlingResult {
        case successful
        case error(NotificationHandlingError)
    }

    // MARK: - Initialization
    override init() {
        super.init()
        //UNUserNotificationCenter.current().delegate = self
    }

    func getNotification(from userInfo: [AnyHashable: Any]) -> LocalNotifireNotification? {
        guard let userInfoData = try? JSONSerialization.data(withJSONObject: userInfo, options: []),
            let notifireNotification = try? JSONDecoder().decode(LocalNotifireNotification.self, from: userInfoData) else {
                return nil
        }
        return notifireNotification
    }

    func handle(content: UNNotificationContent) throws -> LocalNotifireNotification {
        let userInfoDict = content.userInfo
        guard let notifireNotification = getNotification(from: userInfoDict) else {
            throw NotificationHandlingError.unknownContent
        }
        guard let realm = activeRealmProvider?.realm else {
            throw NotificationHandlingError.noActiveUserSession
        }

        if let service = realm.object(ofType: LocalService.self, forPrimaryKey: notifireNotification.serviceID) {
            // LocalService exists
            try realm.write {
                // Create normal notification that has a parent service.
                notifireNotification.service = service
                service.notifications.append(notifireNotification)
                // we don't need this value anymore (accessible via notification.service variable)
                notifireNotification.serviceID.value = nil
            }
        } else {
            // LocalService doesn't exist yet
            try realm.write {
                // Create orphaned Notification (no parent service)
                realm.add(notifireNotification)
            }
        }
        return notifireNotification
    }

    func numberOfUnreadNotifications() -> Int? {
        guard let realm = activeRealmProvider?.realm else {
            return nil
        }
        let notifications = realm.objects(LocalNotifireNotification.self).filter(LocalNotifireNotification.isReadPredicate)
        return notifications.count
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotifireNotificationsHandler: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //completionHandler([])
    }
}
