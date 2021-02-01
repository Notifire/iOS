//
//  DarkModeAuthorizationAppleIDButton.swift
//  Notifire
//
//  Created by David Bielik on 27/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import AuthenticationServices

/// https://developer.apple.com/forums/thread/121762
@available(iOS 13.0, *)
class DarkModeAuthorizationAppleIDButton: UIControl {
    private var target: Any?
    private var action: Selector?
    private var controlEvents: UIControl.Event = .touchUpInside
    private lazy var whiteButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
    private lazy var darkButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)

    override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        self.target = target
        self.action = action
        self.controlEvents = controlEvents
        setupButton()
        updateBorder()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupButton()
        updateBorder()
    }

    // MARK: - Private Methods
    private func updateBorder() {
        layer.borderColor = UIColor.compatibleLabel.cgColor
    }

    private func setupButton() {
        switch traitCollection.userInterfaceStyle {
        case .dark:
            whiteButton.removeTarget(target, action: action, for: controlEvents)
            subviews.forEach { $0.removeFromSuperview() }
            add(subview: darkButton)
            darkButton.embed(in: self)
            action.map { darkButton.addTarget(target, action: $0, for: controlEvents) }
        case _:
            darkButton.removeTarget(target, action: action, for: controlEvents)
            subviews.forEach { $0.removeFromSuperview() }
            add(subview: whiteButton)
            whiteButton.embed(in: self)
            action.map { whiteButton.addTarget(target, action: $0, for: controlEvents) }
        }
    }
}
