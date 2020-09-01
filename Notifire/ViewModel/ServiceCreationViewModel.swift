//
//  ServiceCreationViewModel.swift
//  Notifire
//
//  Created by David Bielik on 09/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class ServiceCreationViewModel: InputValidatingViewModel, APIFailable {

    // MARK: - Properties
    let protectedApiManager: NotifireProtectedAPIManager

    // MARK: Callbacks
    var onSuccess: ((Service) -> Void)?
    var onLoadingChange: ((Bool) -> Void)?
    // MARK: APIFailable
    var onError: ((NotifireAPIManager.ManagerResultError) -> Void)?

    // MARK: Model
    var serviceName: String = ""
    var loading: Bool = false {
        didSet {
            guard oldValue != loading else { return }
            onLoadingChange?(loading)
        }
    }
    // TODO: image
    let image: String = ""

    // MARK: - Initialization
    init(protectedApiManager: NotifireProtectedAPIManager) {
        self.protectedApiManager = protectedApiManager
    }

    // MARK: - Methods
    func createService() {
        guard !loading else { return }
        loading = true
        protectedApiManager.createService(name: serviceName, image: image) { [weak self] responseContext in
            self?.loading = false
            switch responseContext {
            case .error(let error):
                self?.onError?(error)
            case .success(let newService):
                self?.onSuccess?(newService)
            }
        }
    }
}
