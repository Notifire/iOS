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
struct ServiceChangeEvent: Decodable, CustomStringConvertible {

    private enum ServiceEventType: String, Codable {
        case create, update, upsert, delete
    }

    enum DecodingError: Error {
        case mismatchedServiceDataAndEvent
    }

    enum ServiceChangeData {
        case create(Service)
        case update(Service)
        case upsert(Service)
        case delete(id: Int)
    }

    /// The type of change on the `service` that should occur
    let serviceChangeData: ServiceChangeData

    // MARK: Initialization
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(ServiceEventType.self, forKey: .type)
        switch type {
        case .create:
            let service = try container.decode(Service.self, forKey: .serviceData)
            self.init(serviceChangeData: .create(service))
        case .update:
            let service = try container.decode(Service.self, forKey: .serviceData)
            self.init(serviceChangeData: .update(service))
        case .upsert:
            let service = try container.decode(Service.self, forKey: .serviceData)
            self.init(serviceChangeData: .upsert(service))
        case .delete:
            let serviceIDContainer = try container.nestedContainer(keyedBy: IDCodingKeys.self, forKey: .serviceData)
            let serviceID = try serviceIDContainer.decode(Int.self, forKey: .id)
            self.init(serviceChangeData: .delete(id: serviceID))
        }
    }

    init(serviceChangeData: ServiceChangeData) {
        self.serviceChangeData = serviceChangeData
    }

    var description: String {
        switch serviceChangeData {
        case .create(let service): return "create service (id=\(service.id))"
        case .update(let service): return "update service (id=\(service.id))"
        case .upsert(let service): return "upsert service (id=\(service.id))"
        case .delete(let id): return "delete service (id=\(id))"
        }
    }

    private enum CodingKeys: String, CodingKey {
        case type, serviceData = "service"
    }

    private enum IDCodingKeys: String, CodingKey {
        case id
    }
}
//
///// Protocol describing Notifire WebSocketEvent data that have an associated EventType.
//protocol ServiceChangeEventTypeable {
//    static var associatedEventTypes: [ServiceChangeEventType] { get }
//}
//
//enum ServiceChangeEventType: String, Codable, Equatable {
//    case create, update, delete, upsert
//}
//
//struct ServiceChangeEvent2<ServiceEventData: Codable & ServiceChangeEventTypeable>: Codable {
//    enum DecodingError: Error {
//        case mismatchedDataAndEvent
//    }
//
//    // MARK: Properties
//    let eventType: ServiceChangeEventType
//    let serviceData: ServiceEventData
//
//    // MARK: Initialization
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        let eventType = try container.decode(ServiceChangeEventType.self, forKey: .eventType)
//        guard ServiceEventData.associatedEventTypes.contains(eventType) else { throw DecodingError.mismatchedDataAndEvent }
//
//        let serviceData = try container.decode(ServiceEventData.self, forKey: .serviceData)
//        self.init(serviceData: serviceData, eventType: eventType)
//    }
//
//    init(serviceData: ServiceEventData, eventType: ServiceChangeEventType) {
//        self.eventType = eventType
//        self.serviceData = serviceData
//    }
//
//    // MARK: Codable
//    private enum CodingKeys: String, CodingKey {
//        case eventType, serviceData = "service"
//    }
//
//    // MARK: CustomStringConvertible
//    var description: String {
//        return "\(eventType.rawValue) service \(serviceData.asDictionary ?? [:])"
//    }
//}
//
// MARK: - Create, Update, Upsert
//typealias FullServiceChangeEvent = ServiceChangeEvent<Service>
//
//extension Service: ServiceChangeEventTypeable {
//
//    static var associatedEventTypes: [ServiceChangeEventType] {
//        return [.create, .update, .upsert]
//    }
//}
//
// MARK: - Delete
//struct DeleteServiceEventData: Codable, ServiceChangeEventTypeable {
//    let id: Int
//
//    static var associatedEventTypes: [ServiceChangeEventType] {
//        return [.delete]
//    }
//}
//
//typealias DeleteServiceEvent = ServiceChangeEvent<DeleteServiceEventData>
