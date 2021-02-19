//
//  UpdateServiceRepresentablesOperation.swift
//  Notifire
//
//  Created by David Bielik on 24/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

/// The operation class that takes care of CRUD operations on ServiceSnippets / LocalService / Service (ServiceRepresentable) objects.
class UpdateServiceRepresentablesOperation: Operation, ThreadSafeServiceRepresentableOperation {

    typealias Result = (representables: [ServiceRepresentable], changes: ServiceRepresentableChanges?)

    // MARK: - Properties
    /// The local services
    var localServices: RealmSwift.Results<LocalService> {
        return synchronizationManager.servicesHandler.collection
    }

    var localServiceSnippets: RealmSwift.Results<LocalServiceSnippet> {
        return synchronizationManager.realmProvider.realm.objects(LocalServiceSnippet.self)
    }

    // MARK: Adaptor Operation Supplies
    /// These variables are supplied by the BlockOperation (adaptor)

    /// The main action of this operation.
    var action: LocalRemoteServicesAction?

    // MARK: ThreadSafeServiceRepresentableOperation
    var threadSafeServiceRepresentables: ThreadSafeServiceRepresentables?
    let synchronizationManager: ServicesSynchronizationManager

    // MARK: Completion
    var completionHandler: ((ThreadSafeServiceRepresentables, ServiceRepresentableChanges?) -> Void)?

    // MARK: - Initialization
    init(synchronizationManager: ServicesSynchronizationManager) {
        self.synchronizationManager = synchronizationManager
    }

    override func main() {
        // Get the action of this operation
        guard let action = action else {
            Logger.log(.default, "\(self) action (LocalRemoteServiceAction) was nil.")
            return
        }

        Logger.log(.debug, "\(self) handling action: \(action)")

        // Invoke proper handler
        switch action {
        case .add(let batch):
            add(batch: batch)
        case .changeSingleService(let serviceChangeEvent):
            handle(serviceChangeEvent: serviceChangeEvent)
        case .changeMultipleServices(let serviceChangeEvents):
            serviceChangeEvents.forEach({ handle(serviceChangeEvent: $0, shouldComplete: false) })
            complete(([], nil))
        }
    }

    // MARK: - Action Handlers
    // MARK: Util
    private func handle(serviceChangeEvent: ServiceChangeEvent, shouldComplete: Bool = true) {
        let result: Result?
        switch serviceChangeEvent.serviceChangeData {
        case .create(let service):
            result = create(service: service)
        case .update(let service):
            result = update(service: service)
        case .upsert(let service):
            result = upsert(service: service)
        case .delete(let id):
            result = delete(serviceID: id)
        }

        if shouldComplete, let result = result {
            complete(result)
        }
    }

    private func complete(_ result: Result) {
        let actionString = action?.description ?? "none"
        Logger.log(.debug, "\(self) finished action: \(actionString). Changes: \(String(describing: result.changes))")

        // Complete if needed
        guard let completion = completionHandler else {
            Logger.log(.info, "\(self) completionHandler=nil")
            return
        }

        finishOperation(representables: result.representables) { threadSafeRepresentables in
            completion(threadSafeRepresentables, result.changes)
        }
    }

    // MARK: Pagination
    func add(batch remoteServices: [ServiceSnippet]) {
        guard let serviceRepresentables = serviceRepresentables else {
            Logger.log(.default, "\(self) serviceRepresentables is nil")
            return
        }

        // Get new 'page' of `ServiceRepresentable`
        let newServiceRepresentables = synchronizationManager.mergeToRepresentables(remote: remoteServices)

        // Compute the inserted IndexPaths w.r.t. current representables
        let lastCurrentRowIndex: Int = serviceRepresentables.count

        let insertedIndexes = newServiceRepresentables.enumerated().map({ IndexPath(row: lastCurrentRowIndex + $0.offset) })
        let representableChanges = ServiceRepresentableChangesData(
            deletions: [],
            insertions: insertedIndexes,
            modifications: [],
            moves: []
        )

        // Complete the operation
        complete((serviceRepresentables + newServiceRepresentables, .partial(changesData: representableChanges)))
    }

    // MARK: Websocket
    func create(service: Service) -> Result? {
        guard var serviceRepresentables = serviceRepresentables else {
            Logger.log(.fault, "\(self) serviceRepresentables is nil")
            return nil
        }

//
//        // Create new LocalService
//        guard let newLocalService = synchronizationManager.createLocalService(from: service) else {
//            Logger.log(.fault, "\(self) couldn't create new LocalService")
//            return
//        }

        // Create new ServiceSnippet
        let newServiceSnippet = service.asServiceSnippet

        // Get the index of this new service inside a sorted array of ServiceRepresentables
        serviceRepresentables.append(newServiceSnippet)
        serviceRepresentables.sort { $0.name < $1.name }
        guard let newIndex = serviceRepresentables.firstIndex(where: { $0.id == newServiceSnippet.id }) else {
            Logger.log(.fault, "\(self) couldn't get index of newly created LocalService")
            return nil
        }

        let representableChanges = ServiceRepresentableChangesData(
            deletions: [],
            insertions: [newIndex.asIndexPath],
            modifications: [],
            moves: []
        )

        return (serviceRepresentables, .partial(changesData: representableChanges))
    }

    func update(service: Service) -> Result? {
        guard var serviceRepresentables = serviceRepresentables else {
            Logger.log(.fault, "\(self) serviceRepresentables is nil")
            return nil
        }

        // Update the LocalServiceSnippet if needed
        if let localServiceSnippet = localServiceSnippets.first(where: { $0.id == service.id }) {
            localServiceSnippet.name = service.name
            if let image = service.image {
                localServiceSnippet.smallImageURLString = image.small.absoluteString
                localServiceSnippet.mediumImageURLString = image.medium.absoluteString
                localServiceSnippet.largeImageURLString = image.large.absoluteString
            }
        }

        var nameChanged = false
        if let snippetName = serviceRepresentables.first(where: { $0.id == service.id })?.name {
            nameChanged = snippetName != service.name
        } else if let localName = localServices.first(where: { $0.id == service.id })?.name {
            nameChanged = localName != service.name
        }

        // We have to take into account the position of the updated service as the name changes the sort order.
        if let representable = serviceRepresentables.enumerated().first(where: { $0.element.id == service.id }) {
            // updated service is already in the serviceRepresentables array

            if representable.element is ServiceSnippet {
                // already displayed ServiceSnippet
                let newRepresentable = ServiceSnippet(name: service.name, id: service.id, image: service.image)
                serviceRepresentables[representable.offset] = newRepresentable
            } else if let local = representable.element as? LocalService {
                // already displayed LocalService
                synchronizationManager.update(localService: local, from: service)
            }

            let changes: ServiceRepresentableChanges
            if nameChanged {
                // if the name has changed, move the updated service to the correct row
                serviceRepresentables.sort(by: { $0.name < $1.name })
                guard let newIndex = serviceRepresentables.firstIndex(where: { $0.id == service.id }) else { return nil }

                if newIndex == serviceRepresentables.count - 1 && !synchronizationManager.paginationHandler.isFullyPaginated {
                    // the newIndex is the last row
                    // we can't be sure if this sorted array is correct, because there might be other services between our last service and second-to-last service
                    // thus, delete the last (newly updated) service and paginate from second-to-last to avoid
                    changes = .partial(changesData: ServiceRepresentableChangesData(deletions: [newIndex.asIndexPath], insertions: [], modifications: [], moves: []))
                } else {
                    // the newIndex is properly sorted in our already loaded array of ServiceRepresentable
                    // thus, we can just move it accordingly
                    let move = (representable.offset.asIndexPath, newIndex.asIndexPath)
                    changes = .partial(changesData: ServiceRepresentableChangesData(deletions: [], insertions: [], modifications: [], moves: [move]))
                }
            } else {
                // otherwise just reload the row
                changes = .partial(changesData: ServiceRepresentableChangesData(deletions: [], insertions: [], modifications: [representable.offset.asIndexPath], moves: []))
            }

            return (serviceRepresentables, changes)
        } else if let localService = localServices.first(where: { $0.id == service.id }) {
            // updated service is in local services but hasn't been presented yet
            synchronizationManager.update(localService: localService, from: service)

            if nameChanged {
                // compute if we should move this local service into serviceRepresentables
                var representableWithUpdatedLocal = serviceRepresentables
                representableWithUpdatedLocal.append(localService)

                representableWithUpdatedLocal.sort(by: { $0.name < $1.name })
                if let localServiceIndex = representableWithUpdatedLocal.firstIndex(where: { $0.id == localService.id }), localServiceIndex < representableWithUpdatedLocal.count - 1 {
                    // insert the service into representables
                    let changes = ServiceRepresentableChangesData(deletions: [], insertions: [localServiceIndex.asIndexPath], modifications: [], moves: [])

                    return (representableWithUpdatedLocal, .partial(changesData: changes))
                }
            } else {
                // complete without UI changes
                return (serviceRepresentables, nil)
            }
        }
        return nil
    }

    /// Update OR Insert (create) service
    func upsert(service: Service) -> Result? {
        guard let serviceRepresentables = serviceRepresentables else {
            Logger.log(.fault, "\(self) serviceRepresentables is nil")
            return nil
        }

        let serviceExists =
            serviceRepresentables.first(where: { $0.id == service.id }) != nil ||
            localServices.first(where: { $0.id == service.id }) != nil

        if serviceExists {
            // update it
            return update(service: service)
        } else {
            // create a new one
            return create(service: service)
        }
    }

    func delete(serviceID: Int) -> Result? {
        guard var serviceRepresentables = serviceRepresentables else {
            Logger.log(.fault, "\(self) serviceRepresentables is nil")
            return nil
        }

        if let representableIndexToDelete = serviceRepresentables.firstIndex(where: { $0.id == serviceID }) {
            // service already presented in the UI
            // remove the service from the representables array
            serviceRepresentables.remove(at: representableIndexToDelete)

            let changes = ServiceRepresentableChangesData(
                deletions: [representableIndexToDelete.asIndexPath],
                insertions: [],
                modifications: [],
                moves: []
            )

            synchronizationManager.deleteLocalServiceIfNeeded(from: serviceID)

            return (serviceRepresentables, .partial(changesData: changes))
        } else {
            synchronizationManager.deleteLocalServiceIfNeeded(from: serviceID)
            // service was not in the serviceRepresentables array
            return (serviceRepresentables, nil)
        }
    }
}
