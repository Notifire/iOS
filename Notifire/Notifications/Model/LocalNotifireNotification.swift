//
//  LocalNotifireNotification.swift
//  Notifire
//
//  Created by David Bielik on 04/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

class LocalNotifireNotification: Object, Decodable {

    static let sortByDateKeyPath = "date"
    static let isUnreadPredicate = NSPredicate(format: "isRead == %@", NSNumber(value: false))

    /// This variable stores the service snippet (id + name) it belongs to.
    /// - Note:
    ///     -   Used when the notification LocalService is NOT downloaded previously on the device.
    ///        e.g. when the user creates a service X on device A and a notification for X is received on device B (which doesn't previously know about X)
    ///     -   This variable is set to nil whenever the respective LocalService is associated with this notification.
    @objc dynamic var serviceSnippet: LocalServiceSnippet?

    /// This variable is not nil when a `LocalService` has been identified for this notification.
    @objc dynamic var service: LocalService?

    /// Get the service ID that this notification is associated with.
    var currentServiceID: Int? {
        if let serviceID = serviceSnippet?.id {
            return serviceID
        } else if let serviceID = service?.id {
            return serviceID
        } else {
            return nil
        }
    }

    /// Used to store the userID associated with this notification.
    /// Removed (set to nil) in `NotificationService` after checking if the currently logged in userID is equal to this value.
    var userID: Int?

    @objc dynamic var body: String?
    @objc dynamic var urlString: String?
    @objc dynamic var date: Date
    @objc dynamic var text: String?
    @objc dynamic var rawLevel: String
    @objc dynamic var isRead: Bool = false
    @objc dynamic var notificationID: String = UUID().uuidString

    override static func primaryKey() -> String? {
        return "notificationID"
    }

    var level: NotificationLevel {
        return NotificationLevel(rawValue: rawLevel) ?? .info
    }

    var additionalURL: URL? {
        guard let unwrappedUrlString = urlString else { return nil }
        return URL(string: unwrappedUrlString)
    }

    private enum CodingKeys: String, CodingKey {
        // Containers
        case apsContainer = "aps"
        case notificationsContainer = "notification"
        case alert = "alert"

        // Values
        case body = "body"
        case title = "title"
        case urlString = "url"
        case date = "timestamp"
        case text = "text"
        case level = "level"
        case userID = "user-id"
    }

    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let apsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .apsContainer)
        let alertContainer = try apsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .alert)
        body = try alertContainer.decodeIfPresent(String.self, forKey: .body)

        let notificationContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notificationsContainer)
        text = try notificationContainer.decodeIfPresent(String.self, forKey: .text)
        urlString = try notificationContainer.decodeIfPresent(String.self, forKey: .urlString)
        let dateDouble = try notificationContainer.decode(Double.self, forKey: .date)
        date = Date(timeIntervalSince1970: dateDouble)
        rawLevel = try notificationContainer.decode(String.self, forKey: .level)
        userID = try notificationContainer.decode(Int.self, forKey: .userID)
    }

    required init() {
        date = Date()
        rawLevel = "info"
        super.init()
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        date = Date()
        rawLevel = "info"
        super.init()
    }

    required init(value: Any, schema: RLMSchema) {
        date = Date()
        rawLevel = "info"
        super.init()
    }
}
