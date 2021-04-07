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

    enum NotificationHandlingError: Error {
        case unknownContent(Error)
        case noActiveUserSession
    }

    enum NotificationHandlingResult {
        case successful
        case error(NotificationHandlingError)
    }

    // MARK: - Properties
    static let notificationIDKey = LocalNotifireNotification.primaryKey() ?? "notificationID"

    var activeRealmProvider: RealmProviding?

    /// `true` if a notification tap is currently being handled by this object. Used to avoid multiple handlings at the same time.
    var currentlyHandlingNotificationTap = false

    // MARK: Callback
    /// Called when the user taps on a notification. Parameter is `notificationID`.
    var onNotificationTap: ((String) -> Void)?

    // MARK: - Initialization
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func getNotification(from userInfo: [AnyHashable: Any]) throws -> (LocalNotifireNotification, LocalServiceSnippet) {
        let userInfoData = try JSONSerialization.data(withJSONObject: userInfo, options: [])
        let notificationDecoder = JSONDecoder()
        notificationDecoder.dateDecodingStrategy = .timestampStrategy
        let notifireNotification = try notificationDecoder.decode(LocalNotifireNotification.self, from: userInfoData)
        let notificationServiceSnippet = try notificationDecoder.decode(LocalServiceSnippet.self, from: userInfoData)
        return (notifireNotification, notificationServiceSnippet)
    }

    /// Create an instance of `LocalNotifireNotification`
    func handle(content: UNNotificationContent) throws -> LocalNotifireNotification {
        let userInfoDict = content.userInfo
        let notifireNotification: LocalNotifireNotification
        let localServiceSnippet: LocalServiceSnippet
        do {
            (notifireNotification, localServiceSnippet) = try getNotification(from: userInfoDict)
        } catch let error {
            throw NotificationHandlingError.unknownContent(error)
        }

        guard let realm = activeRealmProvider?.realm else {
            throw NotificationHandlingError.noActiveUserSession
        }

        if let service = realm.object(ofType: LocalService.self, forPrimaryKey: localServiceSnippet.id) {
            // LocalService exists
            try realm.write {
                // Create normal notification that has a parent service.
                notifireNotification.service = service
                service.notifications.append(notifireNotification)
            }
        } else {
            // LocalService doesn't exist yet
            try realm.write {
                realm.add(localServiceSnippet, update: .modified)
                notifireNotification.serviceSnippet = localServiceSnippet

                // Create a Notification without a parent service
                realm.add(notifireNotification)
            }
        }
        realm.refresh()
        return notifireNotification
    }

    /// Return the number of unread notifications.
    /// Used to update the App Icon Badge number.
    func numberOfUnreadNotifications() -> Int? {
        guard let realm = activeRealmProvider?.realm else {
            return nil
        }
        let notifications = realm.objects(LocalNotifireNotification.self).filter(LocalNotifireNotification.isUnreadPredicate)
        return notifications.count
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotifireNotificationsHandler: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Check if the notification contains notificationID
        if !currentlyHandlingNotificationTap, let notificationID = userInfo[NotifireNotificationsHandler.notificationIDKey] as? String {
            currentlyHandlingNotificationTap = true
            onNotificationTap?(notificationID)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.currentlyHandlingNotificationTap = false
            }
        }
    }
}
