//
//  Encodable+Dictionary.swift
//  Notifire
//
//  Created by David Bielik on 07/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension Encodable {
    /// Returns an optional dictionary from the given Encodable
    var asDictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
    }
}
