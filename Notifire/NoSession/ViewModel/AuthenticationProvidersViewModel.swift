//
//  AuthenticationProvidersViewModel.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class AuthenticationProvidersViewModel {

    // MARK: - Properties
    let providers: [AuthenticationProvider]
    private let tagToProviders: [Int: AuthenticationProvider]
    private let providerToTags: [AuthenticationProvider: Int]

    // MARK: SSO
    let ssoManager = SSOManager()

    // MARK: Actions
    /// Callback for the buttons UI to get updated when the authentication is finished.
    /// - Parameters:
    ///     - Int: the tag of the button that should be updated
    var onAuthenticationFinished: ((Int) -> Void)?

    // MARK: - Initialization
    init(providers: [AuthenticationProvider]) {
        self.providers = providers
        var tagProviders = [Int: AuthenticationProvider]()
        var providerTags = [AuthenticationProvider: Int]()
        for (i, provider) in providers.enumerated() {
            tagProviders[i] = provider
            providerTags[provider] = i
        }
        self.providerToTags = providerTags
        self.tagToProviders = tagProviders
    }

    // MARK: - Public
    func providerFrom(tag: Int) -> AuthenticationProvider {
        return tagToProviders[tag] ?? .apple
    }

    func tagFrom(provider: AuthenticationProvider) -> Int {
        return providerToTags[provider] ?? 0
    }

    func startAuthenticationFlow(with provider: AuthenticationProvider) {
        ssoManager.signIn(with: provider)
    }

    func finishAuthenticationFlow(with provider: AuthenticationProvider) {
        let tag = tagFrom(provider: provider)
        onAuthenticationFinished?(tag)
    }
}
