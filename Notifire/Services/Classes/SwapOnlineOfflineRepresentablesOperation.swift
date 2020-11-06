//
//  SwapOnlineOfflineRepresentablesOperation.swift
//  Notifire
//
//  Created by David Bielik on 30/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Operation that handles the case when a user goes to 'Offline mode' (e.g. loses websocket connection, airplane mode, etc.)
class SwapOnlineOfflineRepresentablesOperation: Operation, ThreadSafeServiceRepresentableOperation {

    /// The direction of this operation
    enum Mode {
        /// Currently loaded `[ServiceRepresentable]` is merged with the rest of user's local services
        case toOffline
        /// Previously loaded `[ServiceRepresentable]` is restored.
        case toOnline
    }

    // MARK: - Properties
    let mode: Mode

    // MARK: ThreadSafeServiceRepresentableOperation
    var threadSafeServiceRepresentables: ThreadSafeServiceRepresentables?
    let synchronizationManager: ServicesSynchronizationManager

    // MARK: Completion
    var completionHandler: (([ServiceRepresentable]) -> Void)?

    // MARK: - Initialization
    init(synchronizationManager: ServicesSynchronizationManager, mode: Mode, representables: [ServiceRepresentable]) {
        self.synchronizationManager = synchronizationManager
        self.mode = mode
        super.init()
        setThreadSafe(serviceRepresentables: representables)
    }

    // MARK: - Inherited
    override func main() {
        guard let serviceRepresentables = serviceRepresentables else {
            Logger.log(.default, "\(self) serviceRepresentables is nil")
            return
        }

        Logger.log(.debug, "\(self) handling swap \(mode)")

        let resultRepresentables: [ServiceRepresentable]
        switch mode {
        case .toOnline:
            guard
                let threadSafeServicesBeforeOfflineMode = synchronizationManager.lastThreadSafeServiceRepresentables,
                let servicesBeforeOfflineMode = synchronizationManager.resolve(threadSafeRepresentables: threadSafeServicesBeforeOfflineMode)
            else {
                Logger.log(.fault, "\(self) SynchronizationManager.serviceRepresentablesBeforeOfflineMode=nil")
                return
            }
            synchronizationManager.lastThreadSafeServiceRepresentables = nil
            resultRepresentables = servicesBeforeOfflineMode
        case .toOffline:
            synchronizationManager.lastThreadSafeServiceRepresentables = synchronizationManager.threadSafeRepresentables(from: serviceRepresentables)
            resultRepresentables = synchronizationManager.mergeRepresentablesAndLocal(representables: serviceRepresentables)
        }

        // Complete if needed
        guard let completion = completionHandler else {
            Logger.log(.info, "\(self) completionHandler=nil")
            return
        }

        Logger.log(.debug, "\(self) finished swap \(mode)")

        finishOperation(representables: resultRepresentables) { resolvedRepresentables in
            completion(resolvedRepresentables)
        }
    }
}
