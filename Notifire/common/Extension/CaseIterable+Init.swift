//
//  CaseIterable+Init.swift
//  Notifire
//
//  Created by David Bielik on 14/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension CaseIterable {

    /// Convenience init that enables any `CaseIterable` enum to be initialized from an Index (e.g. `Int`)
    init(from index: AllCases.Index) {
        self = Self.allCases[index]
    }
}
