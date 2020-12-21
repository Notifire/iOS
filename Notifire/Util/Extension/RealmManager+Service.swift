//
//  RealmManager+Service.swift
//  Notifire
//
//  Created by David Bielik on 15/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

/// Methods related to CRUD operations on `LocalService`
extension RealmManager {

    /// Create a `LocalService` in the user's realm.
    /// - Note: Writes changes into the user's realm.
    static func createLocalService(from service: Service, realm: Realm) -> LocalService? {
        do {
            var localService: LocalService?
            let existingObject = realm.object(ofType: LocalService.self, forPrimaryKey: service.id)
            guard existingObject == nil else {
                Logger.log(.info, "\(self) another realm object with the same id (\(service.id)) is already present, returning it instead.")
                return existingObject
            }
            try realm.write {
                // Create the service
                let local = LocalService()
                local.updateData(from: service)

                // Add existing notifications to this service
                let notificationPredicate = NSPredicate(format: "serviceID = %d", service.id)
                let serviceNotifications = realm.objects(LocalNotifireNotification.self).filter(notificationPredicate)

                for serviceNotification in serviceNotifications {
                    // Set the notification's parent to the new local service
                    serviceNotification.service = local
                    serviceNotification.serviceID.value = nil
                }

                // add it to the user's realm
                realm.add(local)
                localService = local
            }
            return localService
        } catch {
            return nil
        }
    }

    static func delete(localService: LocalService, realm: Realm) throws {
        try realm.write {
            // Delete the notifcations
            realm.delete(localService.notifications)
            // Delete the service
            realm.delete(localService)
        }
    }
}
