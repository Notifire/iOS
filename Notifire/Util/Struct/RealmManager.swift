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

    private static let schemaVersion: UInt64 = 5
    private static let realmFileExtension = "realm"
    private static let appGroupIdentifier = "group.com.dvdblk.Notifire"

    static func realmConfigurationFile(for userSession: UserSession) -> String {
        return "\(userSession.email).\(realmFileExtension)"
    }

    static let realmSharedDatabaseDirectoryURL: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier)!

    /// Create `Realm.Configuration` specific for a given `UserSession`
    static func createUserConfiguration(from userSession: UserSession) -> Realm.Configuration? {
        if !FileManager.default.fileExists(atPath: realmSharedDatabaseDirectoryURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: realmSharedDatabaseDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Logger.log(.error, "\(self) create directory error <\(error.localizedDescription)>")
            }
        }
        let url = realmSharedDatabaseDirectoryURL.appendingPathComponent(realmConfigurationFile(for: userSession))
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
            if oldSchemaVersion < 3 {
                // -    Rename
                //  LocalService.uuid -> LocalService.id
                // -    Update
                //  LocalService.uuid: String -> Int

                migration.deleteData(forType: LocalService.className())

            }
            if oldSchemaVersion < 4 {
                // -    Update/Fix
                //  LocalNotifireNotification.serviceID: String -> Int
                migration.deleteData(forType: LocalNotifireNotification.className())
            }
            if oldSchemaVersion < 5 {
                // -    Delete
                // LocalService.imageURLString
                // LocalService.imageDataString
                // LocalService.snippetImageDataString
                // LocalService.snippetImageURLString
                // -    Update/Fix
                // LocalService.updatedAt has been made required.
                migration.enumerateObjects(ofType: LocalService.className()) { (oldObject, newObject) in
                    if oldObject?["updatedAt"] == nil {
                        newObject?["updatedAt"] = Date()
                    }
                }
                // -    Add
                //- Property 'LocalService.smallImageURLString' has been added.
                //- Property 'LocalService.mediumImageURLString' has been added.
                //- Property 'LocalService.largeImageURLString' has been added.
                //- Property 'LocalService.smallImageDataString' has been added.
                //- Property 'LocalService.mediumImageDataString' has been added.
                //- Property 'LocalService.largeImageDataString' has been added.
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
