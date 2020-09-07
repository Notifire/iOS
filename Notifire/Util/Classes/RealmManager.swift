//
//  RealmManager.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmManager {

    private static let realmFileExtension = "realm"
    private static let appGroupIdentifier = "group.com.dvdblk.Notifire"

    static func realmConfigurationFile(for userSession: UserSession) -> String {
        return "\(userSession.email).\(realmFileExtension)"
    }

    static func createUserConfiguration(from userSession: UserSession) -> Realm.Configuration? {
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return nil
        }
        let url = sharedContainerURL.appendingPathComponent(realmConfigurationFile(for: userSession))
        var configuration = Realm.Configuration()
        configuration.fileURL = url
        configuration.schemaVersion = 1
        return configuration
    }

    static func safeRealm(for userSession: UserSession) -> Realm? {
        guard let configuration = createUserConfiguration(from: userSession) else { return nil }
        do {
            return try Realm(configuration: configuration)
        } catch {
            return nil
        }
    }
}
