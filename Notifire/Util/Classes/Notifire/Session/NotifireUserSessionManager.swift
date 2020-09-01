//
//  NotifireUserSessionManager.swift
//  Notifire
//
//  Created by David Bielik on 11/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import KeychainAccess

class NotifireUserSessionManager {

    private static let bundleID = "com.dvdblk.Notifire"
    private static let teamID = "6QH7E4QW2D"
    private static let keychainAccessGroup = "\(teamID).\(bundleID)"
    static let appGroupSuiteName = "group.\(bundleID)"
    static let appGroupSuiteNameWithTeamID = "\(teamID).\(appGroupSuiteName)"
    private struct Keys {
        private static let prefix = bundleID
        static let loggedInUsername = "\(prefix).logged-in-username"
        static let refreshToken = "\(prefix).refresh-token"
        static let deviceToken = "\(prefix).device-token"
        static let username = "\(prefix).username"
        static let firstLaunch = "\(prefix).notifire"
    }

    private lazy var keychain = Keychain(service: "com.dvdblk.Notifire", accessGroup: NotifireUserSessionManager.keychainAccessGroup)

    private func key(for username: String, key: String) -> String {
        return "\(username)\(key)"
    }

    private func loadSession(username: String) -> NotifireUserSession? {
        guard let maybeRefreshToken = try? keychain.getString(key(for: username, key: Keys.refreshToken)), let refreshToken = maybeRefreshToken else { return nil }
        let userSession = NotifireUserSession(refreshToken: refreshToken, username: username)
        if let deviceToken = try? keychain.getString(key(for: username, key: Keys.deviceToken)) {
            userSession.deviceToken = deviceToken
        }
        return userSession
    }

    // MARK: - Session Management
    func previousSession() -> NotifireUserSession? {
//        var isFirstLaunch = false
//        if let defaults = UserDefaults(suiteName: NotifireUserSessionManager.appGroupSuiteNameWithTeamID) {
//            if !defaults.bool(forKey: Keys.firstLaunch) {
//                defaults.set(true, forKey: Keys.firstLaunch)
//                isFirstLaunch = true
//            }
//        }
        guard let maybeUsername = try? keychain.getString(Keys.loggedInUsername), let username = maybeUsername,
        let session = loadSession(username: username) else { return nil }
//        if isFirstLaunch {
//            removeSession(userSession: session)
//            return nil
//        }
        return session
    }

    func set(userSession: NotifireUserSession, deviceToken: String) {
        userSession.deviceToken = deviceToken
        try? keychain.set(deviceToken, key: key(for: userSession.username, key: Keys.deviceToken))
    }

    func saveSession(userSession: NotifireUserSession) {
        try? keychain.set(userSession.username, key: Keys.loggedInUsername)
        try? keychain.set(userSession.username, key: key(for: userSession.username, key: Keys.username))
        try? keychain.set(userSession.refreshToken, key: key(for: userSession.username, key: Keys.refreshToken))
        if let deviceToken = userSession.deviceToken {
            try? keychain.set(deviceToken, key: key(for: userSession.username, key: Keys.deviceToken))
        }
    }

    func removeSession(userSession: NotifireUserSession) {
        try? keychain.remove(Keys.loggedInUsername)
        for key in [Keys.refreshToken, Keys.deviceToken, Keys.username] {
            try? keychain.remove(self.key(for: userSession.username, key: key))
        }
    }
}
