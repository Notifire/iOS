//
//  Observing.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

protocol Observing: class {
    typealias NotificationHandlers = [NSNotification.Name: ((Notification) -> Void)]

    var observers: [NSObjectProtocol] { get set }
    var notificationNames: [NSNotification.Name] { get }
    var notificationHandlers: NotificationHandlers { get }

    func setupObservers()
    func removeObservers()
}

extension Observing {
    func setupObservers() {
        // skip setup if we are already observing
        guard observers.isEmpty else { return }
        // setup observers
        for notification in notificationNames {
            guard let notificationHandler = notificationHandlers[notification] else { continue }
            let newObserver = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil, using: notificationHandler)
            observers.append(newObserver)
        }
    }

    func removeObservers() {
        observers.forEach { NotificationCenter.default.removeObserver($0) }
    }
}
