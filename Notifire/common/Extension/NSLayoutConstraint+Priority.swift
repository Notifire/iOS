//
//  NSLayoutConstraint+Priority.swift
//  Notifire
//
//  Created by David Bielik on 19/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {

    /// Return the constraint with a new priority value.
    func with(priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
