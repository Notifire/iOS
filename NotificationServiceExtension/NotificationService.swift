//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        // Modify the notification content here...
        if let bestAttemptContent = bestAttemptContent {
            let notificationHandler = NotifireNotificationsHandler()
            // make sure a user is logged in before displaying the notification
            // (notifications are user-specific resources, we need to ensure *some* user is logged in)
            guard let previousSession = UserSessionManager.previousUserSession() else {
                contentHandler(bestAttemptContent)
                return
            }

            notificationHandler.activeRealmProvider = RealmProvider(userSession: previousSession)
            guard
                let unread = notificationHandler.numberOfUnreadNotifications(),
                let notification = try? notificationHandler.handle(content: bestAttemptContent)
            else {
                contentHandler(bestAttemptContent)
                return
            }
            // Check if the user has enabled title prefixing
            if previousSession.settings.prefixNotificationTitleEnabled {
                bestAttemptContent.title = "\(notification.level.emoji) \(bestAttemptContent.title)"
            }
            // Update App Icon Badge
            bestAttemptContent.badge = NSNumber(value: unread)
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
