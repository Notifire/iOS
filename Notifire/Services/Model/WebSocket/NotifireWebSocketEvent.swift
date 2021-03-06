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
}

// MARK: - NotifireWebSocketEvent
/// Protocol describing Notifire WebSocketEvent data that have an associated EventType.
protocol EventTypeable {
    static var associatedEvent: EventType { get }
}

/// Represents the events that are sent from the server to the client.
struct NotifireWebSocketEvent<EventData: Decodable & EventTypeable>: Decodable {

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

struct NotifireWebSocketEventType: Decodable {
    let event: EventType
}

// MARK: - Ready Event
struct NotifireWebSocketReadyEventData: Codable, EventTypeable {
    let sessionID: String
    let heartbeatInterval: TimeInterval

    private enum CodingKeys: String, CodingKey {
        case sessionID, heartbeatInterval = "pingInterval"
    }

    static let associatedEvent: EventType = .ready
}

typealias NotifireWebSocketReadyEvent = NotifireWebSocketEvent<NotifireWebSocketReadyEventData>

// MARK: - Service Event
typealias NotifireWebSocketServiceEventData = ServiceChangeEvent

extension NotifireWebSocketServiceEventData: EventTypeable {
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
