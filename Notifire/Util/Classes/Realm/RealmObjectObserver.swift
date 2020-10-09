//
//  RealmObjectObserver.swift
//  Notifire
//
//  Created by David Bielik on 09/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class RealmObjectObserver<RealmObject: RealmSwift.Object> {

    // MARK: - Properties
    let realmProvider: RealmProviding
    private let underlyingObject: RealmObject

    /// The notification token associated with the observing RealmObject
    private var objectNotificationToken: RealmSwift.NotificationToken?

    private var objectRef: ThreadSafeReference<RealmObject> {
        return ThreadSafeReference(to: underlyingObject)
    }

    var object: RealmObject {
        return realmProvider.realm.resolve(objectRef)!
    }

    // MARK: Callback
    /// Invoked when a notification is received on `objectNotificationToken`
    var onObjectChange: ((RealmSwift.ObjectChange<RealmObject>) -> Void)?

    // MARK: - Initialization
    init(realmProvider: RealmProviding, object: RealmObject) {
        self.realmProvider = realmProvider
        self.underlyingObject = object
    }

    deinit {
        objectNotificationToken?.invalidate()
    }

    // MARK: - Methods
    func setupNotificationTokenIfNeeded() {
        // Only setup if needed
        guard objectNotificationToken == nil else { return }

        objectNotificationToken = object.observe({ [weak self] change in
            self?.onResults(change: change)
        })
    }

    open func onResults(change: RealmSwift.ObjectChange<RealmObject>) {
        // invoke the callback if needed
        onObjectChange?(change)
    }
}
