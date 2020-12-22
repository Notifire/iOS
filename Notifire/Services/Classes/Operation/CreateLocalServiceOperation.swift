//
//  CreateLocalServiceOperation.swift
//  Notifire
//
//  Created by David Bielik on 21/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// The operation class that takes care of CRUD operations on ServiceSnippets / LocalService / Service (ServiceRepresentable) objects.
class CreateLocalServiceOperation: Operation, ThreadSafeServiceRepresentableOperation {

    /// Represents an error that this operation can result with.
    enum Error: Equatable {
        case serviceDeletedBeforeOperationStarted
        case localServiceObjectNotFound
        case realmError(NSError)
    }

    /// Represents the result of this operation
    enum Result {
        case error(Error)
        case created(localServiceID: Int, at: Int)
    }

    // MARK: - Properties
    var service: Service?

    // MARK: ThreadSafeServiceRepresentableOperation
    var threadSafeServiceRepresentables: ThreadSafeServiceRepresentables?
    let synchronizationManager: ServicesSynchronizationManager

    // MARK: Completion
    var completionHandler: ((Result) -> Void)?

    // MARK: - Initialization
    init(synchronizationManager: ServicesSynchronizationManager) {
        self.synchronizationManager = synchronizationManager
    }

    override func main() {
        guard let service = service else {
            Logger.log(.error, "\(self) service was nil.")
            return
        }

        Logger.log(.debug, "\(self) creating new local service.")

        // Verify that threadSafeServiceRepresentables contain the service.
        guard
            let serviceIndex = threadSafeServiceRepresentables?.firstIndex(where: {
                switch $0 {
                case .service(let id):
                    return id == service.id
                case .snippet(let snippet):
                    return snippet.id == service.id
                }
            })
        else {
            Logger.log(.error, "\(self) couldn't create new local service because it was deleted already.")
            complete(.error(.serviceDeletedBeforeOperationStarted))
            return
        }

        let localService: LocalService
        do {
            localService = try RealmManager.createLocalService(from: service, realm: synchronizationManager.realmProvider.realm)
        } catch let realmError as NSError {
            Logger.log(.error, "\(self) couldn't create new local service. Aborting operation.")
            complete(.error(.realmError(realmError)))
            return
        }

        complete(.created(localServiceID: localService.id, at: serviceIndex))
    }

    func complete(_ result: Result) {
        guard let completion = completionHandler else {
            Logger.log(.info, "\(self) completionHandler=nil")
            return
        }

        Logger.log(.debug, "\(self) finished creating local service.")

        DispatchQueue.main.async {
            completion(result)
        }
    }
}
