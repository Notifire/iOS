//
//  IndexPath+RowInit.swift
//  Notifire
//
//  Created by David Bielik on 27/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

extension IndexPath {
    init(row: Int) {
        self.init(row: row, section: 0)
    }
}

extension Int {
    var asIndexPath: IndexPath {
        return IndexPath(row: self)
    }
}
