//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UserNotifications
import SDWebImage

class NotificationService: UNNotificationServiceExtension {

    // MARK: - Properties
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    // MARK: - Overrides
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
                let notification = try? notificationHandler.handle(content: bestAttemptContent),
                let unread = notificationHandler.numberOfUnreadNotifications()
            else {
                contentHandler(bestAttemptContent)
                return
            }
            // Set best attempt content
            bestAttemptContent.userInfo.updateValue(notification.notificationID, forKey: NotifireNotificationsHandler.notificationIDKey)

            // Check if the user has enabled title prefixing
            if previousSession.settings.prefixNotificationTitleEnabled {
                bestAttemptContent.title = "\(notification.level.emoji) \(bestAttemptContent.title)"
            }

            // Update App Icon Badge
            bestAttemptContent.badge = NSNumber(value: unread)

            // Check if the user has enabled showing service images
            if
                previousSession.settings.showServiceImageInNotifications,
                let imageURLString = notification.service?.smallImageURLString,
                let imageCache = UserSessionManager.createImageCache(from: previousSession),
                let tmpSubFolderURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(ProcessInfo.processInfo.globallyUniqueString, isDirectory: true)
            {
                try? FileManager.default.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
                if imageCache.diskImageDataExists(withKey: imageURLString) {
                    // Image already downloaded = found image in cache
                    if let cachedImagePath = imageCache.cachePath(forKey: imageURLString) {
                        let cachedImageURL = URL(fileURLWithPath: cachedImagePath)
                        let tmpImageURL = tmpSubFolderURL.appendingPathComponent(cachedImageURL.lastPathComponent)
                        try? FileManager.default.copyItem(at: cachedImageURL, to: tmpImageURL)
                        if let attachment = try? UNNotificationAttachment(identifier: "image", url: tmpImageURL, options: nil) {
                            bestAttemptContent.attachments.append(attachment)
                        }
                    }
                    contentHandler(bestAttemptContent)
                } else if let imageURL = URL(string: imageURLString) {
                    // Image not downloaded = need to download it now and save it to cache
                    let imageManager = SDWebImageManager(cache: imageCache, loader: SDWebImageManager.shared.imageLoader)
                    imageManager.loadImage(with: imageURL, options: [], progress: nil) { [weak self] (_, data, error, _, _, url) in
                        guard let `self` = self, let bestAttemptContent = self.bestAttemptContent else { return }
                        guard error == nil else {
                            self.contentHandler?(bestAttemptContent)
                            return
                        }
                        let tmpImageURL = tmpSubFolderURL.appendingPathComponent(imageURL.lastPathComponent)
                        try? data?.write(to: tmpImageURL)
                        if let attachment = try? UNNotificationAttachment(identifier: "image", url: tmpImageURL, options: nil) {
                            bestAttemptContent.attachments.append(attachment)
                        }
                        self.contentHandler?(bestAttemptContent)
                    }
                }
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
