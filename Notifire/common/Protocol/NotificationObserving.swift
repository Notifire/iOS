//
//  NotificationObserving.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

// MARK: - NotificationObserving
/// Protocol that describes classes that are able to observe notifications sent by`NotificationCenter`.
/// - Note: instead of implementing this protocol you might want to use `NotificationObserver` class that already provides a sufficient implementation for most cases.
protocol NotificationObserving: class {
    typealias NotificationHandler = ((Notification) -> Void)
    typealias NotificationHandlers = [NSNotification.Name: ((Notification) -> Void)]

    /// The actual observers created by `startObservingNotifications()`
    var observers: [NSObjectProtocol] { get set }
    /// The notification names that will be observed.
    var notificationNames: [NSNotification.Name] { get }
    /// The notification handlers (callbacks) that will be invoked when the corresponding notification is received.
    var notificationHandlers: NotificationHandlers { get }

    /// Creates observers and adds handlers on the default `NotificationCenter` for each notification name in `notificationNames`
    func startObservingNotifications()
    /// Removes observers from the notification center and the observers array.
    func stopObservingNotifications()
}

extension NotificationObserving {
    func startObservingNotifications() {
        // skip setup if we are already observing
        guard observers.isEmpty else { return }
        // setup observers
        for notification in notificationNames {
            guard let notificationHandler = notificationHandlers[notification] else { continue }
            let newObserver = NotificationCenter.default.addObserver(forName: notification, object: nil, queue: nil, using: notificationHandler)
            observers.append(newObserver)
        }
    }

    func stopObservingNotifications() {
        // Remove the observing notifications
        observers.forEach { NotificationCenter.default.removeObserver($0) }
        // Empty the observers array
        observers = []
    }
}

// MARK: - NotificationObserver
/// The default (full) implementation of `NotificationObserving`
class NotificationObserver: NotificationObserving {

    // MARK: - Properties
    var observers: [NSObjectProtocol] = []
    var notificationNames: [NSNotification.Name]
    var notificationHandlers: NotificationHandlers

    // MARK: - Initialization
    /// - Parameters:
    ///     - notificationNames: array of `NSNotification.Name` that this observer will observe
    ///     - notificationHandlers: dictionary of `NSNotification.Name` and `NotificationHandler`. Make sure the size of this dict matches the size of `notificationNames`
    ///     - setupImmediately: if `true`, the `setupObservers()` method is called automatically in the initializer. Set this to false if you want to observe notifications later.
    init(notificationNames: [NSNotification.Name], notificationHandlers: NotificationHandlers, setupImmediately: Bool = true) {
        self.notificationNames = notificationNames
        self.notificationHandlers = notificationHandlers
        startObservingNotifications()
    }

    convenience init(notificationName: NSNotification.Name, notificationHandler: @escaping NotificationHandler) {
        self.init(notificationNames: [notificationName], notificationHandlers: [notificationName: notificationHandler])
    }

    deinit {
        stopObservingNotifications()
    }
}
