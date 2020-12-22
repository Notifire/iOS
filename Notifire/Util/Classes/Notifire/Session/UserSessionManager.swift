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
    private static let keychainAccessGroup = "\(teamID).\(Config.productBundleID)"
    static let appGroupSuiteName = "group.\(Config.productBundleID)"
    static let appGroupSuiteNameWithTeamID = "\(teamID).\(appGroupSuiteName)"

    /// Enumeration describing the keys used by the keychain
    /// Note: User specific
    enum KeychainKey: String, CaseIterable {
        case email
        case refreshToken
        case deviceToken
        case ssoUserIdentifier
        case provider
    }

    private static var keychain = Keychain(service: "userData", accessGroup: keychainAccessGroup)

    // MARK: - Methods
    private static func keychainKey(key: KeychainKey, userIdentifier: String? = nil) -> String {
        let keychainKey: [String]
        if let identifier = userIdentifier {
            // the value is specific for some user
            keychainKey = [Config.productBundleID, identifier, key.rawValue]
        } else {
            // The value is specific only for the app (bundleID)
            keychainKey = [Config.productBundleID, key.rawValue]
        }
        return keychainKey.joined(separator: ".")
    }

    /// Gets the keychain value for the specified key.
    /// - Parameters:
    ///     - key: the unique key for the value in the keychain
    ///     - userIdentifier: optional identifier that is used to differentiate various user accounts that could be logged in on one device (e.g. user's email)
    private static func getKeychainValue(key: KeychainKey, userIdentifier: String? = nil) -> String? {
        return try? keychain.getString(
            keychainKey(key: key, userIdentifier: userIdentifier)
        )
    }

    private static func setKeychainValue(value: String, key: KeychainKey, userIdentifier: String? = nil) {
        try? keychain.set(value, key: keychainKey(key: key, userIdentifier: userIdentifier))
    }

    private static func loadUserSession(email: String) -> UserSession? {
        // Get data that will be used to instantiate a new UserSession
        guard
            let refreshToken = getKeychainValue(key: KeychainKey.refreshToken, userIdentifier: email),
            let providerString = getKeychainValue(key: KeychainKey.provider, userIdentifier: email),
            let provider = AuthenticationProvider(providerString: providerString)
        else { return nil }
        // There userIdentifier might be nil if the provider = .email
        let ssoUserIdentifier = getKeychainValue(key: KeychainKey.ssoUserIdentifier, userIdentifier: email)
        let providerData = AuthenticationProviderData(provider: provider, email: email, userID: ssoUserIdentifier)
        let userSession = UserSession(refreshToken: refreshToken, providerData: providerData)
        if let deviceToken = getKeychainValue(key: KeychainKey.deviceToken, userIdentifier: email) {
            userSession.deviceToken = deviceToken
        }
        return userSession
    }

    // MARK: - Session Management
    /// Return a UserSession from the keychain.
    public class func previousUserSession() -> UserSession? {
        guard
            let keychainStoredEmail = getKeychainValue(key: KeychainKey.email),
            let session = loadUserSession(email: keychainStoredEmail)
        else { return nil }
        return session
    }

    static func saveSession(userSession: UserSession) {
        saveSessionInParts(
            session: userSession,
            email: true,
            refreshToken: true,
            providerData: true,
            deviceToken: true
        )
    }

    static func saveSessionInParts(session: UserSession, email: Bool, refreshToken: Bool, providerData: Bool, deviceToken: Bool) {
        let userIdentifier = session.email
        // Email
        if email {
            // set the last logged in email to the email in this userSession
            setKeychainValue(value: session.email, key: KeychainKey.email)
            // set the email of the userSession
            setKeychainValue(value: session.email, key: KeychainKey.email, userIdentifier: userIdentifier)
        }

        // Refresh token
        if refreshToken {
            setKeychainValue(value: session.refreshToken, key: KeychainKey.refreshToken, userIdentifier: userIdentifier)
        }

        // Provider data
        if providerData {
            setKeychainValue(value: session.providerData.provider.description, key: KeychainKey.provider, userIdentifier: userIdentifier)
            if let ssoUserID = session.providerData.userID {
                setKeychainValue(value: ssoUserID, key: KeychainKey.ssoUserIdentifier, userIdentifier: userIdentifier)
            }
        }

        // Device token
        if deviceToken, let token = session.deviceToken {
            setKeychainValue(value: token, key: KeychainKey.deviceToken, userIdentifier: userIdentifier)
        }
    }

    static func removeSession(userSession: UserSession) {
        // remove last logged in email
        try? keychain.remove(KeychainKey.email.rawValue)
        // remove user data
        for key in KeychainKey.allCases {
            try? keychain.remove(keychainKey(key: key, userIdentifier: userSession.email))
        }
    }

    static func removePreviousSessionIfNeeded() {
        guard let previousSession = previousUserSession() else { return }
        removeSession(userSession: previousSession)
    }
}
