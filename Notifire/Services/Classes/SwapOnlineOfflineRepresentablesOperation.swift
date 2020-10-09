//
//  SwapOnlineOfflineRepresentablesOperation.swift
//  Notifire
//
//  Created by David Bielik on 30/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class SwapOnlineOfflineRepresentablesOperation: Operation {

    enum Mode {
        case toOffline
        case toOnline
    }

    // MARK: - Properties
    let mode: Mode
    let synchronizationManager: ServicesSynchronizationManager
    let serviceRepresentables: [ServiceRepresentable]

    // MARK: Completion
    var completionHandler: (([ServiceRepresentable]) -> Void)?

    // MARK: - Initialization
    init(synchronizationManager: ServicesSynchronizationManager, mode: Mode, representables: [ServiceRepresentable]) {
        self.synchronizationManager = synchronizationManager
        self.mode = mode
        self.serviceRepresentables = representables
    }

    // MARK: - Inherited
    override func main() {
        let resultRepresentables: [ServiceRepresentable]
        switch mode {
        case .toOnline:
            guard let servicesBeforeOfflineMode = synchronizationManager.serviceRepresentablesBeforeOfflineMode else {
                Logger.log(.fault, "\(self) SynchronizationManager.serviceRepresentablesBeforeOfflineMode=nil")
                return
            }
            synchronizationManager.serviceRepresentablesBeforeOfflineMode = nil
            resultRepresentables = servicesBeforeOfflineMode
        case .toOffline:
            synchronizationManager.serviceRepresentablesBeforeOfflineMode = serviceRepresentables
            resultRepresentables = synchronizationManager.mergeRepresentablesAndLocal(representables: serviceRepresentables)
        }

        // Complete
        guard let completion = completionHandler else {
            Logger.log(.debug, "\(self) completionHandler=nil")
            return
        }

        DispatchQueue.main.async {
            completion(resultRepresentables)
        }
    }
}
