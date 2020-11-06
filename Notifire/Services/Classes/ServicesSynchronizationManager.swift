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

    // MARK: Offline Mode
    /// Representables in the last Online mode state.
    /// Used to come back from offline mode.
    var lastThreadSafeServiceRepresentables: ThreadSafeServiceRepresentables?

    var isOfflineModeActive: Bool {
        return lastThreadSafeServiceRepresentables != nil
    }

    // MARK: Pagination
    let paginationHandler = PaginationHandler()

    /// If the pagination should be allowed at this moment.
    var allowsPagination: Bool {
        // Allow pagination IF: can paginate && offline mode is NOT active
        return paginationHandler.canPaginate && !isOfflineModeActive
    }

    // MARK: - Initialization
    init(realmProvider: RealmProviding, servicesCollectionHandler: RealmCollectionObserver<LocalService>) {
        self.realmProvider = realmProvider
        self.servicesHandler = servicesCollectionHandler
    }

    // MARK: - Methods

    /// Merge the remote `ServiceSnippet` and array of `LocalService` obtained from the servicesHandler into one synchronized array of `ServiceRepresentable`.
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

    /// Merge already existing representables with all of the local services obtained from servicesHandler
    /// - Note: Used while swapping online / offline modes.
    func mergeRepresentablesAndLocal(representables: [ServiceRepresentable]) -> [ServiceRepresentable] {
        // The resulting array that will contain `ServiceSnippet` and/or `LocalService` objects
        var resultRepresentables = [ServiceRepresentable]()
        let localServices = servicesHandler.collection

        // Gather service that we will merge later
        var localServicesInRepresentables = [LocalService]()
        for representable in representables {
            if representable is ServiceSnippet, let local = localServices.first(where: { $0.uuid == representable.id }) {
                // case 1: ServiceSnippet but exists in localServices
                localServicesInRepresentables.append(local)
            } else if let local = representable as? LocalService {
                // case 2: representable is already a LocalService
                localServicesInRepresentables.append(local)
            }
        }

        // case 3: LocalServices that haven't been remotely fetched to [ServiceRepresentable] yet
        let restOfLocalPredicate = NSPredicate(format: "NOT uuid IN %@", localServicesInRepresentables.map({ $0.uuid }))
        let restOfLocalServices = Array(realmProvider.realm.objects(LocalService.self).filter(restOfLocalPredicate))

        // Merge current representables with non-duplicate local services
        resultRepresentables = representables + restOfLocalServices

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

    // MARK: - Thread Safety
    /// Creates an array containing `ThreadSafeReference<LocalService>` and `ServiceSnippet` from an array of `ServiceRepresentable`
    /// - Note: Used to return Realm instances from background threads.
    func threadSafeRepresentables(from representables: [ServiceRepresentable]) -> ThreadSafeServiceRepresentables {
        var result = ThreadSafeServiceRepresentables()

        for representable in representables {
            if let localServiceRepresentable = representable as? LocalService {
                // LocalService case
                result.append(ThreadSafeReference(to: localServiceRepresentable))
            } else {
                // ServiceSnippet case
                result.append(representable)
            }
        }

        return result
    }

    /// The inverse operation to `threadSafeRepresentables(from:)`
    func resolve(threadSafeRepresentables: ThreadSafeServiceRepresentables) -> [ServiceRepresentable]? {
        var result = [ServiceRepresentable]()

        for threadSafeRepresentable in threadSafeRepresentables {
            if let threadSafeReference = threadSafeRepresentable as? ThreadSafeReference<LocalService> {
                guard let localService = realmProvider.realm.resolve(threadSafeReference) else { continue }
                result.append(localService)
            } else if let serviceSnippet = threadSafeRepresentable as? ServiceSnippet {
                result.append(serviceSnippet)
            }
        }

        guard result.count == threadSafeRepresentables.count else {
            Logger.log(.fault, "\(self) couldn't resolve threadSafeRepresentables")
            return nil
        }
        return result
    }
}
