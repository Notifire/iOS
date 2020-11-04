//
//  GenericCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// A generic coordinator class that is used for UIViewControllers that require having a coordinator for some interaction with other coordinators.
class GenericCoordinator<ViewController: UIViewController>: ChildCoordinator {

    let rootViewController: ViewController

    var viewController: UIViewController {
        return rootViewController
    }

    init(viewController: ViewController) {
        self.rootViewController = viewController
    }

    func start() {

    }
}
