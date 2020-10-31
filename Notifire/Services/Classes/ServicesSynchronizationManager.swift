//
//  ServicesSynchronizationManager.swift
//  Notifire
//
//  Created by David Bielik on 24/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

/// Synchronizes the remote / local services
class ServicesSynchronizationManager {

    typealias LocalServicesToUpdate = [(LocalService, ServiceSnippet)]

    // MARK: - Properties
    let realmProvider: RealmProviding
    let servicesHandler: RealmCollectionObserver<LocalService>

    /// The last Main thread ThreadSafeReference to localServices
    var lastLocalServicesRef: ThreadSafeReference<Results<LocalService>>

    // MARK: Offline Mode
    /// Representables in the last Online mode state.
    /// Used to come back from offline mode.
    var serviceRepresentablesBeforeOfflineMode: [ServiceRepresentable]?

    var isOfflineModeActive: Bool {
        return serviceRepresentablesBeforeOfflineMode != nil
    }

    // MARK: Pagination
    let paginationHandler = PaginationHandler()

    /// If the pagination should be allowed at this moment.
    var allowsPagination: Bool {
        return paginationHandler.noPagesFetched || (paginationHandler.shouldPaginate && !isOfflineModeActive)
    }

    // MARK: - Initialization
    init(realmProvider: RealmProviding, servicesCollectionHandler: RealmCollectionObserver<LocalService>) {
        self.realmProvider = realmProvider
        self.servicesHandler = servicesCollectionHandler
        lastLocalServicesRef = servicesCollectionHandler.collectionRef
    }

    // MARK: - Methods

    /// Merge the remote `ServiceSnippet`s and array of `LocalService`s into one synchronized array of `ServiceRepresentable`s.
    /// - Note: Also writes changes to a user-specific realm whenever the remote `ServiceSnippet` contains changes diffing the pre-existing `LocalService` with the same ID.
    /// - Parameters:
    ///     - remote: array of `ServiceSnippet` fetched from the remote API
    ///     - shouldUpdateLocal: determines whether to update the local services from the remote ones. Defaults to `true`
    func mergeToRepresentables(remote: [ServiceSnippet], shouldUpdateLocal: Bool = true) -> [ServiceRepresentable] {
        // The resulting array that will contain `ServiceSnippet` and/or `LocalService` objects
        var serviceRepresentables = [ServiceRepresentable]()
        let local = servicesHandler.collection

        // Remote services have priority
        var localServicesToUpdate = LocalServicesToUpdate()
        for remoteServiceSnippet in remote {
            // Check if the remote service is already present in local services
            let maybeLocalService = local.first { $0.uuid == remoteServiceSnippet.id }
            if let localService = maybeLocalService {
                // Found a local service on the device realm matching the remote service id
                localServicesToUpdate.append((localService, remoteServiceSnippet))
                serviceRepresentables.append(localService)
            } else {
                // Haven't found a local service for this remote service id
                serviceRepresentables.append(remoteServiceSnippet)
            }
        }

        // Update the local services from their corresponding remote service snippets
        if shouldUpdateLocal {
            update(localServices: localServicesToUpdate)
        }
        return serviceRepresentables
    }

    //
    func mergeRepresentablesAndLocal(representables: [ServiceRepresentable]) -> [ServiceRepresentable] {
        // The resulting array that will contain `ServiceSnippet` and/or `LocalService` objects
        var resultRepresentables = [ServiceRepresentable]()
        let localServices = servicesHandler.collection

        // Gather service that we will merge later
        var localServicesToMerge = [LocalService]()
        for representable in representables where representable is ServiceSnippet {
            guard let local = localServices.first(where: { $0.id == representable.id }) else { continue }
            localServicesToMerge.append(local)
        }

        // Merge current representables with non-duplicate local services
        resultRepresentables = representables + localServicesToMerge
        // Sort
        resultRepresentables.sort(by: { $0.name < $1.name })
        return resultRepresentables
    }

    /// Updates the local services from their remote service snippets.
    /// - Note: Writes changes into the user's realm.
    private func update(localServices: LocalServicesToUpdate) {
        guard !localServices.isEmpty else { return }
        // Update local services that already exist so they match the remote ones
        try? realmProvider.realm.write {
            for (outdatedLocalService, serviceSnippet) in localServices {
                outdatedLocalService.updateDataExceptUUID(from: serviceSnippet)
            }
        }
    }

    func deleteLocalServiceIfNeeded(from service: Service) {
        let realm = realmProvider.realm
        try? realm.write {
            // check if the service already exists
            guard let localService = realm.object(ofType: LocalService.self, forPrimaryKey: service.uuid) else { return }
            // delete service notifications
            realm.delete(localService.notifications)
            // delete the service
            realm.delete(localService)
        }
    }

    func update(localService: LocalService, from service: Service) {
        try? realmProvider.realm.write {
            localService.updateDataExceptUUID(from: service)
        }
    }
}
