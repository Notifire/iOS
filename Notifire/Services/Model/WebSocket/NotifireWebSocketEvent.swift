//
//  NotifireWebSocketEvent.swift
//  Notifire
//
//  Created by David Bielik on 01/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

// MARK: - EventType
/// The websocket events sent to the client from the server.
enum EventType: String, Codable {
    case ready, serviceEvent, replay, error

    private enum CodingKeys: String, CodingKey {
        case replay, ready, error, serviceEvent = "service_event"
    }
}

// MARK: - NotifireWebSocketEvent
protocol EventTypeable {
    static var associatedEvent: EventType { get }
}

/// Represents the events that are sent from the server to the client.
struct NotifireWebSocketEvent<EventData: Codable & EventTypeable>: Codable {

    enum DecodingError: Error {
        case mismatchedDataAndEvent
    }

    // MARK: Properties
    let event: EventType
    let data: EventData

    // MARK: Initialization
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let event = try container.decode(EventType.self, forKey: .event)
        guard event == EventData.associatedEvent else { throw DecodingError.mismatchedDataAndEvent }

        let data = try container.decode(EventData.self, forKey: .data)
        self.init(data: data)
    }

    init(data: EventData) {
        self.event = EventData.associatedEvent
        self.data = data
    }

    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case event, data = "d"
    }
}

// MARK: - Ready Event
struct NotifireWebSocketReadyEventData: Codable, EventTypeable {
    let sessionID: String
    let timestamp: Date

    static let associatedEvent: EventType = .ready
}

typealias NotifireWebSocketReadyEvent = NotifireWebSocketEvent<NotifireWebSocketReadyEventData>

// MARK: - Service Event
struct NotifireWebSocketServiceEventData: Codable, EventTypeable {

    enum ServiceEventType: String, Codable {
        case create, update, delete, upsert
    }

    let type: ServiceEventType
    let service: Service

    static let associatedEvent: EventType = .serviceEvent
}

typealias NotifireWebSocketServiceEvent = NotifireWebSocketEvent<NotifireWebSocketServiceEventData>

// MARK: - Replay Event
typealias NotifireWebSocketReplayEventData = [NotifireWebSocketServiceEventData]

extension NotifireWebSocketReplayEventData: EventTypeable {
    static var associatedEvent: EventType {
        return .replay
    }
}

typealias NotifireWebSocketReplayEvent = NotifireWebSocketEvent<NotifireWebSocketReplayEventData>

// MARK: - Error Event
struct NotifireWebSocketErrorEventData: Codable, EventTypeable {
    let message: String
    let verbose: String

    static let associatedEvent: EventType = .error
}

typealias NotifireWebSocketErrorEvent = NotifireWebSocketEvent<NotifireWebSocketErrorEventData>
