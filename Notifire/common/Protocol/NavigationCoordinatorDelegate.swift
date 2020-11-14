//
//  NavigationCoordinatorDelegate.swift
//  Notifire
//
//  Created by David Bielik on 03/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

protocol NavigationCoordinatorDelegate: class {
    /// Called before a `childCoordinator` is added to the childCoordinators property
    func willAddChild(coordinator: ChildCoordinator)
    /// Called when a `childCoordinator` is added to the childCoordinators property
    /// - Parameters:
    ///     - coordinator: the coordinator that was added
    ///     - pushed: boolean value indicating if the viewController was also pushed to the navigationController stack.
    func didAddChild(coordinator: ChildCoordinator, pushed: Bool)
    /// Called when a `childCoordinator` is removed from the childCoordinators property
    func didRemoveChild(coordinator: ChildCoordinator)
}

extension NavigationCoordinatorDelegate {
    func didAddChild(coordinator: ChildCoordinator, pushed: Bool) {}
    func willAddChild(coordinator: ChildCoordinator) {}
    func didRemoveChild(coordinator: ChildCoordinator) {}
}
