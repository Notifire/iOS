//
//  UserDefault.swift
//  Notifire
//
//  Created by David Bielik on 12/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

protocol UserDefaultsKey: RawRepresentable {
    var rawValue: String { get }
}

/// https://www.vadimbulavin.com/advanced-guide-to-userdefaults-in-swift/
// The marker protocol
protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Date: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}

// Every element must be a property-list type
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}

protocol UserDefaultSessionEditing {
    associatedtype Key: UserDefaultsKey
    var key: Key { get }
    /// The user identifier to prepend to the `key`. If no identifier is specified, only `key` is used while accessing the UserDefaults value.
    /// Note: Use `UserSession.email`
    var identifier: String? { get }
    var defaultsKey: String { get }
}

extension UserDefaultSessionEditing {
    var defaultsKey: String {
        if let identifier = identifier {
            return [identifier, key.rawValue].joined(separator: ".")
        } else {
            return key.rawValue
        }
    }

    /// `true` if the value is currently non-nil. Used to set the initial value.
    var isValueSet: Bool {
        return UserSessionManager.userDefaults.value(forKey: defaultsKey) != nil
    }
}

@propertyWrapper
struct UserDefault<T: PropertyListValue, Key: UserDefaultsKey>: UserDefaultSessionEditing {
    let key: Key
    var defaultValue: T?
    var identifier: String?

    var wrappedValue: T? {
        get { UserSessionManager.userDefaults.value(forKey: defaultsKey) as? T ?? defaultValue }
        set { UserSessionManager.userDefaults.set(newValue, forKey: defaultsKey) }
    }
}

@propertyWrapper
struct UserDefaultBool<Key: UserDefaultsKey>: UserDefaultSessionEditing {
    let key: Key
    var initialValue: Bool = false
    var negated: Bool = false
    var identifier: String?

    var wrappedValue: Bool {
        get {
            let result = UserSessionManager.userDefaults.bool(forKey: defaultsKey)
            return negated ? !result : result
        }
        set {
            UserSessionManager.userDefaults.set(negated ? !newValue : newValue, forKey: defaultsKey)
        }
    }
}

@propertyWrapper
struct UserDefaultInt<Key: UserDefaultsKey>: UserDefaultSessionEditing {
    let key: Key
    var initialValue: Int = 0
    var identifier: String?

    var wrappedValue: Int {
        get {
            return UserSessionManager.userDefaults.integer(forKey: defaultsKey)
        }
        set {
            UserSessionManager.userDefaults.set(newValue, forKey: defaultsKey)
        }
    }
}
