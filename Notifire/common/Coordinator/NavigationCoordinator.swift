//
//  NavigationCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 03/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// Protocol representing a coordinator that contains a navigationController
protocol NavigatingCoordinator: Coordinator, UINavigationControllerDelegate {
    /// The main navigation controller
    var navigationController: UINavigationController { get }
    /// The child coordinators that this coordinator presented via push.
    var childCoordinators: [ChildCoordinator] { get set }
    var delegate: NavigationCoordinatorDelegate? { get }
}

/// A `ChildCoordinator` that allows pushing/popping from a parent navigationCoordinator.
protocol NavigatingChildCoordinator: ChildCoordinator {
    var parentNavigatingCoordinator: NavigatingCoordinator? { get set }
}

extension NavigatingCoordinator {
    /// Adds a child coordinator to the `childCoordinators` stack and starts it via `start()`
    /// - Parameters:
    ///     - childCoordinator: the child coordinator that will be added to the stack of childCoordinators and animated via push
    ///     - push: if the viewcontroller associated with the childCoordinator should be pushed immediately (animated)
    func add(childCoordinator: ChildCoordinator, push: Bool = false) {
        delegate?.willAddChild(coordinator: childCoordinator)
        // if the child to be added will require push/pop interaction with the navigation controller
        // set its parentNavigationCoordinator
        if let navigatingChildCoordinator = childCoordinator as? NavigatingChildCoordinator {
            navigatingChildCoordinator.parentNavigatingCoordinator = self
        }
        childCoordinators.append(childCoordinator)
        childCoordinator.start()
        guard push else { return }
        navigationController.pushViewController(childCoordinator.viewController, animated: true)
    }

    /// Removes a child coordinator from the coordinator hierarchy
    func childDidFinish(_ child: ChildCoordinator?, childIndex: Int? = nil) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === child {
            childCoordinators.remove(at: index)
            delegate?.didRemoveChild(coordinator: coordinator)
            break
        }
    }

    /// Removes the last coordinator that was added to the childCoordinator hierarchy.
    /// - Parameter animated: if the pop should be animated
    func removeLastCoordinator(animated: Bool = true) {
        navigationController.popViewController(animated: true)
    }

    /// Default implementation for `navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool)`
    /// Removes the childcoordinator object of the popped viewcontroller from the childCoordinators array.
    func navigationControllerDidShow(_ navigationController: UINavigationController, viewController: UIViewController, animated: Bool) {
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

/// Sublcass this class whenever a navigationCoordinator with a specified rootVC is needed.
class NavigationCoordinator<RootChildCoordinator: ChildCoordinator>: NSObject, NavigatingCoordinator, UINavigationControllerDelegate, ChildCoordinator {

    // MARK: - Properties
    var childCoordinators = [ChildCoordinator]()
    let navigationController: UINavigationController
    let rootChildCoordinator: RootChildCoordinator

    var rootViewController: UIViewController {
        return rootChildCoordinator.viewController
    }

    // MARK: Tabbed / ChildCoordinator
    var viewController: UIViewController {
        return navigationController
    }

    // MARK: Delegate
    weak var delegate: NavigationCoordinatorDelegate?

    // MARK: - Initialization
    init(rootChildCoordinator: RootChildCoordinator, navigationController: UINavigationController = UINavigationController()) {
        self.navigationController = navigationController
        self.rootChildCoordinator = rootChildCoordinator
    }

    // MARK: - Lifecycle
    /// - Important: If you are overriding this method, always call the parent method (`super.start()`) first.
    open func start() {
        navigationController.delegate = self
        navigationController.setViewControllers([rootViewController], animated: false)
        add(childCoordinator: rootChildCoordinator)
    }

    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        navigationControllerDidShow(navigationController, viewController: viewController, animated: animated)
    }
}
