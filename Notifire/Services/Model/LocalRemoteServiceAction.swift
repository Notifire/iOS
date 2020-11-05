//
//  LocalRemoteServiceAction.swift
//  Notifire
//
//  Created by David Bielik on 05/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

enum LocalRemoteServiceAction: CustomStringConvertible {
    // MARK: Pagination
    /// The pagination / add batch action.
    /// - Note: supports offline mode
    case add(batch: [ServiceSnippet])

    // MARK: Websocket
    case create(service: Service)
    case update(service: Service)
    case delete(service: Service)
    case upsert(service: Service)

    var description: String {
        switch self {
        case .add: return "add batch"
        case .create: return "create service"
        case .update: return "update service"
        case .delete: return "delete service"
        case .upsert: return "upsert service"
        }
    }

    // MARK: - Initialization
    /// Convenenice intializer from `NotifireWebSocketServiceEventData`
    init(from serviceEventData: NotifireWebSocketServiceEventData) {
        switch serviceEventData.type {
        case .create: self = .create(service: serviceEventData.service)
        case .delete: self = .delete(service: serviceEventData.service)
        case .update: self = .update(service: serviceEventData.service)
        case .upsert: self = .upsert(service: serviceEventData.service)
        }
    }
}
