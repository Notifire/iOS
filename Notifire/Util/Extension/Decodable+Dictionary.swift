//
//  Decodable+Dictionary.swift
//  Notifire
//
//  Created by David Bielik on 07/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension Decodable {
    /// Decode the dictionary into the specified Type
    static func decodeDictionary<T: Decodable>(to type: T.Type, from data: Any) -> T? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: data, options: []),
            let result = try? JSONDecoder().decode(type, from: data)
        else { return nil }
        return result
    }
}
