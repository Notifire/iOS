//
//  GetServicesBatchOperation.swift
//  Notifire
//
//  Created by David Bielik on 24/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Class responsible for retrieving the next batch of services (Local + Remote if available)
class GetServicesBatchOperation: ProtectedNetworkOperation<ServicesResponse> {

    // MARK: - Properties
    let limit: Int
    let paginationData: PaginationData?

    // MARK: - Initialization
    init(servicesLimit: Int, paginationData: PaginationData?, apiManager: NotifireProtectedAPIManager) {
        self.limit = servicesLimit
        self.paginationData = paginationData
        super.init(apiManager: apiManager)
    }

    // MARK: - Main
    override func main() {
        guard !isCancelled else { return }

        apiManager.getServices(limit: limit, paginationData: paginationData) { [weak self] result in
            self?.complete(result: result)
        }
    }
}
