//
//  NotificationsCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotificationsCoordinator: TabbedCoordinator {

    // MARK: - Properties
    let notificationsViewController: NotificationsViewController
    let navigationController: UINavigationController
    let realmProvider: RealmProviding
    // MARK: TabbedCoordinator
    var viewController: UIViewController {
        return navigationController
    }

    // MARK: - Initialization
    init(navigationController: UINavigationController, notificationsViewModel: NotificationsViewModel) {
        self.navigationController = navigationController
        self.realmProvider = notificationsViewModel.realmProvider
        let notificationsViewController = NotificationsViewController(viewModel: notificationsViewModel)
        self.notificationsViewController = notificationsViewController
        notificationsViewController.delegate = self
    }

    func start() {
        guard navigationController.viewControllers.isEmpty else {
            navigationController.pushViewController(notificationsViewController, animated: true)
            return
        }
        // first VC
        navigationController.setViewControllers([notificationsViewController], animated: false)
    }

    func showDetailed(notification: LocalNotifireNotification) {
        let notificationDetailVM = NotificationDetailViewModel(realmProvider: realmProvider, notification: notification)
        let notificationDetailVC = NotificationDetailViewController(viewModel: notificationDetailVM)
        notificationDetailVC.view.backgroundColor = .backgroundColor
        notificationDetailVC.viewModel.delegate = self
        navigationController.pushViewController(notificationDetailVC, animated: true)
    }
}

extension NotificationsCoordinator: NotificationsViewControllerDelegate {
    func didSelect(notification: LocalNotifireNotification) {
        showDetailed(notification: notification)
    }
}

extension NotificationsCoordinator: NotificationDetailViewModelDelegate {
    func onNotificationDeletion() {
        navigationController.popToRootViewController(animated: true)
    }
}
