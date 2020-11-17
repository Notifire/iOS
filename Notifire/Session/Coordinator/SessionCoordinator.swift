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
        switch section {
        case .notifications:
            let notificationsNavigationController = NotifireNavigationController()
            let notificationsViewModel = NotificationsViewModel(realmProvider: userSessionHandler)
            let notificationsCoordinator = NotificationsCoordinator(notificationsViewModel: notificationsViewModel)
            childCoordinator = NavigationCoordinator(rootChildCoordinator: notificationsCoordinator, navigationController: notificationsNavigationController)
        case .services:
            let servicesNavigationController = NotifireNavigationController()
            servicesNavigationController.navigationBar.isTranslucent = false
            let servicesCoordinator = ServicesCoordinator(sessionHandler: userSessionHandler)
            let navigationCoordinator = NavigationCoordinator(rootChildCoordinator: servicesCoordinator, navigationController: servicesNavigationController)
            navigationCoordinator.delegate = servicesCoordinator
            childCoordinator = navigationCoordinator
        case .settings:
            let settingsNavigationController = NotifireNavigationController()
            let settingsViewModel = SettingsViewModel(sessionHandler: userSessionHandler)
            let settingsViewController = SettingsViewController(viewModel: settingsViewModel)
            let settingsCoordinator = SettingsCoordinator(settingsViewController: settingsViewController)
            childCoordinator = NavigationCoordinator(rootChildCoordinator: settingsCoordinator, navigationController: settingsNavigationController)
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
    }
}

// MARK: - TabBarViewControllerDelegate
extension SessionCoordinator: TabBarViewControllerDelegate {
    func didSelect(tab: Tab) {
        changeSection(to: tab)
    }

    func didReselect(tab: Tab) {
        guard
            let childCoordinator = childCoordinators[tab],
            let reselectableViewController = childCoordinator.viewController as? Reselectable,
            !reselectableViewController.reselect()
        else { return }
        reselectableViewController.reselectChildViewControllers()
    }
}