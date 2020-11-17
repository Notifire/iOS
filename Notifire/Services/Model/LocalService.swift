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

    // MARK: - Properties
    // MARK: Static
    static let defaultImage: UIImage = #imageLiteral(resourceName: "emoji_service_image")
    static let sortKeyPath = "name"

    // MARK: Dynamic
    /// Service name
    @objc dynamic var name: String = ""
    /// Service ID, primary key.
    @objc dynamic var uuid: String = ""
    /// Service API key used to send notifications.
    @objc dynamic var serviceAPIKey: String = ""

    // Images
    @objc dynamic var imageURLString: String?
    @objc dynamic var snippetImageURLString: String?
    /// image data stored as b64 string
    @objc dynamic var imageDataString: String?
    /// snippet image data stored as b64 string
    @objc dynamic var snippetImageDataString: String?

    @objc dynamic var updatedAt: Date?
    @objc dynamic var info: Bool = true
    @objc dynamic var warning: Bool = true
    @objc dynamic var error: Bool = true
    let notifications = List<LocalNotifireNotification>()

    var image: UIImage {
        return LocalService.createImage(from: imageDataString)
    }

    var snippetImage: UIImage {
        return LocalService.createImage(from: snippetImageDataString)
    }

    static func createImage(from stringData: String?) -> UIImage {
        guard
            let imageDataString = stringData,
            let imageData = Data(base64Encoded: imageDataString),
            let result = UIImage(data: imageData)
        else { return LocalService.defaultImage }
        return result
    }

    override static func primaryKey() -> String? {
        return "uuid"
    }
}
