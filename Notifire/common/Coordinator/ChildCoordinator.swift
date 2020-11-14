//
//  ChildCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 02/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Describes Coordinators that will be presented or embedded into a parent Coordinator.
protocol ChildCoordinator: Coordinator {
    /// The `UIViewController` that will get presented by a parent Coordinator.
    var viewController: UIViewController { get }
}
