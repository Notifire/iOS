//
//  KeyboardObserverHandler.swift
//  Notifire
//
//  Created by David Bielik on 05/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// A class that encapsulates properties needed in `KeyboardObserving` protocol.
class KeyboardObserverHandler {

    // MARK: - Properties
    /// The last observed notification. Used internally to propagate handles as needed.
    var lastKeyboardNotification: Notification?
    var observers = [NSObjectProtocol]()

    // MARK: Public
    /// The array of constraints that should be activated when the keyboard is appearing / is expanded.
    /// - Note: These constraints are animated automatically alongside the keyboard animation.
    var keyboardExpandedConstraints = [NSLayoutConstraint]()

    /// The array of constraints that should be activated when the keyboard is disappearing / is hidden.
    /// - Note: These constraints are animated automatically alongside the keyboard animation.
    var keyboardCollapsedConstraints = [NSLayoutConstraint]()

    /// The callback that gets called whenever the keyboard is animating. Called inside a `UIView.animate` block.
    /// - Parameters:
    ///     - expanding: a boolean value describing if the keyboard is expanding (going to appear) or not
    ///     - duration: the duration of the animation
    var onKeyboardNotificationAnimationCallback: ((Bool, TimeInterval) -> Void)?

    /// The callback that gets called whenever the keyboard is about to change.
    /// This function is called outside (before) any animation blocks and is followed by a `setNeedsLayout()` call on the view.
    /// - Parameters:
    ///     - expanding: a boolean value describing if the keyboard is expanding (going to appear) or not
    ///     - notification: the keyboard notification
    var onKeyboardNotificationCallback: ((Bool, Notification) -> Void)?

    // MARK: - Private
    /// Determine the keyboard height from a `Notification`
    func keyboardHeight(from notification: Notification) -> CGFloat? {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return nil
        }
        let keyboardRectangle = keyboardFrame.cgRectValue
        return keyboardRectangle.height
    }
}
