//
//  ServicesCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ServicesCoordinator: TabbedCoordinator {

    // MARK: - Properties
    let navigationController: UINavigationController
    let servicesViewController: ServicesViewController
    let userSessionHandler: UserSessionHandler
    var notificationsCoordinator: NotificationsCoordinator?
    private var presentedServiceController: ServiceViewController?

    private var protectedApiManager: NotifireProtectedAPIManager {
        return servicesViewController.viewModel.protectedApiManager
    }

    // MARK: TabbedCoordinator
    var viewController: UIViewController {
        return navigationController
    }

    // MARK: - Initialization
    init(servicesNavigationController: UINavigationController, sessionHandler: UserSessionHandler) {
        self.userSessionHandler = sessionHandler
        self.navigationController = servicesNavigationController
        let servicesViewModel = ServicesViewModel(sessionHandler: sessionHandler)
        self.servicesViewController = ServicesViewController(viewModel: servicesViewModel)
        servicesViewController.delegate = self
    }

    func start() {
        navigationController.setViewControllers([servicesViewController], animated: false)
    }

    func showServiceCreation() {
        guard navigationController.presentedViewController == nil else { return }
        let serviceCreationVC = ServiceCreationViewController(viewModel: ServiceCreationViewModel(protectedApiManager: protectedApiManager))
        let serviceNavigation = NotifireActionNavigationController(rootViewController: serviceCreationVC)
        serviceCreationVC.delegate = self
        navigationController.present(serviceNavigation, animated: true, completion: nil)
    }

    func show(service: ServiceRepresentable) {
        let serviceViewModel = ServiceViewModel(service: service, sessionHandler: userSessionHandler)
        let serviceViewController = ServiceViewController(viewModel: serviceViewModel)
        serviceViewController.delegate = self
        presentedServiceController = serviceViewController
        navigationController.pushViewController(serviceViewController, animated: true)
    }

    func dismiss(service: LocalService) {
        guard let serviceViewController = presentedServiceController, navigationController.topViewController == serviceViewController else { return }
        navigationController.popViewController(animated: true)
    }

    func dismissServiceCreation(service: Service? = nil) {
        guard navigationController.presentedViewController != nil else { return }
        navigationController.dismiss(animated: true, completion: nil)
    }

    func showNotifications(service: LocalService) {
        let serviceNotificationsViewModel = ServiceNotificationsViewModel(realmProvider: userSessionHandler, service: service)
        let notificationsCoordinator = NotificationsCoordinator(navigationController: navigationController, notificationsViewModel: serviceNotificationsViewModel)
        notificationsCoordinator.start()
        self.notificationsCoordinator = notificationsCoordinator
    }
}

// MARK: - ServicesViewControllerDelegate
extension ServicesCoordinator: ServicesViewControllerDelegate {
    func didSelect(service: ServiceRepresentable) {
        show(service: service)
    }

    func didSelectCreateService() {
        showServiceCreation()
    }
}

extension ServicesCoordinator: ServiceViewControllerDelegate {
    func didDelete(service: LocalService) {
        dismiss(service: service)
    }

    func shouldShowNotifications(for service: LocalService) {
        showNotifications(service: service)
    }
}

// MARK: - ServiceCreationDelegate
extension ServicesCoordinator: ServiceCreationDelegate {
    func didCreate(service: Service) {
       dismissServiceCreation(service: service)
    }

    func didCancelCreation() {
        dismissServiceCreation()
    }
}
