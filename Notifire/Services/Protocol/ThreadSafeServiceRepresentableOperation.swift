//
//  ThreadSafeServiceRepresentableOperation.swift
//  Notifire
//
//  Created by David Bielik on 05/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

enum ThreadSafeServiceRepresentable {
    case snippet(ServiceSnippet)
    case service(id: Int)
}

// MARK: - ThreadSafeServiceRepresentables
typealias ThreadSafeServiceRepresentables = [ThreadSafeServiceRepresentable]

// MARK: - ThreadSafeServiceRepresentableOperation
/// Describes `Operation`s that work (on a background queue) with array of `ServiceRepresentable`
/// Ensures that every operation on Realm objects is done in a thread safe manner.
protocol ThreadSafeServiceRepresentableOperation: class {

    var synchronizationManager: ServicesSynchronizationManager { get }

    /// An array of `ServiceSnippet` and `ThreadSafeReference<LocalService>` (referenced from another thread)
    /// - Important: Always set this value by calling `setThreadSafeServiceRepresentables(from:)` which ensures thread safety
    var threadSafeServiceRepresentables: ThreadSafeServiceRepresentables? { get set }

    /// Resolved `threadSafeServiceRepresentables` on the current thread.
    var serviceRepresentables: [ServiceRepresentable]? { get }
}

extension ThreadSafeServiceRepresentableOperation {
    var serviceRepresentables: [ServiceRepresentable]? {
        guard let threadSafeServiceRepresentables = self.threadSafeServiceRepresentables else { return nil }
        return synchronizationManager.createServiceRepresentables(from: threadSafeServiceRepresentables)
    }

    /// Sets the `threadSafeServiceRepresentables` from the main `DispatchQueue`.
    func setThreadSafe(serviceRepresentables: [ServiceRepresentable]) {
        self.threadSafeServiceRepresentables = synchronizationManager.createThreadSafeRepresentables(from: serviceRepresentables)
    }

    func finishOperation(representables resultRepresentables: [ServiceRepresentable], resolvedHandler: @escaping ((ThreadSafeServiceRepresentables) -> Void)) {
        let threadSafeRepresentables = synchronizationManager.createThreadSafeRepresentables(from: resultRepresentables)
        DispatchQueue.main.async {
            resolvedHandler(threadSafeRepresentables)
        }
    }
}
