//
//  NotificationsCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotificationsCoordinator: NavigatingChildCoordinator, TabbedCoordinator {

    // MARK: - Properties
    let notificationsViewController: NotificationsViewController

    // MARK: TabbedCoordinator
    var viewController: UIViewController {
        return notificationsViewController
    }

    // MARK: NavigatingChildCoordinator
    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: - Initialization
    init(notificationsViewModel: NotificationsViewModel) {
        let notificationsViewController = NotificationsViewController(viewModel: notificationsViewModel)
        self.notificationsViewController = notificationsViewController
    }

    func start() {
        notificationsViewController.delegate = self
    }

    func showDetailed(notification: LocalNotifireNotification, animated: Bool) {
        let realmProvider = notificationsViewController.viewModel.realmProvider
        let notificationDetailVM = NotificationDetailViewModel(realmProvider: realmProvider, notification: notification)
        let notificationDetailVC = NotificationDetailViewController(viewModel: notificationDetailVM)
        notificationDetailVC.view.backgroundColor = .compatibleSystemBackground
        notificationDetailVC.viewModel.delegate = self
        let notificationDetailCoordinator = GenericCoordinator(viewController: notificationDetailVC)
        parentNavigatingCoordinator?.push(childCoordinator: notificationDetailCoordinator, animated: animated)
    }
}

extension NotificationsCoordinator: NotificationsViewControllerDelegate {
    func didSelect(notification: LocalNotifireNotification) {
        showDetailed(notification: notification, animated: true)
    }
}

extension NotificationsCoordinator: NotificationDetailViewModelDelegate {
    func onNotificationDeletion() {
        parentNavigatingCoordinator?.popChildCoordinator()
    }
}
