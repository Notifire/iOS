//
//  RealmCollectionObserver.swift
//  Notifire
//
//  Created by David Bielik on 25/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

/// Handles the querying, filtering, sorting and update notifications for a realm collection.
class RealmCollectionObserver<RealmObject: RealmSwift.Object> {

    // MARK: - Properties
    let realmProvider: RealmProviding

    // MARK: Collection
    private var underlyingCollection: Results<RealmObject> {
        var results = realmProvider.realm.objects(RealmObject.self)
        if let predicate = filterPredicate {
            results = results.filter(predicate)
        }
        if let sortOptions = sortOptions {
            results = results.sorted(byKeyPath: sortOptions.keyPath, ascending: sortOptions.ascending)
        }
        return results
    }

    var collectionRef: ThreadSafeReference<Results<RealmObject>> {
        return ThreadSafeReference(to: underlyingCollection)
    }

    var collection: Results<RealmObject> {
        return realmProvider.realm.resolve(collectionRef)!
        //guard let collection = realmProvider.realm.resolve(collectionRef) else { return nil }
        //return collection
    }

    var sortOptions: RealmSortingOptions?
    var filterPredicate: NSPredicate?

    /// The token responsible for observing collection changes.
    var collectionNotificationToken: NotificationToken?

    // MARK: Callback
    /// Invoked when a notification is received on the `collectionNotificationToken`
    var onCollectionChange: ((RealmCollectionChange<Results<RealmObject>>) -> Void)?

    // MARK: - Initialization
    init(realmProvider: RealmProviding, sortOptions: RealmSortingOptions? = nil, filterPredicate: NSPredicate? = nil) {
        self.realmProvider = realmProvider
        self.sortOptions = sortOptions
        self.filterPredicate = filterPredicate
    }

    deinit {
        collectionNotificationToken?.invalidate()
    }

    // MARK: - Methods
    func setupNotificationTokenIfNeeded() {
        // Only setup if needed
        guard collectionNotificationToken == nil else { return }

        collectionNotificationToken = collection.observe({ [weak self] change in
            self?.onResults(change: change)
        })
    }

    open func onResults(change: RealmCollectionChange<Results<RealmObject>>) {
        // invoke the callback if needed
        onCollectionChange?(change)
    }
}
