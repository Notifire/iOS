//
//  NavigationCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class NavigationCoordinator<RootVC: UIViewController>: NSObject, Coordinator, UINavigationControllerDelegate {

    // MARK: - Properties
    var childCoordinators = [ChildCoordinator]()
    let navigationController: UINavigationController
    let rootViewController: RootVC

    private let rootChildCoordinator: ChildCoordinator

    // MARK: - Initialization
    init(rootChildViewController: RootVC, navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        self.rootViewController = rootChildViewController
        self.rootChildCoordinator = GenericCoordinator(viewController: rootViewController)
    }

    // MARK: - Lifecycle
    /// - Important: If you are overriding this method, always call the parent one first.
    open func start() {
        navigationController.delegate = self
        navigationController.setViewControllers([rootViewController], animated: false)
        add(childCoordinator: rootChildCoordinator)
    }

    /// Adds a child coordinator to the `childCoordinators` stack and starts it via `start()`
    func add(childCoordinator: ChildCoordinator, push: Bool = false) {
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
        guard push else { return }
        navigationController.pushViewController(childCoordinator.viewController, animated: true)
    }

    /// Removes a child coordinator from the coordinator hierarchy
    func childDidFinish(_ child: Coordinator?, childIndex: Int? = nil) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
            break
        }
    }

    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // Get the from view controller
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        // Guard that the navigation view controller hierarchy doesn't contain the fromViewController
        guard !navigationController.viewControllers.contains(fromViewController) else { return }

        for childCoordinator in childCoordinators where childCoordinator.viewController === fromViewController {
            childDidFinish(childCoordinator)
            break
        }
    }
}
