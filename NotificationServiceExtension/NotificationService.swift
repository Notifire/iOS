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

        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
            let notificationHandler = NotifireNotificationsHandler()
            let sessionManager = UserSessionManager()
            guard let previousSession = sessionManager.previousUserSession() else {
                contentHandler(bestAttemptContent)
                return
            }
            notificationHandler.activeRealmProvider = RealmProvider(userSession: previousSession)
            guard let unread = notificationHandler.numberOfUnreadNotifications(),
                let (service, notification) = try? notificationHandler.handle(content: bestAttemptContent) else {
                contentHandler(bestAttemptContent)
                return
            }
            bestAttemptContent.title = "\(notification.level.emoji) \(service.name):"
            bestAttemptContent.badge = NSNumber(integerLiteral: unread)
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
