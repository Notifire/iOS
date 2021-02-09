//
//  Reselectable.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Conforming classes to this protocol are able to be "reselected" on the TabBar. Behavior of reselection is class specific.
protocol Reselectable: UIViewController {
    typealias ReselectHandled = Bool

    /// - returns: `true` if the class handled the reselection, `false` otherwise
    func reselect(animated: Bool) -> ReselectHandled
}

extension Reselectable {
    func reselect(animated: Bool) -> ReselectHandled {
        return reselectChildViewControllers(animated: animated)
    }

    @discardableResult
    /// Reselects all the childviewcontrollers that are also `Reselectable`
    /// - returns: `true` if any of the Reselectable child VCs got reselected, `false` otherwise
    func reselectChildViewControllers(animated: Bool) -> ReselectHandled {
        for childVC in children {
            guard let reselectableVC = childVC as? Reselectable, reselectableVC.reselect(animated: animated) else { continue }
            return true
        }
        return false
    }
}
