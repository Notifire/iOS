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
    @objc dynamic var id: Int = -1
    /// Service API key used to send notifications.
    @objc dynamic var serviceAPIKey: String = ""

    // Images
    @objc dynamic var smallImageURLString: String?
    @objc dynamic var mediumImageURLString: String?
    @objc dynamic var largeImageURLString: String?
    /// small image data stored as b64 string
    @objc dynamic var smallImageDataString: String?
    /// medum image data stored as b64 string
    @objc dynamic var mediumImageDataString: String?
    /// large image data stored as b64 string
    @objc dynamic var largeImageDataString: String?

    @objc dynamic var updatedAt: Date = Date()
    @objc dynamic var info: Bool = true
    @objc dynamic var warning: Bool = true
    @objc dynamic var error: Bool = true
    let notifications = List<LocalNotifireNotification>()

    override static func primaryKey() -> String? {
        return "id"
    }

    static var nonOptionalPrimaryKey: String {
        return primaryKey() ?? #keyPath(LocalService.id)
    }

    // MARK: Images
    func image(from keyPath: KeyPath<LocalService, String?>) -> UIImage {
        return LocalService.createImage(from: self[keyPath: keyPath])
    }

    var smallImage: UIImage {
        return image(from: \.smallImageDataString)
    }

    var mediumImage: UIImage {
        return image(from: \.mediumImageDataString)
    }

    var largeImage: UIImage {
        return image(from: \.largeImageDataString)
    }

    static func createImage(from stringData: String?) -> UIImage {
        guard
            let imageDataString = stringData,
            let imageData = Data(base64Encoded: imageDataString),
            let result = UIImage(data: imageData)
        else { return LocalService.defaultImage }
        return result
    }
}
