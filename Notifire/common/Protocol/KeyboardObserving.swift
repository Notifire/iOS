//
//  KeyboardObserving.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol KeyboardObserving: NotificationObserving {
    var keyboardObserverHandler: KeyboardObserverHandler { get }
}

extension KeyboardObserving {
    var notificationNames: [NSNotification.Name] {
        return [UIResponder.keyboardWillShowNotification, UIResponder.keyboardWillHideNotification]
    }

    var observers: [NSObjectProtocol] {
        get {
            return keyboardObserverHandler.observers
        }
        set {
            keyboardObserverHandler.observers = newValue
        }
    }
}

extension KeyboardObserving where Self: UIViewController {
    var notificationHandlers: [NSNotification.Name: ((Notification) -> Void)] {
        return [UIResponder.keyboardWillShowNotification: keyboardWillShow,
                UIResponder.keyboardWillHideNotification: keyboardWillHide]
    }

    // MARK: Private
    private func handle(notification: Notification, expanding: Bool, activate: [NSLayoutConstraint], deactivate: [NSLayoutConstraint]) {
        // Get in-flight animation data
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        // Handle constraints
        deactivate.forEach { $0.isActive = false }
        activate.forEach { $0.isActive = true }
        // Call the callback outside of the animation block
        keyboardObserverHandler.onKeyboardNotificationCallback?(expanding, notification)
        view.setNeedsLayout()
        // Animate the second (animation) callback
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.init(rawValue: curve.uintValue), animations: {
            self.keyboardObserverHandler.onKeyboardNotificationAnimationCallback?(expanding, duration)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    // MARK: Notification Handlers
    func keyboardWillShow(notification: Notification) {
        guard let keyboardEndFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardEndHeight = keyboardEndFrame.cgRectValue.height
        let lastNotification = keyboardObserverHandler.lastKeyboardNotification
        keyboardObserverHandler.lastKeyboardNotification = notification
        if let lastNotification = lastNotification, let lastHeight = keyboardObserverHandler.keyboardHeight(from: lastNotification) {
            guard lastHeight < keyboardEndHeight else { return }
        }
        handle(
            notification: notification,
            expanding: true,
            activate: keyboardObserverHandler.keyboardExpandedConstraints,
            deactivate: keyboardObserverHandler.keyboardCollapsedConstraints
        )
    }

    func keyboardWillHide(notification: Notification) {
        keyboardObserverHandler.lastKeyboardNotification = nil
        handle(
            notification: notification,
            expanding: false,
            activate: keyboardObserverHandler.keyboardCollapsedConstraints,
            deactivate: keyboardObserverHandler.keyboardExpandedConstraints
        )
    }

}
