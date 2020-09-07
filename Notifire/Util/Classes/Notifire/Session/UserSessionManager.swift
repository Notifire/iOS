//
//  UserSessionManager.swift
//  Notifire
//
//  Created by David Bielik on 11/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import KeychainAccess

class UserSessionManager {

    // MARK: - Properties
    private static let teamID = "6QH7E4QW2D"
    private static let keychainAccessGroup = "\(teamID).\(Config.bundleID)"
    static let appGroupSuiteName = "group.\(Config.bundleID)"
    static let appGroupSuiteNameWithTeamID = "\(teamID).\(appGroupSuiteName)"

    /// Enumeration describing the keys used by the keychain
    private enum Key: String, CaseIterable {
        case email
        case refreshToken
        case deviceToken
        case ssoUserIdentifier
        case provider
        case firstLaunch

        static var userDataKeys: [Key] {
            return allCases.filter { $0 != .firstLaunch }
        }
    }

    private lazy var keychain = Keychain(service: Config.bundleID, accessGroup: UserSessionManager.keychainAccessGroup)

    // MARK: - Methods
    private func keychainKey(key: Key, userIdentifier: String? = nil) -> String {
        let keychainKey: [String]
        if let identifier = userIdentifier {
            // the value is specific for some user
            keychainKey = [Config.bundleID, identifier, key.rawValue]
        } else {
            // The value is specific only for the app (bundleID)
            keychainKey = [Config.bundleID, key.rawValue]
        }
        return keychainKey.joined(separator: ".")
    }

    /// Gets the keychain value for the specified key.
    /// - Parameters:
    ///     - key: the unique key for the value in the keychain
    ///     - userIdentifier: optional identifier that is used to differentiate various user accounts that could be logged in on one device (e.g. user's email)
    private func getKeychainValue(key: Key, userIdentifier: String? = nil) -> String? {
        return try? keychain.getString(
            keychainKey(key: key, userIdentifier: userIdentifier)
        )
    }

    private func setKeychainValue(value: String, key: Key, userIdentifier: String? = nil) {
        try? keychain.set(value, key: keychainKey(key: key, userIdentifier: userIdentifier))
    }

    private func loadUserSession(email: String) -> UserSession? {
        // Get data that will be used to instantiate a new UserSession
        guard
            let refreshToken = getKeychainValue(key: Key.refreshToken, userIdentifier: email),
            let providerString = getKeychainValue(key: Key.provider, userIdentifier: email),
            let provider = AuthenticationProvider(providerString: providerString)
        else { return nil }
        // There userIdentifier might be nil if the provider = .email
        let ssoUserIdentifier = getKeychainValue(key: Key.ssoUserIdentifier, userIdentifier: email)
        let providerData = AuthenticationProviderData(provider: provider, email: email, userID: ssoUserIdentifier)
        let userSession = UserSession(refreshToken: refreshToken, providerData: providerData)
        if let deviceToken = getKeychainValue(key: Key.deviceToken, userIdentifier: email) {
            userSession.deviceToken = deviceToken
        }
        return userSession
    }

    // MARK: - Session Management
    /// Return a UserSession from the keychain.
    public func previousUserSession() -> UserSession? {
        guard
            let keychainStoredEmail = getKeychainValue(key: Key.email),
            let session = loadUserSession(email: keychainStoredEmail)
        else { return nil }
        return session
    }

    func saveSession(userSession: UserSession) {
        let email = userSession.email
        // set the last logged in email to the email in this userSession
        setKeychainValue(value: email, key: Key.email)
        // set the email of the userSession
        setKeychainValue(value: email, key: Key.email, userIdentifier: email)
        setKeychainValue(value: userSession.refreshToken, key: Key.refreshToken, userIdentifier: email)
        setKeychainValue(value: userSession.providerData.provider.description, key: Key.provider, userIdentifier: email)
        if let ssoUserID = userSession.providerData.userID {
            setKeychainValue(value: ssoUserID, key: Key.ssoUserIdentifier, userIdentifier: email)
        }
        if let deviceToken = userSession.deviceToken {
            setKeychainValue(value: deviceToken, key: Key.deviceToken, userIdentifier: email)
        }
    }

    func removeSession(userSession: UserSession) {
        // remove last logged in email
        try? keychain.remove(Key.email.rawValue)
        // remove user data
        for key in Key.userDataKeys {
            try? keychain.remove(keychainKey(key: key, userIdentifier: userSession.email))
        }
    }
}
