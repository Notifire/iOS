//
//  LocalRemoteServicesAction.swift
//  Notifire
//
//  Created by David Bielik on 05/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Describes the set of possible actions performed by `UpdateServiceRepresentablesOperation`.
enum LocalRemoteServicesAction: CustomStringConvertible {

    // MARK: Pagination
    /// The pagination / add batch action.
    /// - Note: supports offline mode
    case add(batch: [ServiceSnippet])

     // MARK: Websocket
    /// Changes a single service according to the associated `ServiceChangeEvent` value
    case changeSingleService(ServiceChangeEvent)
    /// Changes multiple services at once. (Bulk `.changeSingleService`)
    case changeMultipleServices([ServiceChangeEvent])

    var description: String {
        switch self {
        case .add(let services): return "add batch of \(services.count) services"
        case .changeSingleService(let changeEvent): return "change \(changeEvent.description)"
        case .changeMultipleServices(let changeEvents): return "bulk change of \(changeEvents.count) services"
        }
    }
}
