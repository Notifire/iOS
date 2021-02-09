//
//  LocalServiceSnippet.swift
//  Notifire
//
//  Created by David Bielik on 08/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class LocalServiceSnippet: Object, Decodable {

    // MARK: - Properties

    // MARK: Dynamic
    /// Service name
    @objc dynamic var name: String = ""
    /// Service ID, primary key.
    @objc dynamic var id: Int = -1

    // Images
    @objc dynamic var smallImageURLString: String?
    @objc dynamic var mediumImageURLString: String?
    @objc dynamic var largeImageURLString: String?

    override static func primaryKey() -> String? {
        return "id"
    }

    private enum CodingKeys: String, CodingKey {
        // Containers
        case apsContainer = "aps"
        case notificationsContainer = "notification"
        case alert = "alert"

        // Values
        case name = "title"
        case serviceID = "service-uid"
    }

    // MARK: - Initialization
    convenience required init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let apsContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .apsContainer)
        let alertContainer = try apsContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .alert)
        name = try alertContainer.decode(String.self, forKey: .name)

        let notificationContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .notificationsContainer)
        id = try notificationContainer.decode(Int.self, forKey: .serviceID)
    }
}
