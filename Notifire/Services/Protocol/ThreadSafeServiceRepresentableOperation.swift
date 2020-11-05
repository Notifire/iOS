//
//  ThreadSafeServiceRepresentableOperation.swift
//  Notifire
//
//  Created by David Bielik on 05/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

// MARK: - ThreadSafeServiceRepresentables
/// Array contains `ServiceSnippet` and `ThreadSafeReference<LocalService`
 typealias ThreadSafeServiceRepresentables = [Any]

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
        // resolved on current DispatchQueue
        return synchronizationManager.resolve(threadSafeRepresentables: threadSafeServiceRepresentables)
    }

    /// Sets the `threadSafeServiceRepresentables` from the main `DispatchQueue`.
    /// - Important: Calling this from the main `DispatchQueue` will result in a deadlock.
    func setThreadSafe(serviceRepresentables: [ServiceRepresentable], fromMainQueue: Bool = true) {
        let setterClosure = { [unowned self] in
            self.threadSafeServiceRepresentables = self.synchronizationManager.threadSafeRepresentables(from: serviceRepresentables)
        }

        if fromMainQueue {
            // Make sure that we create the threadSafeReferences from the Main Queue
            // The call has to be sync because the operation might start sooner than an otherwise async call would
            // Thus wait for the main queue to finish the block before proceeding.
            DispatchQueue.main.sync {
                setterClosure()
            }
        } else {
            setterClosure()
        }
    }

    func finishOperation(representables resultRepresentables: [ServiceRepresentable], resolvedHandler: @escaping (([ServiceRepresentable]) -> Void)) {
        // Ensure we're returning ThreadSafeReferences for every LocalService by using synchronizationManager threadSafe methods
        // because the local services will be handled on the main queue
        let threadSafeRepresentables = synchronizationManager.threadSafeRepresentables(from: resultRepresentables)

        // Resolve the threadSafeRepresentables on Main
        // Note:    Can't use async here as it would cause `self` to be nil (reference to synchronizationManager would be lost)
        //          This happens because the operation changes the state to finished and is deallocated before the main.async call would happen.
        DispatchQueue.main.sync { [unowned self] in
            guard let resolvedRepresentables = self.synchronizationManager.resolve(threadSafeRepresentables: threadSafeRepresentables) else { return }

            // Call the resolvedHandler asynchronously as the reference to resolvedRepresentables is not reliant on `self`
            // thus it will get always called.
            DispatchQueue.main.async {
                // Resolved representables completion handler
                resolvedHandler(resolvedRepresentables)
            }
        }
    }
}
