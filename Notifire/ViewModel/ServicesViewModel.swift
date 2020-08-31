//
//  ServicesViewModel.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import RealmSwift

class ServicesViewModel: RealmCollectionViewModel<LocalService>, APIFailable {
    
    enum ViewState: Equatable {
        case fetching(afterInitial: Bool)
        case displayingServices
        case emptyState
        case initial
    }
    
    // MARK: - Properties
    let userSessionHandler: NotifireUserSessionHandler
    
    var protectedApiManager: NotifireProtectedAPIManager {
        return userSessionHandler.notifireProtectedApiManager
    }
    
    var onError: ((NotifireAPIManagerBase.ManagerResultError) -> Void)?
    
    // MARK: Model
    var viewState: ViewState = .initial {
        didSet {
            onViewStateChange?(viewState, oldValue)
        }
    }
    var isFirstFetch = true
    
    // MARK: Callback
    typealias OldViewState = ViewState
    var onViewStateChange: ((ViewState, OldViewState) -> Void)?
    
    // MARK: - Initialization
    init(sessionHandler: NotifireUserSessionHandler) {
        self.userSessionHandler = sessionHandler
        super.init(realmProvider: sessionHandler)
    }
    
    // MARK: - Inherited
    override func resultsSortOptions() -> RealmCollectionViewModel<LocalService>.SortOptions? {
        return SortOptions(keyPath: LocalService.sortKeyPath, ascending: true)
    }
    
    // MARK: - Private
    override func onResults(change: RealmCollectionChange<Results<LocalService>>) {
        switch change {
        case .initial(let collection), .update(let collection, _, _, _):
            if collection.isEmpty {
                self.viewState = .emptyState
            } else {
                self.viewState = .displayingServices
            }
        case .error:
            break
        }
        super.onResults(change: change)
    }
    
    // MARK: - Methods
    func firstServicesFetch() {
        guard isFirstFetch else { return }
        isFirstFetch = false
        fetchUserServices()
    }
    
    func fetchUserServices() {
        if case .fetching = viewState { return }
        let isInitialFetch = viewState == .initial
        viewState = .fetching(afterInitial: isInitialFetch)
        protectedApiManager.services(completion: { [weak self] responseContext in
            switch responseContext {
            case .error(let error):
                self?.viewState = .displayingServices
                self?.onError?(error)
            case .success(let services):
                var localServicesToUpdate: [(LocalService, Service?)] = []
                for service in services {
                    let maybeLocalService = self?.collection.first { $0.uuid == service.uuid }
                    if let localService = maybeLocalService {
                        // service exists in the Realm and the remote DB
                        guard let localUpdatedAt = localService.updatedAt, let remoteUpdatedAt = service.updatedAt, localUpdatedAt < remoteUpdatedAt else { continue }
                        // service was updated outside of the application, update it locally
                        localServicesToUpdate.append((localService, service))
                    } else {
                        // service was created outside of the application, create a new local one
                        let newLocalService = LocalService()
                        newLocalService.updateData(from: service)
                        localServicesToUpdate.append((newLocalService, nil))
                    }
                }
                if localServicesToUpdate.isEmpty {
                    self?.viewState = .displayingServices
                } else {
                    try? self?.realmProvider.realm.write {
                        for (outdatedLocalService, maybeService) in localServicesToUpdate {
                            if let service = maybeService {
                                outdatedLocalService.updateDataExceptUUID(from: service)
                            } else {
                                self?.realmProvider.realm.add(outdatedLocalService, update: .all)
                            }
                        }
                    }
                }
            }
            self?.setupResultsTokenIfNeeded()
        })
    }
    
    func createLocalService(from service: Service) {
        let realm = realmProvider.realm
        try? realm.write {
            let existingObject = realm.object(ofType: LocalService.self, forPrimaryKey: service.uuid)
            guard existingObject == nil else { return }
            let localService = LocalService()
            localService.updateData(from: service)
            realm.add(localService)
        }
    }
}
