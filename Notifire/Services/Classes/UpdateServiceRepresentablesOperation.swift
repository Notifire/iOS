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

    // MARK: - Properties
    /// The local services
    var localServices: RealmSwift.Results<LocalService> {
        return synchronizationManager.servicesHandler.collection
    }

    // MARK: Adaptor Operation Supplies
    /// These variables are supplied by the BlockOperation (adaptor)

    /// The main action of this operation.
    var action: LocalRemoteServiceAction?

    // MARK: ThreadSafeServiceRepresentableOperation
    var threadSafeServiceRepresentables: ThreadSafeServiceRepresentables?
    let synchronizationManager: ServicesSynchronizationManager

    // MARK: Completion
    var completionHandler: (([ServiceRepresentable], ServiceRepresentableChanges?) -> Void)?

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
        case .create(let service):
            create(service: service)
        case .update(let service):
            update(service: service)
        case .upsert(let service):
            upsert(service: service)
        case .delete(let service):
            delete(service: service)
        }
    }

    // MARK: - Action Handlers
    // MARK: Util
    private func complete(_ representables: [ServiceRepresentable], _ changes: ServiceRepresentableChanges?) {
        let actionString = action?.description ?? "none"
        Logger.log(.debug, "\(self) finished action: \(actionString). Changes: \(String(describing: changes))")

        // Complete if needed
        guard let completion = completionHandler else {
            Logger.log(.info, "\(self) completionHandler=nil")
            return
        }

        finishOperation(representables: representables) { resolvedRepresentables in
            completion(resolvedRepresentables, changes)
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
        complete(serviceRepresentables + newServiceRepresentables, .partial(changesData: representableChanges))
    }

    // MARK: Websocket
    func create(service: Service) {
        guard var serviceRepresentables = serviceRepresentables else {
            Logger.log(.fault, "\(self) serviceRepresentables is nil")
            return
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
            return
        }

        let representableChanges = ServiceRepresentableChangesData(
            deletions: [],
            insertions: [newIndex.asIndexPath],
            modifications: [],
            moves: []
        )

        // Complete the operation
        complete(serviceRepresentables, .partial(changesData: representableChanges))
    }

    func update(service: Service) {
        guard var serviceRepresentables = serviceRepresentables else {
            Logger.log(.fault, "\(self) serviceRepresentables is nil")
            return
        }

        var nameChanged = false
        if let snippetName = serviceRepresentables.first(where: { $0.id == service.uuid })?.name {
            nameChanged = snippetName != service.name
        } else if let localName = localServices.first(where: { $0.id == service.uuid })?.name {
            nameChanged = localName != service.name
        }

        // We have to take into account the position of the updated service as the name changes the sort order.
        if let representable = serviceRepresentables.enumerated().first(where: { $0.element.id == service.uuid }) {
            // updated service is already in the serviceRepresentables array

            if representable.element is ServiceSnippet {
                // already displayed ServiceSnippet
                let newRepresentable = ServiceSnippet(name: service.name, id: service.uuid, snippetImageURLString: service.imageURLString)
                serviceRepresentables[representable.offset] = newRepresentable
            } else if let local = representable.element as? LocalService {
                // already displayed LocalService
                synchronizationManager.update(localService: local, from: service)
            }

            let changes: ServiceRepresentableChanges
            if nameChanged {
                // if the name has changed, move the updated service to the correct row
                serviceRepresentables.sort(by: { $0.name < $1.name })
                guard let newIndex = serviceRepresentables.firstIndex(where: { $0.id == service.uuid }) else { return }

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

            complete(serviceRepresentables, changes)
        } else if let localService = localServices.first(where: { $0.id == service.uuid }) {
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

                    complete(representableWithUpdatedLocal, .partial(changesData: changes))
                }
            } else {
                // complete without UI changes
                complete(serviceRepresentables, nil)
            }
        }
    }

    /// Update OR Insert (create) service
    func upsert(service: Service) {
        guard let serviceRepresentables = serviceRepresentables else {
            Logger.log(.fault, "\(self) serviceRepresentables is nil")
            return
        }

        let serviceExists =
            serviceRepresentables.first(where: { $0.id == service.uuid }) != nil ||
            localServices.first(where: { $0.id == service.uuid }) != nil

        if serviceExists {
            // update it
            update(service: service)
        } else {
            // create a new one
            create(service: service)
        }
    }

    func delete(service: Service) {
        guard var serviceRepresentables = serviceRepresentables else {
            Logger.log(.fault, "\(self) serviceRepresentables is nil")
            return
        }

        synchronizationManager.deleteLocalServiceIfNeeded(from: service)

        if let representableIndexToDelete = serviceRepresentables.firstIndex(where: { $0.id == service.uuid }) {
            // service already presented in the UI
            // remove the service from the representables array
            serviceRepresentables.remove(at: representableIndexToDelete)

            let changes = ServiceRepresentableChangesData(
                deletions: [representableIndexToDelete.asIndexPath],
                insertions: [],
                modifications: [],
                moves: []
            )

            complete(serviceRepresentables, .partial(changesData: changes))
        } else {
            // service was not in the serviceRepresentables array
            complete(serviceRepresentables, nil)
        }
    }
}
