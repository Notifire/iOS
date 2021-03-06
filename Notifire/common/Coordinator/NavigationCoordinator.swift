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
    /// The child coordinators that this coordinator is currently presenting.
    var childCoordinators: [ChildCoordinator] { get set }
    var delegate: NavigationCoordinatorDelegate? { get }
    /// The child coordinator of the `topViewController`
    var topChildCoordinator: ChildCoordinator? { get }
}

/// A `ChildCoordinator` that allows pushing/popping from a parent navigationCoordinator.
protocol NavigatingChildCoordinator: ChildCoordinator {
    var parentNavigatingCoordinator: NavigatingCoordinator? { get set }
}

extension NavigatingCoordinator {
    var topChildCoordinator: ChildCoordinator? {
        return childCoordinators.last
    }

    /// Adds a child coordinator to the `childCoordinators` stack and starts it via `start()`
    /// - Parameters:
    ///     - childCoordinator: the child coordinator that will be added to the stack of childCoordinators
    func add(childCoordinator: ChildCoordinator) {
        // Check if the childCoordinator is not already present in the childCoordinators array
        guard !childCoordinators.contains(where: { $0 === childCoordinator }) else { return }

        delegate?.willAddChild(coordinator: childCoordinator)
        // if the child to be added will require push/pop interaction with the navigation controller
        // set its parentNavigationCoordinator
        if let navigatingChildCoordinator = childCoordinator as? NavigatingChildCoordinator {
            navigatingChildCoordinator.parentNavigatingCoordinator = self
        }
        childCoordinators.append(childCoordinator)
        childCoordinator.start()

        // call the didAddChild delegate method
        delegate?.didAddChild(coordinator: childCoordinator)
    }

    /// Add a new childCoordinator to the childCoordinators array and push its `ChildCoordinator.viewController` to the navigation stack.
    /// - Parameter animated: whether the `pushViewController` should be animated. Default value is `true`.
    func push(childCoordinator: ChildCoordinator, animated: Bool = true) {
        // Add the child first
        add(childCoordinator: childCoordinator)
        // Push it to the navigationHierarchy stack
        navigationController.pushViewController(childCoordinator.viewController, animated: animated)
        // Triggers viewDidLoad on the pushed VC in case there are multiple pushes
        if !animated {
            _ = childCoordinator.viewController.view
        }
    }

    /// Removes the last coordinator that was added to the childCoordinator hierarchy.
    /// - Parameter animated: if the pop should be animated. Default value is `true`.
    func popChildCoordinator(animated: Bool = true) {
        guard childCoordinators.count > 1, let lastChildCoordinator = childCoordinators.last else {
            Logger.log(.default, "\(self) attempted to pop a child coordinator when only the root coordinator is presented.")
            return
        }
        navigationController.popViewController(animated: animated) { [weak self] in
            guard let `self` = self else { return }
            // Remove the childCoordinator from the array
            self.childCoordinators = self.childCoordinators.filter({ $0.viewController != lastChildCoordinator.viewController })
        }
    }

    /// Pops all childCoordinators except for the root one.
    /// - Parameter animated: if the pop should be animated. Default value is `true`.
    func popToRootCoordinator(animated: Bool = true) {
        guard childCoordinators.count > 1, let rootCoordinator = childCoordinators.first else {
            Logger.log(.default, "\(self) attempted to pop to root coordinator while it is already presenting only the root coordinator.")
            return
        }
        navigationController.popToRootViewController(animated: animated) { [weak self] in
            self?.childCoordinators = [rootCoordinator]
        }
    }

    /// Default implementation for `navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool)`
    /// Removes the childcoordinator object of the popped viewcontroller from the childCoordinators array.
    func navigationControllerDidShow(_ navigationController: UINavigationController, viewController: UIViewController, animated: Bool) {
        // Get the from view controller
        guard let fromViewController = navigationController.transitionCoordinator?.viewController(forKey: .from) else { return }
        // Guard that the navigation view controller hierarchy doesn't contain the fromViewController
        guard !navigationController.viewControllers.contains(fromViewController) else { return }

        // Find the first childCoordinator that coordinates fromViewController
        for (index, childCoordinator) in childCoordinators.enumerated() where childCoordinator.viewController === fromViewController {
            // childDidFinish
            childCoordinators.remove(at: index)
            delegate?.didRemoveChild(coordinator: childCoordinator)
            break
        }
    }
}

/// Sublcass this class whenever a navigationCoordinator with a specified rootVC is needed.
class NavigationCoordinator<RootChildCoordinator: ChildCoordinator>: NSObject, NavigatingCoordinator, UINavigationControllerDelegate, ChildCoordinator {

    // MARK: - Properties
    let navigationController: UINavigationController
    let rootChildCoordinator: RootChildCoordinator

    /// Array of childCoordinators that are currently pushed on the navigation stack.
    var childCoordinators = [ChildCoordinator]()

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
        super.init()
        if let reselectableNavigation = navigationController as? NavigationReselectable {
            reselectableNavigation.navigatingCoordinator = self
        }
    }

    // MARK: - Lifecycle
    /// - Important: If you are overriding this method, always call the parent method (`super.start()`) first.
    open func start() {
        // Set the UINavigationControllerDelegate
        navigationController.delegate = self
        // Add root child coordinator
        add(childCoordinator: rootChildCoordinator)
        // Set the rootVC for the navigationContoller
        navigationController.setViewControllers([rootViewController], animated: false)
    }

    // MARK: - UINavigationControllerDelegate
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        navigationControllerDidShow(navigationController, viewController: viewController, animated: animated)
    }
}
