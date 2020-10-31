//
//  ServiceViewModel.swift
//  Notifire
//
//  Created by David Bielik on 11/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class ServiceViewModel: APIFailable {

    enum ViewState: Equatable {
        case skeleton
        case displaying(localService: LocalService)
    }

    enum APIKeyGenerationResult {
        case success
        case wrongPassword
    }

    // MARK: - Properties
    let serviceRepresentable: ServiceRepresentable
    var localServiceObserver: RealmObjectObserver<LocalService>?
    let userSessionHandler: UserSessionHandler

    private var protectedApiManager: NotifireProtectedAPIManager {
        return userSessionHandler.notifireProtectedApiManager
    }

    private var serviceToken: NotificationToken?

    /// The currently displayed local service if available.
    var currentLocalService: LocalService? {
        guard case .displaying(let localService) = viewState else { return nil }
        return localService
    }

    // MARK: Model
    var viewState: ViewState = .skeleton {
        didSet {
            onViewStateChange?(oldValue, viewState)
        }
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
    var onServiceDeletion: (() -> Void)?

    // MARK: - Initialization
    init(service: ServiceRepresentable, sessionHandler: UserSessionHandler) {
        self.serviceRepresentable = service
        self.userSessionHandler = sessionHandler
    }

    deinit {
        serviceToken?.invalidate()
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
        // Create new RLM object observer
        let observer = RealmObjectObserver(realmProvider: userSessionHandler, object: localService)
        observer.onObjectChange = { [weak self] changes in
            switch changes {
            case .change(let object, _):
                guard case .displaying(let service) = self?.viewState, service == object else { return }
                self?.onServiceUpdate?(object)
            case .deleted:
                self?.onServiceDeletion?()
            case .error:
                break
            }
        }
        localServiceObserver = RealmObjectObserver(realmProvider: userSessionHandler, object: localService)

        // Change the viewState
        viewState = .displaying(localService: localService)
    }

    func fetch(serviceSnippet: ServiceSnippet) {
        guard !isFetching else {
            Logger.log(.debug, "\(self) attempted to fetch a new service snippet when already fetching.")
            return
        }

        isFetching = true

        viewState = .skeleton

        protectedApiManager.get(service: serviceSnippet) { [weak self] result in
            guard let `self` = self else { return }
            self.isFetching = false
            switch result {
            case .error(let error):
                self.onError?(error)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.fetch(serviceSnippet: serviceSnippet)
                }
            case .success(let service):
                guard let localService = RealmManager.createLocalService(from: service, realm: self.userSessionHandler.realm) else {
                    Logger.log(.fault, "\(self) couldn't create new LocalService object, retrying GET /service request.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.fetch(serviceSnippet: serviceSnippet)
                    }
                    return
                }
                self.startDisplaying(localService: localService)
            }
        }
    }

    func updateService(block: (() -> Void)) {
        guard let localService = currentLocalService else { return }

        let realm = userSessionHandler.realm
        realm.beginWrite()
        block()
        var tokens: [NotificationToken] = []
        if let activeToken = serviceToken {
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

    func generateNewAPIKey(password: String, completion: @escaping (APIKeyGenerationResult) -> Void) {
        guard let localService = currentLocalService else { return }
        protectedApiManager.changeApiKey(for: localService, password: password) { [weak self] result in
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
                try? RealmManager.delete(localService: localService, realm: self.userSessionHandler.realm)
            }
        }
    }
}
