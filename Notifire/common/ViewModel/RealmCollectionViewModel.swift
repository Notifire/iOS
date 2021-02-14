//
//  RealmCollectionViewModel.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCollectionViewModel<RealmObject: Object>: ViewModelRepresenting {
    struct SortOptions {
        let keyPath: String
        let ascending: Bool
    }

    // MARK: - Properties
    let realmProvider: RealmProviding

    lazy var collection: Results<RealmObject> = realmProvider.realm.objects(RealmObject.self).filter(NSPredicate(value: false))
    var resultsToken: NotificationToken?

    // MARK: - Setup
    func getCollection() -> Results<RealmObject> {
        var results = realmProvider.realm.objects(RealmObject.self)
        if let predicate = resultsFilterPredicate() {
            results = results.filter(predicate)
        }
        if let sortOptions = resultsSortOptions() {
            results = results.sorted(byKeyPath: sortOptions.keyPath, ascending: sortOptions.ascending)
        }
        return results
    }

    func resultsSortOptions() -> SortOptions? {
        return nil
    }

    func resultsFilterPredicate() -> NSPredicate? {
        return nil
    }

    // MARK: Callback
    var onCollectionUpdate: ((RealmCollectionChange<Results<RealmObject>>) -> Void)?

    init(realmProvider: RealmProviding) {
        self.realmProvider = realmProvider
        collection = getCollection()
    }

    deinit {
        resultsToken?.invalidate()
    }

    func setupResultsTokenIfNeeded() {
        guard resultsToken == nil else { return }
        resultsToken = collection.observe({ [weak self] change in
            self?.onResults(change: change)
        })
    }

    /// Remove the current results token and set a new one from the current collection.
    func refreshResultsToken() {
        resultsToken?.invalidate()
        resultsToken = nil
        setupResultsTokenIfNeeded()
    }

    func reloadCollection() {
        collection = getCollection()
        refreshResultsToken()
    }

    open func onResults(change: RealmCollectionChange<Results<RealmObject>>) {
        // invoke the callback if needed
        onCollectionUpdate?(change)
    }
}
