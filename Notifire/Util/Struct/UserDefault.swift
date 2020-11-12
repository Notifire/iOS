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

@propertyWrapper
struct UserDefault<T: PropertyListValue, Key: UserDefaultsKey> {
    let key: Key
    let defaultValue: T? = nil
    /// The user identifier to prepend to the `key`. If no identifier is specified, only `key` is used while accessing the UserDefaults value.
    /// Note: Use `UserSession.email`
    var identifier: String?

    var wrappedValue: T? {
        get { UserDefaults.standard.value(forKey: defaultsKey) as? T ?? defaultValue }
        set { UserDefaults.standard.set(newValue, forKey: defaultsKey) }
    }

    private var defaultsKey: String {
        if let identifier = identifier {
            return [identifier, key.rawValue].joined(separator: ".")
        } else {
            return key.rawValue
        }
    }
}
