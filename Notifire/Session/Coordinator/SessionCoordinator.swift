//
//  SessionCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class SessionCoordinator: SectioningCoordinator {

    typealias SectionDefiningEnum = Tab

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

    // MARK: - SectioningCoordinator
    var containerViewController: (UIViewController & ChildViewControllerContainerProviding) {
        return tabBarViewController
    }

    func createChildCoordinatorFrom(section: Tab) -> SectionedCoordinator {
        let childCoordinator: ChildCoordinator
        let navigationController = NotifireNavigationController()
        switch section {
        case .notifications:
            let notificationsViewModel = NotificationsViewModel(realmProvider: userSessionHandler, userSession: userSessionHandler.userSession)
            let notificationsCoordinator = NotificationsCoordinator(notificationsViewModel: notificationsViewModel)
            childCoordinator = NavigationCoordinator(rootChildCoordinator: notificationsCoordinator, navigationController: navigationController)
        case .services:
            navigationController.navigationBar.isTranslucent = false
            let servicesCoordinator = ServicesCoordinator(sessionHandler: userSessionHandler)
            let navigationCoordinator = NavigationCoordinator(rootChildCoordinator: servicesCoordinator, navigationController: navigationController)
            childCoordinator = navigationCoordinator
        case .settings:
            let settingsViewModel = SettingsViewModel(sessionHandler: userSessionHandler)
            let settingsViewController = SettingsViewController(viewModel: settingsViewModel)
            let settingsCoordinator = SettingsCoordinator(settingsViewController: settingsViewController)
            childCoordinator = NavigationCoordinator(rootChildCoordinator: settingsCoordinator, navigationController: navigationController)
        }
        return childCoordinator
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

        tabBarViewController.viewModel.onShouldPresentNotificationRequirement = { [weak self] in
            self?.presentNotificationRequirementsVC()
        }
    }

    func presentNotificationRequirementsVC() {
        let viewModel = NotificationsRequirementViewModel(deviceTokenManager: userSessionHandler.deviceTokenManager)
        viewModel.onSuccess = { [weak self] in
            self?.tabBarViewController.dismiss(animated: true) { [weak self] in
                self?.tabBarViewController.viewModel.notificationPermissionPrompt?.finish()
            }
        }
        let viewController = NotificationsRequirementViewController(viewModel: viewModel)
        if #available(iOS 13.0, *) {
            viewController.isModalInPresentation = true
        }
        tabBarViewController.present(viewController, animated: true, completion: nil)
    }
}

// MARK: - TabBarViewControllerDelegate
extension SessionCoordinator: TabBarViewControllerDelegate {
    func didSelect(tab: Tab) {
        changeSection(to: tab)
    }

    func didReselect(tab: Tab, animated: Bool) {
        guard
            let childCoordinator = childCoordinators[tab],
            let reselectableViewController = childCoordinator.viewController as? Reselectable,
            !reselectableViewController.reselect(animated: animated)
        else { return }
        reselectableViewController.reselectChildViewControllers(animated: animated)
    }
}
