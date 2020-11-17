//
//  ServiceCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 13/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class ServiceCoordinator: ChildCoordinator, NavigatingChildCoordinator {

    // MARK: - Properties
    let serviceViewController: ServiceViewController

    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    var viewController: UIViewController {
        return serviceViewController
    }

    // MARK: - Initialization
    init(serviceViewController: ServiceViewController) {
        self.serviceViewController = serviceViewController
    }

    // MARK: - Methods
    func start() {

    }

    func showNotifications() {
        guard let localService = serviceViewController.viewModel.currentLocalService else {
            Logger.log(.info, "\(self) wanted to open notifications but currentLocalService is nil")
            return
        }
        let realmProvider = serviceViewController.viewModel.userSessionHandler
        let serviceNotificationsViewModel = ServiceNotificationsViewModel(realmProvider: realmProvider, service: localService)
        let notificationsCoordinator = NotificationsCoordinator(notificationsViewModel: serviceNotificationsViewModel)
        notificationsCoordinator.start()
    }
}
