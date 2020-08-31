//
//  KeyboardObserving.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol KeyboardObserving: Observing {
    var keyboardExpandedConstraints: [NSLayoutConstraint] { get }
    var keyboardCollapsedConstraints: [NSLayoutConstraint] { get }
    
    var keyboardAnimationBlock: ((Bool, TimeInterval) -> Void)? { get set }
    
    func onKeyboardChange(expanding: Bool, notification: Notification)
}

extension KeyboardObserving {
    var notificationNames: [NSNotification.Name] {
        return [UIResponder.keyboardWillShowNotification, UIResponder.keyboardWillHideNotification]
    }
    
    func onKeyboardChange(expanding: Bool, notification: Notification) {}
}

extension KeyboardObserving where Self: UIViewController {
    var notificationHandlers: [NSNotification.Name: ((Notification) -> ())] {
        return [UIResponder.keyboardWillShowNotification: keyboardWillShow,
                UIResponder.keyboardWillHideNotification: keyboardWillHide]
    }
    
    // MARK: Private
    private func handle(notification: Notification, expanding: Bool, activate: [NSLayoutConstraint], deactivate: [NSLayoutConstraint]) {
        guard let userInfo = notification.userInfo,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return }
        
        deactivate.forEach { $0.isActive = false }
        activate.forEach { $0.isActive = true }
        onKeyboardChange(expanding: expanding, notification: notification)
        view.layoutIfNeeded()
        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.init(rawValue: curve.uintValue), animations: {
            self.keyboardAnimationBlock?(expanding, duration)
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    // MARK: Notification Handlers
    func keyboardWillShow(notification: Notification) {
        handle(notification: notification, expanding: true, activate: keyboardExpandedConstraints, deactivate: keyboardCollapsedConstraints)
    }
    
    func keyboardWillHide(notification: Notification) {
        handle(notification: notification, expanding: false, activate: keyboardCollapsedConstraints, deactivate: keyboardExpandedConstraints)
    }
    
}
