//
//  Config.swift
//  Notifire
//
//  Created by David Bielik on 23/02/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class Config {

    // MARK: - Private
    /// Error that can be thrown while accessing the config values
    enum Error: Swift.Error {
        case missingKey, invalidValue
    }

    /// Enumeration of possible Info.plist values that this struct is accessing.
    /// - Tag: Config.BundleKey
    private enum BundleKey: String {
        case appName = "CFBundleName"
        case appVersion = "CFBundleShortVersionString"
        case buildNumber = "CFBundleVersion"
        case apiUrl = "API_URL"
        case wsURL = "WS_URL"
    }

    /// Access the value for a specific [BundleKey](x-source-tag://Config.BundleKey)
    private static func value<T>(for key: BundleKey) throws -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key.rawValue) else {
            throw Error.missingKey
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            throw Error.invalidValue
        }
    }

    // MARK: - Public
    // swiftlint:disable force_try
    /// The Application Name
    static let appName: String = try! value(for: .appName)
    /// The Application Version
    static let appVersion: String = try! value(for: .appVersion)
    /// The Build Number
    static let buildNumber: String = try! value(for: .buildNumber)
    // The API URL
    static let apiUrlString: String = try! value(for: .apiUrl)
    // The WS URL
    static let wsUrlString: String = try! value(for: .wsURL)
    // Privacy Policy URL
    static let privacyPolicyURL = URL(string: "https://notifire.dvdblk.com/privacypolicy")!
    // swiftlint:enable force_try
    static let bundleID: String = Bundle.main.bundleIdentifier!
}
