//
//  ServicesViewModel.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import RealmSwift
import Starscream

/// The services view ViewModel
class ServicesViewModel: ViewModelRepresenting, APIErrorProducing {

    /// Enumeration representing the (table) view state of the View
    enum ViewState: Equatable {
        case skeleton
        case displayingServices
        case emptyState
    }

    /// Enumeration representing the connection status to the websocket
    enum WebSocketConnectionViewState: Equatable {
        case offline
        case connecting
        case connected
    }

    // MARK: - Properties
    let userSessionHandler: UserSessionHandler
    private let websocketManager: ServiceWebSocketManager
    let synchronizationManager: ServicesSynchronizationManager

    /// queue for CRUD on LocalService + GET /services
    lazy var synchronizedDispatchQueue = DispatchQueue(label: "\(Config.bundleID).ServicesViewModel.synchronizedQueue")

    lazy var synchronizedQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = synchronizedDispatchQueue
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    var protectedApiManager: NotifireProtectedAPIManager {
        return userSessionHandler.notifireProtectedApiManager
    }

    /// `true` if the viewmodel is currently attempting a GET /services request. `false` otherwise.
    var isFetching: Bool = false {
        didSet {
            onIsFetchingChange?(isFetching)
        }
    }

    /// `true` if the first pagination hasn't been completed yet
    var isInitialPageFetch: Bool {
        return synchronizationManager.paginationHandler.noPagesFetched
    }

    /// `true` if the websocket is connecting for the first time
    var isFirstAttemptToConnect: Bool = true

    // MARK: APIErrorProducing
    var onError: ((NotifireAPIError) -> Void)?

    // MARK: Model
    var viewState: ViewState = .skeleton {
        didSet {
            onViewStateChange?(viewState, oldValue)
        }
    }

    var connectionViewState: WebSocketConnectionViewState? = nil {
        didSet {
            guard
                !isFirstAttemptToConnect,    // don't show connection state on first connect
                let newState = connectionViewState,
                oldValue != newState
            else { return }
            onConnectionViewStateChange?(newState)
        }
    }

    var services: [ServiceRepresentable] = [] {
        willSet {
            //
            // Refresh the Realm on this thread before setting a new value for services.
            // This ensures that we get all objects created from another thread on time
            // in this thread.
            synchronizationManager.realmProvider.realm.refresh()
        }
        didSet {
            // Set thread safe services
            self.threadSafeServices = synchronizationManager.createThreadSafeRepresentables(from: services)
            // Set service observers
            var newObservers = [Int: ServiceNotificationsObserver]()
            for service in services {
                let serviceID = (service as? LocalService)?.safeHandle?.id ?? service.id
                if let currentObserver = serviceNotificationsObservers[serviceID] {
                    // Reuse the old one -- service wasn't changed
                    newObservers[serviceID] = currentObserver
                } else {
                    // Create a new observer for this new service
                    let newObserver = ServiceNotificationsObserver(realmProvider: userSessionHandler, serviceID: serviceID)
                    newObserver.onNumberNotificationsChange = { [weak self] serviceID in
                        guard let serviceIndex = self?.services.firstIndex(where: { $0.id == serviceID }) else { return }
                        self?.onServicesChange?(.partial(changesData: ServiceRepresentableChangesData(deletions: [], insertions: [], modifications: [IndexPath(row: serviceIndex, section: 0)], moves: [])))
                    }
                    newObservers[serviceID] = newObserver
                }
            }
            serviceNotificationsObservers = newObservers
        }
    }
    var threadSafeServices = ThreadSafeServiceRepresentables()
    var serviceNotificationsObservers = [Int: ServiceNotificationsObserver]()

    // `true` after the SyncAllServicesOperation finished
    var areLocalServicesSynchronized: Bool = false

    // MARK: Callback
    typealias OldViewState = ViewState

    /// Called when `viewState` changes
    var onViewStateChange: ((ViewState, OldViewState) -> Void)?
    /// Called  when `connectionViewState` changes
    var onConnectionViewStateChange: ((WebSocketConnectionViewState) -> Void)?
    /// Called on `services` change
    var onServicesChange: ((ServiceRepresentableChanges) -> Void)?
    /// Called when `isFetching` changes
    var onIsFetchingChange: ((Bool) -> Void)?
    /// Called when a service is deleted
    var onServiceDeletion: ((Int) -> Void)?

    // MARK: - Initialization
    init(sessionHandler: UserSessionHandler) {
        self.userSessionHandler = sessionHandler
        let localServicesHandler = RealmCollectionObserver<LocalService>(
            realmProvider: userSessionHandler,
            sortOptions: RealmSortingOptions(keyPath: LocalService.sortKeyPath, order: .ascending)
        )
        self.websocketManager = ServiceWebSocketManager(apiManager: sessionHandler.notifireProtectedApiManager)
        self.synchronizationManager = ServicesSynchronizationManager(realmProvider: sessionHandler, servicesCollectionHandler: localServicesHandler)
    }

    // MARK: - Methods
    /// Starts the viewModel
    /// - Note:
    ///     - Connects to the websocket
    ///     - Fetches first page of services
    ///     - Attempts to /sync local services
    func start() {
        // WebSocket
        // Connection status
        websocketManager.onWebSocketConnectionStatusChange = { [weak self] old, new in
            self?.handleWebSocketConnectionStatusChange(old, new)
        }

        // Service Event handling
        websocketManager.onServiceEvent = { [weak self] eventData in
            self?.handleServiceEvent(data: eventData)
        }

        // Replay event handling
        websocketManager.onReplayEvent = { [weak self] events in
            self?.handleReplayEvent(eventsData: events)
        }

        // Connect to the socket
        websocketManager.connect()
    }

    /// Fetches the first or next page of user's services depending on the `synchronizationManager.paginationHandler` state.
    /// - Note: This function adds three operations into the `synchronizedQueue`.
    ///     1. GET /services operation
    ///     2. adapter operation to get the result of 1. and plug it into 3.
    ///     3. CRUD operation for new batch of services from 1.
    func fetchNextPageOfUserServices() {
        guard
            synchronizationManager.allowsPagination,    // Fetch only if we aren't at the end of paginating
            !isFetching,
            areLocalServicesSynchronized                // We can paginate only if the services have been synchronized
        else { return }

        isFetching = true

        // Optional Pagination
        let paginationData = synchronizationManager.paginationHandler.createPaginationData()

        // Operations
        let getServicesOperation = GetServicesBatchOperation(
            servicesLimit: PaginationHandler.servicesPaginationLimit,
            paginationData: paginationData,
            apiManager: protectedApiManager
        )
        let updateServicesOperation = UpdateServiceRepresentablesOperation(synchronizationManager: synchronizationManager)
        let serviceDataAdapterOperation = BlockOperation()

        // Get -> Adapter -> Update
        serviceDataAdapterOperation.addDependency(getServicesOperation)
        updateServicesOperation.addDependency(serviceDataAdapterOperation)

        //
        // Get services operation
        getServicesOperation.completionHandler = { [unowned serviceDataAdapterOperation, unowned updateServicesOperation, weak self] result in
            switch result {
            case .error(let error):
                // Cancel the other operations if this one fails
                serviceDataAdapterOperation.cancel()
                updateServicesOperation.cancel()
                self?.isFetching = false
                self?.onError?(error)
            case .success(let snippets):
                self?.synchronizationManager.paginationHandler.updatePaginationState(snippets)
            }
        }

        //
        // Update services operation
        updateServicesOperation.completionHandler = { [weak self] threadSafeRepresentables, maybeChanges in
            guard let `self` = self else { return }
            let newServiceRepresentables = self.synchronizationManager.createServiceRepresentables(from: threadSafeRepresentables)
            self.updateViewStateAndServiceRepresentableChanges(representables: newServiceRepresentables, changes: maybeChanges)

            DispatchQueue.main.async { [weak self] in
                self?.isFetching = false
            }
        }

        //
        // Adapter operation
        serviceDataAdapterOperation.addExecutionBlock { [unowned getServicesOperation, unowned updateServicesOperation, weak self] in
            guard let `self` = self, let result = getServicesOperation.result else { return }
            switch result {
            case .error(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.onError?(error)
                }
            case .success(let services):
                updateServicesOperation.action = .add(batch: services)
            }

            updateServicesOperation.threadSafeServiceRepresentables = self.threadSafeServices
        }

        // Enqueue
        synchronizedQueue.addOperations([getServicesOperation, serviceDataAdapterOperation, updateServicesOperation], waitUntilFinished: false)
    }

    func synchronizeLocalServicesWithRemote() {
        // Make sure that the services haven't been synchronized yet, we don't need to do it twice in one session.
        guard !areLocalServicesSynchronized else { return }

        // Operations
        let syncAllServicesOperation = SyncAllServicesOperation(
            synchronizationManager: synchronizationManager,
            apiManager: protectedApiManager
        )
        let updateServicesOperation = UpdateServiceRepresentablesOperation(synchronizationManager: synchronizationManager)
        let serviceDataAdapterOperation = BlockOperation()

        // Get -> Adapter -> Update
        serviceDataAdapterOperation.addDependency(syncAllServicesOperation)
        updateServicesOperation.addDependency(serviceDataAdapterOperation)

        //
        // Sync all services operation
        syncAllServicesOperation.completionHandler = { [unowned serviceDataAdapterOperation, unowned updateServicesOperation, weak self] response in
            guard case .success = response else {
                // Cancel the other operations if this one fails
                serviceDataAdapterOperation.cancel()
                updateServicesOperation.cancel()
                // Try again
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                    self?.synchronizeLocalServicesWithRemote()
                }
                return
            }
        }

        //
        // Update services operation
        updateServicesOperation.completionHandler = { [weak self] _, _ in
            self?.areLocalServicesSynchronized = true

            // Need to call `fetchNextPageOfUserServices` because of threadsafe reference from main thread
            DispatchQueue.main.async {
                // Fetch first page after the update operation is completed
                self?.fetchNextPageOfUserServices()
            }
        }

        //
        // Adapter operation
        serviceDataAdapterOperation.addExecutionBlock { [unowned syncAllServicesOperation, unowned updateServicesOperation] in
            if case .success(let serviceChangeEvents) = syncAllServicesOperation.result {
                let action: LocalRemoteServicesAction = .changeMultipleServices(serviceChangeEvents)
                updateServicesOperation.action = action
            }

            updateServicesOperation.setThreadSafe(serviceRepresentables: [])
        }

        // Enqueue
        synchronizedQueue.addOperations([syncAllServicesOperation, serviceDataAdapterOperation, updateServicesOperation], waitUntilFinished: false)
    }

    /// Swaps the service representables to another mode.
    /// - Note: This function adds one operation into the `synchronizedQueue`.
    ///     1. SwapOnlineOfflineRepresentablesOperation
    func swapOnlineOfflineMode(to newMode: SwapOnlineOfflineRepresentablesOperation.Mode, completionBlock: (() -> Void)? = nil) {
        let swapToOnlineOperation = SwapOnlineOfflineRepresentablesOperation(
            synchronizationManager: synchronizationManager,
            mode: newMode
        )
        swapToOnlineOperation.threadSafeServiceRepresentables = threadSafeServices
        swapToOnlineOperation.completionHandler = { [weak self] threadSafeRepresentables in
            guard let `self` = self else { return }
            let newServiceRepresentables = self.synchronizationManager.createServiceRepresentables(from: threadSafeRepresentables)
            self.updateViewStateAndServiceRepresentableChanges(representables: newServiceRepresentables, changes: .full)
        }
        swapToOnlineOperation.completionBlock = completionBlock
        synchronizedQueue.addOperation(swapToOnlineOperation)
    }

    /// This function fetches a single Service resource by a given ServiceSnippet. It also creates a LocalService for this fetched Service and updates the threadSafeRepresentables array with the new LocalService.
    func fetchService(snippet: ServiceSnippet, completion: ((LocalService?, (NotifireAPIError?, CreateLocalServiceOperation.Error?)?) -> Void)?) {
        // Operations
        let getServiceOperation = GetServiceOperation(serviceSnippet: snippet, apiManager: protectedApiManager)
        let createServiceOperation = CreateLocalServiceOperation(synchronizationManager: synchronizationManager)
        let serviceDataAdapterOperation = BlockOperation()

        // Get -> Adapter -> Update
        serviceDataAdapterOperation.addDependency(getServiceOperation)
        createServiceOperation.addDependency(serviceDataAdapterOperation)

        //
        // Get service operation
        getServiceOperation.completionHandler = { [unowned serviceDataAdapterOperation, unowned createServiceOperation] result in
            guard case .error(let error) = result else { return }
            serviceDataAdapterOperation.cancel()
            createServiceOperation.cancel()
            completion?(nil, (error, nil))
        }

        //
        // Create service operation
        createServiceOperation.completionHandler = { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .created(let localServiceID, let index):
                guard let localService = RealmManager.getLocalService(id: localServiceID, realm: self.synchronizationManager.realmProvider.realm) else {
                    completion?(nil, (nil, .localServiceObjectNotFound))
                    return
                }
                // Add localService to serviceRepresentables
                self.services[index] = localService
                // Callback
                completion?(localService, nil)
            case .error(let error):
                completion?(nil, (nil, error))
            }
        }

        //
        // Adapter operation
        serviceDataAdapterOperation.addExecutionBlock { [unowned getServiceOperation, unowned createServiceOperation, weak self] in
            guard let `self` = self else { return }
            if case .success(let getResponse) = getServiceOperation.result {
                guard let service = getResponse.service else {
                    completion?(nil, (nil, .serviceDeletedBeforeOperationStarted))
                    return
                }
                createServiceOperation.service = service
            }

            createServiceOperation.threadSafeServiceRepresentables = self.threadSafeServices
        }

        // Enqueue
        synchronizedQueue.addOperations([getServiceOperation, serviceDataAdapterOperation, createServiceOperation], waitUntilFinished: false)
    }

    // MARK: - Private
    private func updateConnectionViewState(_ status: WebSocketConnectionStatus) {
        let newViewState: WebSocketConnectionViewState
        switch (connectionViewState, status) {
        case (nil, .connecting), (.connecting, .connecting), (_, .connected), (_, .disconnected(context: .disconnect(_, code: .expiredSessionID))), (_, .disconnected(context: .disconnect(_, code: .invalidAccessToken))):
            newViewState = .connecting
        case (_, .disconnected), (_, .connecting): newViewState = .offline
        case (_, .authorized): newViewState = .connected
        }
        DispatchQueue.main.async { [weak self] in
            self?.connectionViewState = newViewState
        }
    }

    private func updateViewState(to new: ViewState) {
        DispatchQueue.main.async { [weak self] in
            self?.viewState = new
        }
    }

    // MARK: EventHandlers
    private func handleWebSocketConnectionStatusChange(_ old: WebSocketConnectionStatus, _ new: WebSocketConnectionStatus) {
        switch (old, new) {
        case (_, .authorized):
            // Swap to online mode if needed
            if synchronizationManager.isOfflineModeActive {
                swapOnlineOfflineMode(to: .toOnline) { [weak self] in
                    DispatchQueue.main.async {
                        guard self?.isInitialPageFetch ?? false else { return }
                        self?.synchronizeLocalServicesWithRemote()
                    }
                }
            } else if isInitialPageFetch {
                // POST /services/sync after connecting to the socket
                synchronizeLocalServicesWithRemote()
            }
        case (_, .disconnected):
            if isFirstAttemptToConnect { isFirstAttemptToConnect = false }
            // Swap to offline mode if needed
            if !synchronizationManager.isOfflineModeActive {
                swapOnlineOfflineMode(to: .toOffline)
            }

        default:
            break
        }
        updateConnectionViewState(new)
    }

    /// Handles `viewState` changes and updates `services`
    private func updateViewStateAndServiceRepresentableChanges(representables newRepresentables: [ServiceRepresentable], changes: ServiceRepresentableChanges?) {
        switch viewState {
        case .skeleton:
            if newRepresentables.isEmpty {
                // If the new representables are empty, change the state to empty
                updateViewState(to: .emptyState)
            } else {
                // Display new services
                updateServiceRepresentables(with: newRepresentables)
                updateViewState(to: .displayingServices)
            }
        case .emptyState:
            if !newRepresentables.isEmpty {
                // Display new services
                updateServiceRepresentables(with: newRepresentables)
                updateViewState(to: .displayingServices)
            }
        case .displayingServices:
            if let changes = changes {
                if isInitialPageFetch {
                    // We were currently .displayingServices, but if the page fetch is still initial, display skeleton
                    // happens if the user starts the app into offline mode (first fetch / websocket connect wasn't possible)
                    updateServiceRepresentables(with: newRepresentables)
                    updateViewState(to: .skeleton)
                } else {
                    // Display new services and propagate tableview updates
                    updateServiceRepresentables(with: newRepresentables, changes: changes)
                    if newRepresentables.isEmpty {
                        updateViewState(to: .emptyState)
                    }
                }
            }
        }
    }

    private func updateServiceRepresentables(with representables: [ServiceRepresentable], changes: ServiceRepresentableChanges = .full) {
        // update services
        services = representables

        // notify listener
        onServicesChange?(changes)
    }

    private func handleServiceEvent(data: NotifireWebSocketServiceEventData) {
        let updateServicesOperation = UpdateServiceRepresentablesOperation(synchronizationManager: synchronizationManager)
        updateServicesOperation.action = .changeSingleService(data)
        updateServicesOperation.threadSafeServiceRepresentables = threadSafeServices
        updateServicesOperation.completionHandler = { [weak self] threadSafeRepresentables, maybeChanges in
            guard let `self` = self else { return }
            let newServiceRepresentables = self.synchronizationManager.createServiceRepresentables(from: threadSafeRepresentables)
            self.updateViewStateAndServiceRepresentableChanges(representables: newServiceRepresentables, changes: maybeChanges)

            // Notify that we have deleted a service
            if case .delete(let id) = data.serviceChangeData {
                DispatchQueue.main.async { [weak self] in
                    self?.onServiceDeletion?(id)
                }
            }
        }
        synchronizedQueue.addOperation(updateServicesOperation)
    }

    private func handleReplayEvent(eventsData: [NotifireWebSocketServiceEventData]) {
        for eventData in eventsData {
            handleServiceEvent(data: eventData)
        }
    }
}

extension ServicesViewModel: ServiceWebSocketManagerDelegate {
    func didRequestFreshConnect() {
        // Make sure to do a SyncAllServicesOperation again
        areLocalServicesSynchronized = false
    }
}
