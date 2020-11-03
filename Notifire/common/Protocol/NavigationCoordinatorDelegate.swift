//
//  NavigationCoordinatorDelegate.swift
//  Notifire
//
//  Created by David Bielik on 03/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

protocol NavigationCoordinatorDelegate: class {
    func willAddChild(coordinator: ChildCoordinator)
    func didRemoveChild(coordinator: ChildCoordinator)
}
