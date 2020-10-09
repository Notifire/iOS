//
//  CATransaction+Animation.swift
//  Notifire
//
//  Created by David Bielik on 03/10/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension CATransaction {
    class func withDisabledActions<T>(_ body: () throws -> T) rethrows -> T {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer {
            CATransaction.commit()
        }
        return try body()
    }
}
