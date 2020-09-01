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
    static let isReadPredicate = NSPredicate(format: "isRead == %@", NSNumber(value: false))

    var serviceUUID: String?
    @objc dynamic var body: String?
    @objc dynamic var urlString: String?
    @objc dynamic var date: Date
    @objc dynamic var text: String?
    @objc dynamic var rawLevel: String
    @objc dynamic var isRead: Bool = false

    var level: NotificationLevel {
        return NotificationLevel(rawValue: rawLevel) ?? .info
    }

    var additionalURL: URL? {
        guard let unwrappedUrlString = urlString else { return nil }
        return URL(string: unwrappedUrlString)
    }

    let service = LinkingObjects(fromType: LocalService.self, property: "notifications")

    private enum CodingKeys: String, CodingKey {
        case apsContainer = "aps"
        case notificationsContainer = "notification"
        case alert = "alert"
        case body = "body"
        case urlString = "url"
        case date = "datetime"
        case text = "text"
        case level = "level"
        case serviceUUID = "serviceUUID"
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
        let datetimeString = try notificationContainer.decode(String.self, forKey: .date)
        date = DateFormatter.yyyyMMdd.date(from: datetimeString) ?? Date()
        rawLevel = try notificationContainer.decode(String.self, forKey: .level)
        serviceUUID = try notificationContainer.decode(String.self, forKey: .serviceUUID)
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
