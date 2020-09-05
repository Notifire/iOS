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

    enum APIGenerationResult {
        case success
        case wrongPassword
    }

    // MARK: - Properties
    let localService: LocalService
    let userSessionHandler: NotifireUserSessionHandler
    private var protectedApiManager: NotifireProtectedAPIManager {
        return userSessionHandler.notifireProtectedApiManager
    }
    private var realm: Realm {
        return userSessionHandler.realm
    }
    private var serviceToken: NotificationToken?

    // MARK: Model
    var isKeyVisible: Bool = false

    // MARK: Callbacks
    var onError: ((NotifireAPIManager.ManagerResultError) -> Void)?
    var onServiceUpdate: ((LocalService) -> Void)?
    var onServiceDeletion: (() -> Void)?

    // MARK: - Initialization
    init(localService: LocalService, sessionHandler: NotifireUserSessionHandler) {
        self.localService = localService
        self.userSessionHandler = sessionHandler
        setupLocalServicesTokenIfNeeded()
    }

    deinit {
        serviceToken?.invalidate()
    }

    // MARK: - Private
    private func setupLocalServicesTokenIfNeeded() {
        guard serviceToken == nil else { return }
        serviceToken = localService.observe({ [weak self] change in
            switch change {
            case .change:
                guard let updatedService = self?.localService else { return }
                self?.onServiceUpdate?(updatedService)
            case .error:
                break
            case .deleted:
                self?.onServiceDeletion?()
            }
        })
    }

    private func updateLocalServiceFromRemote(service: Service) {
        guard localService.uuid == service.uuid, let localUpdatedAt = localService.updatedAt, let updatedAt = service.updatedAt, localUpdatedAt < updatedAt else {
            return
        }
        try? realm.write {
            self.localService.updateDataExceptUUID(from: service)
        }
    }

    private func updateRemoteService() {
        protectedApiManager.update(service: localService) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let service):
                self.updateLocalServiceFromRemote(service: service)
            case .error(let error):
                self.onError?(error)
            }
        }
    }

    private func deleteLocalService() {
        try? realm.write {
            realm.delete(localService.notifications)
            realm.delete(localService)
        }
    }

    // MARK: - Methods
    func deleteService() {
        protectedApiManager.delete(service: localService) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .error(let error):
                self.onError?(error)
            case .success:
                self.deleteLocalService()
            }
        }
    }

    func updateService(block: (() -> Void)) {
        realm.beginWrite()
        block()
        localService.updatedAt = Date()
        var tokens: [NotificationToken] = []
        if let activeToken = serviceToken {
            tokens.append(activeToken)
        }
        try? realm.commitWrite(withoutNotifying: tokens)
        updateRemoteService()
    }

    func generateNewAPIKey(password: String, completion: @escaping (APIGenerationResult) -> Void) {
        protectedApiManager.changeApiKey(for: localService, password: password) { [weak self] result in
            switch result {
            case .error(let error):
                self?.onError?(error)
            case .success(let response):
                self?.updateLocalServiceFromRemote(service: response)
                completion(.success)
            }
        }
    }

    func deleteServiceNotifications() -> Bool {
        do {
            try realm.write {
                realm.delete(localService.notifications)
            }
            return true
        } catch {
            return false
        }
    }
}
