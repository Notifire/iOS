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
        /// When a service creation error occurs
        case error(Error)
        /// When a service is created.
        /// The `at` parameter determines whether the service should be updated in the threadSafeServiceRepresentables array.
        ///
        /// Service should be updated in threadSafeRepresentables when all of these cases are met:
        /// - the user opens a notification
        /// - the service the notification belongs to is not yet present in the threadSafeRepresentables array
        /// - the service the notifications belongs to is not yet created locally (no LocalService in Realm)
        case created(localServiceID: Int, at: Int?)
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
        let localService: LocalService
        do {
            localService = try RealmManager.createLocalService(from: service, realm: synchronizationManager.realmProvider.realm)
        } catch let realmError as NSError {
            Logger.log(.error, "\(self) couldn't create new local service. Aborting operation.")
            complete(.error(.realmError(realmError)))
            return
        }

        // Check if threadSafeServiceRepresentables contain the service.
        let serviceIndex = threadSafeServiceRepresentables?.firstIndex(where: {
            switch $0 {
            case .service(let id):
                return id == service.id
            case .snippet(let snippet):
                return snippet.id == service.id
            }
        })
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
