//
//  SignInButton.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class SignInButton: NotifireButton {

    // MARK: - Inherited
    override open func setup() {
        borderWidth = Theme.defaultBorderWidth
        borderColor = .compatibleLabel
        super.setup()
        backgroundColor = .compatibleSystemBackground
        shouldAnimateScale = false
        setTitleColor(.compatibleLabel, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        imageView?.contentMode = .scaleAspectFit
        let spacing: CGFloat = 8
        imageEdgeInsets = UIEdgeInsets(top: Size.smallMargin, left: 0, bottom: Size.smallMargin, right: spacing)
        titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: 0)
    }

    /// Sets up the sign in button with a specific provider.
    public func updateUI(for provider: AuthenticationProvider) {
        setTitle("Sign in with \(provider)", for: .normal)
        setImage(provider.providerImage, for: .normal)
        if provider == .email {
           imageView?.tintColor = .primary
        } else if provider == .sso(.github) {
           imageView?.tintColor = .compatibleGithubColor
        }
    }
}
