//
//  ServiceChangeEvent.swift
//  Notifire
//
//  Created by David Bielik on 06/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Describes a service change that should be performed.
/// Used for:
/// * WebSocket events
/// * Replay events
struct ServiceChangeEvent: Codable, CustomStringConvertible {

    enum ServiceEventType: String, Codable {
        case create, update, delete, upsert
    }

    /// The type of change on the `service` that should occur
    let type: ServiceEventType
    /// The service corresponding to the expected change (`type`)
    let service: Service

    var description: String {
        return "\(type.rawValue) service \(service.id)"
    }
}
