//
//  KeyboardFollowingButtonContaining.swift
//  Notifire
//
//  Created by David Bielik on 19/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Describes ViewControllers that contain a primary action button that follows keyboard show/hide animations.
protocol KeyboardFollowingButtonContaining: KeyboardObserving {
    /// `true` if the keyboard following button should be placed into a separated container with an opaque background.
    var shouldAddKeyboardFollowingContainer: Bool { get }

    /// Add a keyboard following button at the bottom of the screen just above the keyboard.
    func addKeyboardFollowing(button: UIButton, buttonBottomLessThanOrEqualToAnchor: NSLayoutYAxisAnchor?)
}

extension KeyboardFollowingButtonContaining {
    var shouldAddKeyboardFollowingContainer: Bool { return true }
}

extension KeyboardFollowingButtonContaining where Self: UIViewController {

    /// Add a keyboard following button to the bottom (or optionally to elsewhere depending on `buttonBottomLessThanOrEqualToAnchor`)
    func addKeyboardFollowing(button: UIButton, buttonBottomLessThanOrEqualToAnchor: NSLayoutYAxisAnchor? = nil) {
        view.add(subview: button)
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true
        let buttonBottomConstraint = button.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        buttonBottomConstraint.priority = .init(950)
        buttonBottomConstraint.isActive = true
        if let buttonBottomGuideAnchor = buttonBottomLessThanOrEqualToAnchor {
            button.bottomAnchor.constraint(lessThanOrEqualTo: buttonBottomGuideAnchor, constant: -Size.textFieldSpacing).isActive = true
        } else {
            button.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Size.textFieldSpacing).isActive = true
        }

        if shouldAddKeyboardFollowingContainer {
            let buttonContainerView = UIView()
            buttonContainerView.backgroundColor = .compatibleSystemBackground
            view.add(subview: buttonContainerView)
            buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
            view.insertSubview(buttonContainerView, belowSubview: button)
            buttonContainerView.embedSides(in: view)
            buttonContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

            button.topAnchor.constraint(equalTo: buttonContainerView.topAnchor, constant: Size.textFieldSpacing).isActive = true

            let buttonSeparator = HairlineView()
            view.add(subview: buttonSeparator)
            buttonSeparator.embedSides(in: view)
            buttonSeparator.topAnchor.constraint(equalTo: buttonContainerView.topAnchor).isActive = true
        }

        keyboardObserverHandler.onKeyboardNotificationCallback = { [weak self] expanding, notification in
            guard let keyboardHeight = self?.keyboardObserverHandler.keyboardHeight(from: notification) else { return }
            if expanding {
                buttonBottomConstraint.constant = -keyboardHeight - Size.textFieldSpacing
            }
        }
        keyboardObserverHandler.keyboardExpandedConstraints = [buttonBottomConstraint]
    }
}
