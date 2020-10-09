//
//  LocalService.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import RealmSwift

class LocalService: Object {
    static let defaultImage: UIImage = #imageLiteral(resourceName: "emoji_service_image")
    static let sortKeyPath = "name"

    @objc dynamic var name: String = ""
    @objc dynamic var uuid: String = ""
    @objc dynamic var serviceKey: String = ""
    @objc dynamic var rawImage: String = ""
    @objc dynamic var updatedAt: Date?
    @objc dynamic var shouldBeDeleted = false
    @objc dynamic var info: Bool = true
    @objc dynamic var warning: Bool = true
    @objc dynamic var error: Bool = true
    let notifications = List<LocalNotifireNotification>()

    var image: UIImage {
        guard let imageData = Data(base64Encoded: rawImage), let result = UIImage(data: imageData) else { return LocalService.defaultImage }
        return result
    }

    override static func primaryKey() -> String? {
        return "uuid"
    }
}
