//
//  SyncAllServicesOperation.swift
//  Notifire
//
//  Created by David Bielik on 06/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Responsible for retrieving sync responses for each batch of localServices.
class SyncAllServicesOperation: ProtectedNetworkOperation<SyncServicesResponse> {

    // MARK: - Properties
    let synchronizationManager: ServicesSynchronizationManager

    // MARK: - Main
    init(synchronizationManager: ServicesSynchronizationManager, apiManager: NotifireProtectedAPIManager) {
        self.synchronizationManager = synchronizationManager
        super.init(apiManager: apiManager)
    }

    // MARK: - Main
    override func main() {
        super.main()

        // Grab all LocalService objects and chunk them into [Service] chunks
        let localServices = synchronizationManager.servicesHandler.collection
        let services = Array(localServices).map({ $0.asServiceSyncData })
        let servicesChunked = Array(services).chunked(by: PaginationHandler.servicesPaginationLimit)

        guard let currentQueue = OperationQueue.current?.underlyingQueue else {
            complete(result: .error(.unknown))
            return
        }

        // Create a semaphore
        let syncServicesGroup = DispatchGroup()

        // Result
        var serviceChangeEvents = [Int: [ServiceChangeEvent]]()
        var maybeErrors: [NotifireAPIError]?

        for (i, chunk) in servicesChunked.enumerated() {
            syncServicesGroup.enter()

            apiManager.sync(services: chunk) { result in
                // make sure to leave the group
                defer { syncServicesGroup.leave() }
                switch result {
                case .error(let error):
                    // Add error to the array of errors
                    currentQueue.async {
                        if maybeErrors == nil {
                            maybeErrors = [error]
                        } else {
                            maybeErrors?.append(error)
                        }
                    }
                case .success(let response):
                    // Use async here to make sure the dict is not accessed by multiple requests at the same time
                    currentQueue.async {
                        serviceChangeEvents[i] = response
                    }
                }
            }
        }

        syncServicesGroup.notify(queue: currentQueue) {
            if let error = maybeErrors?.last {
                self.complete(result: .error(error))
            } else {
                self.complete(result: .success(Array(serviceChangeEvents.values.joined())))
            }
        }
    }
}
