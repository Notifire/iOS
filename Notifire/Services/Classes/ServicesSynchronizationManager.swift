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
            let maybeLocalService = local.first { $0.id == remoteServiceSnippet.id }
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
            if representable is ServiceSnippet, let local = localServices.first(where: { $0.id == representable.id }) {
                // case 1: ServiceSnippet but exists in localServices
                localServicesInRepresentables.append(local)
            } else if let local = representable as? LocalService {
                // case 2: representable is already a LocalService
                localServicesInRepresentables.append(local)
            }
        }

        // case 3: LocalServices that haven't been remotely fetched to [ServiceRepresentable] yet
        let restOfLocalPredicate = NSPredicate(format: "NOT \(LocalService.nonOptionalPrimaryKey) IN %@", localServicesInRepresentables.map({ $0.id }))
        let restOfLocalServices = Array(realmProvider.realm.objects(LocalService.self).filter(restOfLocalPredicate))

        // Merge current representables with non-duplicate local services
        resultRepresentables = localServicesInRepresentables + restOfLocalServices

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
                outdatedLocalService.updateDataExceptID(from: serviceSnippet)
            }
        }
    }

    func deleteLocalServiceIfNeeded(from serviceID: Int) {
        let realm = realmProvider.realm
        try? realm.write {
            // check if the service already exists
            guard let localService = realm.object(ofType: LocalService.self, forPrimaryKey: serviceID) else { return }
            // delete service notifications
            realm.delete(localService.notifications)
            // delete the service
            realm.delete(localService)
        }
    }

    func update(localService: LocalService, from service: Service) {
        try? realmProvider.realm.write {
            localService.updateDataExceptID(from: service)
        }
    }

    // MARK: - Thread Safety
    func createServiceRepresentables(from threadSafeRepresentables: ThreadSafeServiceRepresentables) -> [ServiceRepresentable] {
        var representables = [ServiceRepresentable]()
        for representable in threadSafeRepresentables {
            if case .service(let id) = representable {
                guard let localService = realmProvider.realm.object(ofType: LocalService.self, forPrimaryKey: id) else { continue }
                representables.append(localService)
            } else if case .snippet(let snippet) = representable {
                representables.append(snippet)
            }
        }
        return representables
    }

    func createThreadSafeRepresentables(from serviceRepresentables: [ServiceRepresentable]) -> ThreadSafeServiceRepresentables {
        var threadSafeRepresentables = [ThreadSafeServiceRepresentable]()
        for representable in serviceRepresentables {
            if let local = representable as? LocalService, !local.isInvalidated {
                threadSafeRepresentables.append(.service(id: local.id))
            } else if let snippet = representable as? ServiceSnippet {
                threadSafeRepresentables.append(.snippet(snippet))
            }
        }
        return threadSafeRepresentables
    }
}
