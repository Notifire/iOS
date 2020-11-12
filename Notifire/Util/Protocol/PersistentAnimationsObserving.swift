//
//  PersistentAnimationsObserving.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol PersistentAnimationsObserving: NotificationObserving {
    var persistentAnimations: [String: CAAnimation] { get set }
    var persistentSpeed: Float { get set }
}

extension PersistentAnimationsObserving {
    var notificationNames: [NSNotification.Name] {
        return [UIApplication.willEnterForegroundNotification, UIApplication.didEnterBackgroundNotification]
    }
}

extension PersistentAnimationsObserving where Self: CALayer {
    var notificationHandlers: NotificationHandlers {
        return [UIApplication.willEnterForegroundNotification: didBecomeActive,
                UIApplication.didEnterBackgroundNotification: willResignActive]
    }

    func didBecomeActive(notification: Notification) {
        restoreAnimations(withKeys: Array(persistentAnimations.keys))
        persistentAnimations.removeAll()
        if persistentSpeed == 1.0 {
            resume()
        }
    }

    func willResignActive(notification: Notification) {
        persistentSpeed = speed

        speed = 1.0
        persistAnimations(withKeys: animationKeys())
        speed = persistentSpeed

        pause()
    }

    func persistAnimations(withKeys: [String]?) {
        withKeys?.forEach({ (key) in
            if let animation = animation(forKey: key) {
                persistentAnimations[key] = animation
            }
        })
    }

    func restoreAnimations(withKeys: [String]?) {
        withKeys?.forEach { key in
            if let persistentAnimation = persistentAnimations[key] {
                add(persistentAnimation, forKey: key)
            }
        }
    }
}
