//
//  SessionCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class SessionCoordinator: Coordinator {

    // MARK: - Properties
    let tabBarViewController: TabBarViewController
    var activeCoordinator: TabbedCoordinator?
    var childCoordinators: [Tab: TabbedCoordinator] = [:]
    let userSessionHandler: UserSessionHandler

    // MARK: - Initialization
    init(tabBarViewController: TabBarViewController, sessionHandler: UserSessionHandler) {
        self.tabBarViewController = tabBarViewController
        self.userSessionHandler = sessionHandler
    }

    // MARK: - Coordination
    func start() {
        userSessionHandler.notifireProtectedApiManager.onRefreshTokenInvalidation = { [weak self] in
            guard let `self` = self else { return }
            self.userSessionHandler.exitUserSession(reason: .refreshTokenInvalidated)
        }
        tabBarViewController.delegate = self
        // the initial tab
        tabBarViewController.viewModel.updateTab(to: .services)
    }
}

// MARK: - TabBarViewControllerDelegate
extension SessionCoordinator: TabBarViewControllerDelegate {
    func didSelect(tab: Tab) {
        let selectedCoordinator: TabbedCoordinator
        if let existingChildCoordinator = childCoordinators[tab] {
            // coordinator instantiated previously
            selectedCoordinator = existingChildCoordinator
        } else {
            // create a new child coordinator
            let childCoordinator: TabbedCoordinator
            switch tab {
            case .notifications:
                let notificationsNavigationController = NotifireNavigationController()
                let notificationsViewModel = NotificationsViewModel(realmProvider: userSessionHandler)
                childCoordinator = NotificationsCoordinator(navigationController: notificationsNavigationController, notificationsViewModel: notificationsViewModel)
            case .services:
                let servicesNavigationController = NotifireNavigationController()
                servicesNavigationController.navigationBar.isTranslucent = false
                childCoordinator = ServicesCoordinator(servicesNavigationController: servicesNavigationController, sessionHandler: userSessionHandler)
            case .settings:
                let settingsViewController = SettingsViewController()
                settingsViewController.delegate = self
                childCoordinator = SettingsCoordinator(settingsViewController: settingsViewController)
            }
            childCoordinators[tab] = childCoordinator
            // and start it...
            childCoordinator.start()
            selectedCoordinator = childCoordinator
        }
        if let currentlyActiveCoordinator = activeCoordinator {
            let activeVC = currentlyActiveCoordinator.viewController
            tabBarViewController.remove(childViewController: activeVC)
        }
        activeCoordinator = selectedCoordinator
        let tabbedVC = selectedCoordinator.viewController
        tabBarViewController.add(childViewController: tabbedVC, superview: tabBarViewController.containerView)
        tabbedVC.view.translatesAutoresizingMaskIntoConstraints = false
        tabbedVC.view.leadingAnchor.constraint(equalTo: tabBarViewController.containerView.leadingAnchor).isActive = true
        tabbedVC.view.trailingAnchor.constraint(equalTo: tabBarViewController.containerView.trailingAnchor).isActive = true
        tabbedVC.view.topAnchor.constraint(equalTo: tabBarViewController.containerView.topAnchor).isActive = true
        tabbedVC.view.bottomAnchor.constraint(equalTo: tabBarViewController.containerView.bottomAnchor).isActive = true
    }

    func didReselect(tab: Tab) {
        guard let existingCoordinator = childCoordinators[tab], let navigator = existingCoordinator.viewController as? UINavigationController else { return }
        if let reselectable = navigator.topViewController as? Reselectable, reselectable.reselect() {
            return
        }
        navigator.popToRootViewController(animated: true)
    }
}

// MARK: SettingsViewControllerDelegate
extension SessionCoordinator: SettingsViewControllerDelegate {
    func didTapLogoutButton() {
        userSessionHandler.exitUserSession(reason: .userLoggedOut)
    }
}
