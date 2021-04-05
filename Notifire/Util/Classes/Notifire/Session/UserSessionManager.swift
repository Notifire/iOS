//
//  UserSessionManager.swift
//  Notifire
//
//  Created by David Bielik on 11/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import KeychainAccess
import SDWebImage

class UserSessionManager {

    // MARK: - Properties
    private static let teamID = "6QH7E4QW2D"
    private static let keychainAccessGroup = "\(teamID).\(Config.productBundleID)"
    static let appGroupSuiteName = "group.\(Config.productBundleID)"
    static let appGroupSuiteNameWithTeamID = "\(teamID).\(appGroupSuiteName)"

    /// Shared user defaults for the app and the extensions
    static let userDefaults = UserDefaults(suiteName: appGroupSuiteName) ?? UserDefaults.standard

    /// Enumeration describing the keys used by the keychain
    /// Note: User specific
    enum KeychainKey: String, CaseIterable {
        /// The user ID of the last logged in user. Used to automatically log in the previous user / load the previous `UserSession`
        case lastUserID

        // The rest of these are specific to the previous user session
        case email
        case refreshToken
        case deviceToken
        case ssoUserIdentifier
        case provider
    }

    private static var keychain = Keychain(service: "userData", accessGroup: keychainAccessGroup)

    // MARK: - Methods
    private static func keychainKey(key: KeychainKey, userIdentifier: Int? = nil) -> String {
        let keychainKey: [String]
        if let identifier = userIdentifier {
            // the value is specific for some user
            let keychainUserIdentifier = "user\(identifier)"
            keychainKey = [Config.productBundleID, keychainUserIdentifier, key.rawValue]
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
    private static func getKeychainValue(key: KeychainKey, userIdentifier: Int? = nil) -> String? {
        return try? keychain.getString(
            keychainKey(key: key, userIdentifier: userIdentifier)
        )
    }

    private static func setKeychainValue(value: String, key: KeychainKey, userIdentifier: Int? = nil) {
        try? keychain.set(value, key: keychainKey(key: key, userIdentifier: userIdentifier))
    }

    private static func loadUserSession(userID: Int) -> UserSession? {
        // Get data that will be used to instantiate a new UserSession
        guard
            let email = getKeychainValue(key: KeychainKey.email, userIdentifier: userID),
            let refreshToken = getKeychainValue(key: KeychainKey.refreshToken, userIdentifier: userID),
            let providerString = getKeychainValue(key: KeychainKey.provider, userIdentifier: userID),
            let provider = AuthenticationProvider(providerString: providerString)
        else { return nil }
        // There userIdentifier might be nil if the provider = .email
        let ssoUserIdentifier = getKeychainValue(key: KeychainKey.ssoUserIdentifier, userIdentifier: userID)
        let providerData = AuthenticationProviderData(provider: provider, email: email, userID: ssoUserIdentifier)
        let userSession = UserSession(userID: userID, refreshToken: refreshToken, providerData: providerData)
        if let deviceToken = getKeychainValue(key: KeychainKey.deviceToken, userIdentifier: userID) {
            userSession.deviceToken = deviceToken
        }
        return userSession
    }

    // MARK: - Session Management
    /// Return a UserSession from the keychain.
    public class func previousUserSession() -> UserSession? {
        guard
            let keychainStoredUserIDString = getKeychainValue(key: KeychainKey.lastUserID),
            let keychainStoredUserID = Int(keychainStoredUserIDString),
            let session = loadUserSession(userID: keychainStoredUserID)
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
        let userIdentifier = session.userID

        // Save the last logged in userID to the lastUserID key
        setKeychainValue(value: String(session.userID), key: .lastUserID)

        // Email
        if email {
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
        try? keychain.remove(KeychainKey.lastUserID.rawValue)
        // remove user data
        for key in KeychainKey.allCases {
            try? keychain.remove(keychainKey(key: key, userIdentifier: userSession.userID))
        }
    }

    static func removePreviousSessionIfNeeded() {
        guard let previousSession = previousUserSession() else { return }
        removeSession(userSession: previousSession)
    }
}

// MARK: - Image Cache
extension UserSessionManager {
    static func createImageCache(from userSession: UserSession) -> SDImageCache? {
        guard let imageCacheDirectoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: UserSessionManager.appGroupSuiteName)?.appendingPathComponent("images") else { return nil }
        if !FileManager.default.fileExists(atPath: imageCacheDirectoryURL.path) {
            do {
                try FileManager.default.createDirectory(atPath: imageCacheDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                Logger.log(.error, "UserSessionManager create directory error <\(error.localizedDescription)>")
            }
        }
        return SDImageCache(namespace: String(userSession.userID), diskCacheDirectory: imageCacheDirectoryURL.path)
    }
}
