//
//  ServiceViewModel.swift
//  Notifire
//
//  Created by David Bielik on 11/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class ServiceViewModel: ViewModelRepresenting, APIErrorProducing {

    enum ServiceError: Equatable {
        case apiError(NotifireAPIError)
        case serviceCreationError(CreateLocalServiceOperation.Error)
    }

    enum ViewState: Equatable {
        case loading
        case error(ServiceError)
        case displaying(localService: LocalService)
    }

    enum APIKeyGenerationResult {
        case success
        case wrongPassword
    }

    // MARK: - Properties
    let serviceRepresentable: ServiceRepresentable
    let userSessionHandler: UserSessionHandler
    weak var servicesViewModel: ServicesViewModel?
    var localServiceObserver: RealmObjectObserver<LocalService>?

    private var protectedApiManager: NotifireProtectedAPIManager {
        return userSessionHandler.notifireProtectedApiManager
    }

    /// The currently displayed local service if available.
    var currentLocalService: LocalService? {
        guard
            case .displaying(let localService) = viewState,
            !localService.isInvalidated
        else { return nil }
        return localService
    }

    var currentServiceID: Int? {
        switch viewState {
        case .displaying:
            return currentLocalService?.id
        case .error, .loading:
            return serviceRepresentable.id
        }
    }

    // MARK: Model
    var viewStateModel = StateModel(defaultValue: ViewState.loading, shouldNotifyStateChangeWhenOldNewValuesEqual: true)
    var viewState: ViewState {
        return viewStateModel.state
    }

    var isKeyVisible: Bool = false

    /// `true` if the viewmodel is fetching the ServiceSnippet resource from the remote API.
    var isFetching: Bool = false

    /// `true` when the view is appearing for the first time
    var isFirstAppearance = true

    // MARK: Callbacks
    /// (old ViewState , new ViewState)
    var onViewStateChange: ((ViewState, ViewState) -> Void)?
    var onError: ((NotifireAPIError) -> Void)?
    var onServiceUpdate: ((LocalService) -> Void)?
    var onServiceShouldClose: (() -> Void)?

    // MARK: - Initialization
    init(service: ServiceRepresentable, sessionHandler: UserSessionHandler, servicesVM: ServicesViewModel) {
        self.serviceRepresentable = service
        self.userSessionHandler = sessionHandler
        self.servicesViewModel = servicesVM
        viewStateModel.onStateChange = { [weak self] old, new in
            self?.onViewStateChange?(old, new)
        }
    }

    // MARK: - Methods
    func start() {
        if let localService = serviceRepresentable as? LocalService {
            // serviceRepresentable was a `LocalService` instance
            // - display it

            startDisplaying(localService: localService)
        } else if let serviceSnippet = serviceRepresentable as? ServiceSnippet {
            // serviceRepresentable was a `ServiceSnippet` instance
            // - fetch the remote resource fully (GET /service)

            fetch(serviceSnippet: serviceSnippet)
        } else {
            Logger.log(.fault, "\(self) service representable is of an unknown type.")
        }
    }

    func startDisplaying(localService: LocalService) {
        if localServiceObserver == nil {
            // Create new RLM object observer
            let observer = RealmObjectObserver(realmProvider: userSessionHandler, object: localService)
            observer.onObjectChange = { [weak self] changes in
                switch changes {
                case .change(let object, _):
                    guard case .displaying(let service) = self?.viewState, service == object else { return }
                    self?.onServiceUpdate?(object)
                case .error, .deleted:
                    break
                }
            }
            localServiceObserver = observer
        }

        // Change the viewState
        viewStateModel.state = .displaying(localService: localService)
    }

    func fetch(serviceSnippet: ServiceSnippet) {
        guard !isFetching else {
            Logger.log(.debug, "\(self) attempted to fetch a new service snippet when already fetching.")
            return
        }

        isFetching = true

        viewStateModel.state = .loading

        self.servicesViewModel?.fetchService(snippet: serviceSnippet, completion: { [weak self] (maybeLocalService, maybeErrors) in
            self?.isFetching = false
            if let localService = maybeLocalService {
                // Success - LocalService created
                // Start displaying it

                self?.startDisplaying(localService: localService)
            } else if let errors = maybeErrors {

                // Error - handle errors
                if let apiError = errors.0 {
                    // NotifireAPIError
                    self?.viewStateModel.state = .error(.apiError(apiError))
                } else if let createOperationError = errors.1 {
                    // CreateLocalServiceOperation.Error
                    self?.viewStateModel.state = .error(.serviceCreationError(createOperationError))
                    // Ask the delegate to pop this VC
                    self?.onServiceShouldClose?()
                }
            }
        })
    }

    func updateService(block: (() -> Void)) {
        guard let localService = currentLocalService else { return }

        let realm = userSessionHandler.realm
        realm.beginWrite()
        block()
        var tokens: [NotificationToken] = []
        if let activeToken = localServiceObserver?.objectNotificationToken {
            tokens.append(activeToken)
        }
        try? realm.commitWrite(withoutNotifying: tokens)

        protectedApiManager.update(service: localService) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success:
                break
                // LocalService update handled by websocket changes
            case .error(let error):
                self.onError?(error)
            }
        }
    }

    func generateNewAPIKey(completion: @escaping (APIKeyGenerationResult) -> Void) {
        guard let localService = currentLocalService else { return }
        protectedApiManager.changeApiKey(for: localService) { [weak self] result in
            switch result {
            case .error(let error):
                self?.onError?(error)
            case .success:
                completion(.success)
            }
        }
    }

    func deleteServiceNotifications() -> Bool {
        guard let localService = currentLocalService else { return false }
        do {
            let realm = userSessionHandler.realm
            try realm.write {
                realm.delete(localService.notifications)
            }
            return true
        } catch {
            return false
        }
    }

    func deleteService() {
        guard let localService = currentLocalService else { return }
        protectedApiManager.delete(service: localService) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success:
                break
                // Websocket takes care of deleting this service
            }
        }
    }

    func setDefaultImage() {
        guard let localService = currentLocalService else { return }
        protectedApiManager.updateServiceWithImage(service: localService, imageData: nil) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success:
                // don't do anything, success = false means
                // that the updated service didn't change
                break
            }
        }
    }
}
