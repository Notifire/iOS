//
//  RealmCollectionViewModel.swift
//  Notifire
//
//  Created by David Bielik on 16/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class RealmCollectionViewModel<RealmObject: Object> {
    struct SortOptions {
        let keyPath: String
        let ascending: Bool
    }
    
    // MARK: - Properties
    let realmProvider: RealmProviding
    
    var realmObjects: Results<RealmObject>!
    
    lazy var collection: Results<RealmObject> = {
        var results = realmObjects!
        if let predicate = resultsFilterPredicate() {
            results = results.filter(predicate)
        }
        if let sortOptions = resultsSortOptions() {
            results = results.sorted(byKeyPath: sortOptions.keyPath, ascending: sortOptions.ascending)
        }
        return results
    }()
    var resultsToken: NotificationToken?
    
    // MARK: - Setup
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
        realmObjects = realmProvider.realm.objects(RealmObject.self)
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
    
    open func onResults(change: RealmCollectionChange<Results<RealmObject>>) {
        // invoke the callback if needed
        onCollectionUpdate?(change)
    }
}
