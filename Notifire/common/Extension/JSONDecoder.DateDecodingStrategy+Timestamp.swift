//
//  JSONDecoder.DateDecodingStrategy+Timestamp.swift
//  Notifire
//
//  Created by David Bielik on 23/12/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static var timestampStrategy: Self {
        return .custom({ decoder -> Date in
            let dateDouble = try decoder.singleValueContainer().decode(Double.self)
            return Date(timeIntervalSince1970: dateDouble)
        })
    }
}
