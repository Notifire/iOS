//
//  CGSize+Equal.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension CGSize {

    /// Convenience initializer that initializes the size with the same CGFloat for each side.
    init(equal: CGFloat) {
        self.init(width: equal, height: equal)
    }
}
