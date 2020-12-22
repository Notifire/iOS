//
//  GetServiceOperation.swift
//  Notifire
//
//  Created by David Bielik on 21/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Class responsible for retrieving the next batch of services (Local + Remote if available)
class GetServiceOperation: ProtectedNetworkOperation<ServiceGetResponse> {

    // MARK: - Properties
    let snippet: ServiceSnippet

    // MARK: - Initialization
    init(serviceSnippet: ServiceSnippet, apiManager: NotifireProtectedAPIManager) {
        self.snippet = serviceSnippet
        super.init(apiManager: apiManager)
    }

    // MARK: - Main
    override func main() {
        super.main()

        apiManager.get(service: snippet) { [weak self] result in
            self?.complete(result: result)
        }
    }
}
