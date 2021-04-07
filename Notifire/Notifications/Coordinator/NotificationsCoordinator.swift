//
//  NotificationsCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotificationsCoordinator: NavigatingChildCoordinator, TabbedCoordinator, PresentingCoordinator {

    // MARK: - Properties
    let notificationsViewController: NotificationsViewController

    // MARK: TabbedCoordinator
    var viewController: UIViewController {
        return notificationsViewController
    }

    // MARK: NavigatingChildCoordinator
    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: PresentingCoordinator
    var presentedCoordinator: ChildCoordinator?
    var presentationDismissHandler: UIAdaptivePresentationDismissHandler?

    // MARK: - Initialization
    init(notificationsViewModel: NotificationsViewModel) {
        let notificationsViewController = NotificationsViewController(viewModel: notificationsViewModel)
        self.notificationsViewController = notificationsViewController
    }

    // MARK: - Coordinator
    func start() {
        notificationsViewController.delegate = self
        notificationsViewController.onFilterActionTapped = { [weak self] in
            self?.showNotificationFilters()
        }
    }

    // MARK: Notification Detail
    func showDetailed(notification: LocalNotifireNotification, animated: Bool) {
        let notificationDetailVC = createNotificationDetailVC(notification: notification)
        showDetailed(notificationDetailVC: notificationDetailVC, animated: animated)
    }

    func showDetailed(notificationDetailVC: NotificationDetailViewController, animated: Bool) {
        let notificationDetailCoordinator = GenericCoordinator(viewController: notificationDetailVC)
        if let prevNavigationItem = parentNavigatingCoordinator?.navigationController.navigationBar.topItem {
            notificationDetailVC.previousNavigationItem = prevNavigationItem
        }
        parentNavigatingCoordinator?.push(childCoordinator: notificationDetailCoordinator, animated: animated)
    }

    func createNotificationDetailVC(notification: LocalNotifireNotification, markAsRead: Bool = true) -> NotificationDetailViewController {
        let realmProvider = notificationsViewController.viewModel.realmProvider
        let showServiceUnreadCount = notificationsViewController.viewModel is ServiceNotificationsViewModel
        let notificationDetailVM = NotificationDetailViewModel(
            realmProvider: realmProvider,
            notification: notification,
            userSession: notificationsViewController.viewModel.userSession,
            serviceUnreadCount: showServiceUnreadCount,
            markAsRead: markAsRead
        )
        let notificationDetailVC = NotificationDetailViewController(viewModel: notificationDetailVM)
        notificationDetailVC.viewModel.delegate = self
        return notificationDetailVC
    }

    // MARK: Notification Filters
    func showNotificationFilters() {
        guard canPresentCoordinator else { return }
        let currentFilterData = notificationsViewController.viewModel.notificationsFilterData
        let filterVM = NotificationsFilterViewModel(filterData: currentFilterData)
        let filterVC = NotificationsFilterViewController(viewModel: filterVM)
        filterVC.onFinishedFiltering = { [weak self] maybeFilterData in
            if let newFilterData = maybeFilterData {
                self?.notificationsViewController.viewModel.set(notificationsFilterData: newFilterData)
            }
            self?.dismissPresentedCoordinator(animated: true)
        }
        let filterCoordinator = NotificationsFilterCoordinator(notificationsFilterViewController: filterVC)
        let navigationController = NotifireNavigationController()
        let childCoordinator = NavigationCoordinator(rootChildCoordinator: filterCoordinator, navigationController: navigationController)
        present(childCoordinator: childCoordinator, animated: true)
    }
}

extension NotificationsCoordinator: NotificationsViewControllerDelegate {
    func didSelect(notification: LocalNotifireNotification) {
        showDetailed(notification: notification, animated: true)
    }

    func getNotificationDetailVC(notification: LocalNotifireNotification) -> NotificationDetailViewController {
        // Don't mark the notification as read when we are using the preview.
        return createNotificationDetailVC(notification: notification, markAsRead: false)
    }
}

extension NotificationsCoordinator: NotificationDetailViewModelDelegate {
    func onNotificationDeletion() {
        if let topChildVC = parentNavigatingCoordinator?.topChildCoordinator?.viewController as? NotificationDetailViewController, topChildVC.viewIfLoaded?.window != nil {
            parentNavigatingCoordinator?.popChildCoordinator()
        }
    }
}
