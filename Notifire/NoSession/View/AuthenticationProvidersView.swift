//
//  AuthenticationProvidersView.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import AuthenticationServices

class AuthenticationProvidersView: VMView<AuthenticationProvidersViewModel>, CenterStackViewPresenting {

    // MARK: - Properties
    lazy var buttons: [UIControl] = createButtons(for: viewModel.providers)

    public var emailButtonControl: UIControl? {
        let emailTag = viewModel.tagFrom(provider: .email)
        return buttons.first { $0.tag == emailTag }
    }

    // MARK: CenterStackViewPresenting
    var stackViewSuperview: UIView { return self }

    // MARK: - View Lifecycle
    override func setupSubviews() {
        super.setupSubviews()
        backgroundColor = .clear

        // ViewModel
        viewModel.onAuthenticationFinished = { [weak self] tag in
            let maybeButton = self?.buttons.first { $0.tag == tag }
            if let btn = (maybeButton as? NotifireButton) {
                btn.stopLoading()
            }
            self?.isUserInteractionEnabled = true
        }

        // StackView
        let stackView = insertStackView(arrangedSubviews: buttons, spacing: Size.textFieldSpacing)
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        // Set the `ASAuthorizationAppleIDButton` height to match the other buttons
        guard #available(iOS 13.0, *) else { return }
        for control in buttons {
            if let appleControlButton = control as? ASAuthorizationAppleIDButton {
                appleControlButton.heightAnchor.constraint(equalToConstant: Size.componentHeight).isActive = true
            }
        }
    }

    /** Creates a button array for the providers parameter with a specific button style.
     - Parameters:
        -   providers:  the selected `AuthenticationProvider`s
        -   buttonStyle: the style of the buttons (text)
    */
    private func createButtons(for providers: [AuthenticationProvider]) -> [UIControl] {
        var buttons = [UIControl]()
        // For each provider create a sign in button
        for provider in providers {
            let providerControl: UIControl
            if provider == .sso(.apple) {
                providerControl = createAppleSignInButton()
            } else {
                providerControl = createSignInButton(for: provider)
            }
            buttons.append(providerControl)
        }
        return buttons
    }

    private func createAppleSignInButton() -> UIControl {
        if #available(iOS 13.0, *) {
            let button = ASAuthorizationAppleIDButton(authorizationButtonType: .default, authorizationButtonStyle: .white)
            button.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            button.layer.cornerRadius = Theme.defaultCornerRadius
            button.layer.borderWidth = Theme.defaultBorderWidth
            return button
        } else {
            return UIButton()
        }
    }

    private func createSignInButton(for provider: AuthenticationProvider) -> UIControl {
        let providerButton = SignInButton()
        providerButton.tag = viewModel.tagFrom(provider: provider)
        if let ssoProvider = provider.getExternalSSOProvider() {
            providerButton.onProperTap = { [unowned self] btn in
                // Start the loading animation in the button
                (btn as? NotifireButton)?.startLoading()
                // Disable interaction with other buttons until we finish the flow
                self.isUserInteractionEnabled = false
                // Start the authentication flow
                self.viewModel.startAuthenticationFlow(with: ssoProvider)
            }
        }
        providerButton.updateUI(for: provider)
        return providerButton
    }

    // MARK: - Event Handlers
    // MARK: Apple ID Button
    @objc private func handleAuthorizationAppleIDButtonPress() {
        guard #available(iOS 13.0, *) else { return }
        // Disable interaction with other buttons until we finish the flow
        self.isUserInteractionEnabled = false
        self.viewModel.startAuthenticationFlow(with: .apple)
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = viewModel.ssoManager
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension AuthenticationProvidersView: ASAuthorizationControllerPresentationContextProviding {

    /// For presentation of the Authorization UIWindow
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.window!
    }
}
