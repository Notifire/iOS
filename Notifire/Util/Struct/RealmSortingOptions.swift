//
//  RealmSortingOptions.swift
//  Notifire
//
//  Created by David Bielik on 25/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

struct RealmSortingOptions {

    // MARK: - Order
    enum SortOrder: Equatable {
        case ascending, descending
    }

    // MARK: - Properties
    let keyPath: String
    let order: SortOrder

    // MARK: Computed
    var ascending: Bool {
        return order == .ascending
    }
}
