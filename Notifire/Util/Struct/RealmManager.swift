//
//  RealmManager.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

/// Manager class for Realm operations.
struct RealmManager {

    private static let schemaVersion: UInt64 = 2
    private static let realmFileExtension = "realm"
    private static let appGroupIdentifier = "group.com.dvdblk.Notifire"

    static func realmConfigurationFile(for userSession: UserSession) -> String {
        return "\(userSession.email).\(realmFileExtension)"
    }

    /// Create `Realm.Configuration` specific for a given `UserSession`
    static func createUserConfiguration(from userSession: UserSession) -> Realm.Configuration? {
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return nil
        }
        let url = sharedContainerURL.appendingPathComponent(realmConfigurationFile(for: userSession))
        var configuration = Realm.Configuration()
        configuration.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                // --
                // skip, safeguard for original versions of Notifire where schemaVersion = 0 || 1
                // --
            }
            if oldSchemaVersion < 2 {
                // -    Rename
                migration.renameProperty(onType: LocalService.className(), from: "serviceKey", to: "serviceAPIKey")

                // -    Delete
                // LocalService.shouldBeDeleted

                // -    Add
                // LocalService.snippetImageDataString
                // LocalService.imageURLString
                // LocalService.snippetImageURLString
                // LocalNotifireNotification.service
                // LocalNotifireNotification.serviceID

                // -    Update
                migration.enumerateObjects(ofType: LocalService.className()) { (oldObject, newObject) in
                    let rawImage = oldObject?["rawImage"]
                    newObject?["imageDataString"] = rawImage
                }
            }
        }
        configuration.fileURL = url
        configuration.schemaVersion = schemaVersion
        return configuration
    }

    /// Creates a Realm for a given user session. Returns `nil` if encounters errors.
    static func safeRealm(for userSession: UserSession) -> Realm? {
        guard let configuration = createUserConfiguration(from: userSession) else { return nil }
        do {
            return try Realm(configuration: configuration)
        } catch {
            return nil
        }
    }
}
