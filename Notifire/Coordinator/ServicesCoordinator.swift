//
//  ServicesCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ServicesCoordinator: NavigatingChildCoordinator {

    // MARK: - Properties
    let servicesViewController: ServicesViewController
    let userSessionHandler: UserSessionHandler

    private var presentedServiceController: ServiceViewController?

    private var protectedApiManager: NotifireProtectedAPIManager {
        return servicesViewController.viewModel.protectedApiManager
    }

    // MARK: ChildCoordinator
    var viewController: UIViewController {
        return servicesViewController
    }

    // MARK: NavigatingChildCoordinator
    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: - Initialization
    init(sessionHandler: UserSessionHandler) {
        self.userSessionHandler = sessionHandler
        let servicesViewModel = ServicesViewModel(sessionHandler: sessionHandler)
        self.servicesViewController = ServicesViewController(viewModel: servicesViewModel)
    }

    func start() {
        servicesViewController.delegate = self
    }

    func showServiceCreation() {
        let serviceCreationVC = ServiceCreationViewController(viewModel: ServiceCreationViewModel(protectedApiManager: protectedApiManager))
        let serviceNavigation = NotifireActionNavigationController(rootViewController: serviceCreationVC)
        serviceCreationVC.delegate = self
        servicesViewController.present(serviceNavigation, animated: true, completion: nil)
    }

    func show(service: ServiceRepresentable) {
        let serviceViewModel = ServiceViewModel(service: service, sessionHandler: userSessionHandler)
        let serviceViewController = ServiceViewController(viewModel: serviceViewModel)
        serviceViewController.delegate = self
        presentedServiceController = serviceViewController
        let serviceCoordinator = ServiceCoordinator(serviceViewController: serviceViewController)
        parentNavigatingCoordinator?.add(childCoordinator: serviceCoordinator, push: true)
    }

    func dismiss(serviceRepresentable: ServiceRepresentable) {
        guard
            let serviceViewController = presentedServiceController,
            serviceViewController.viewModel.serviceRepresentable.isEqualTo(other: serviceRepresentable)
        else { return }
        parentNavigatingCoordinator?.popChildCoordinator(animated: true)
    }

    func dismissServiceCreation(service: Service? = nil) {
        servicesViewController.dismiss(animated: true, completion: nil)
    }

    func showNotifications(service: LocalService) {
        let serviceNotificationsViewModel = ServiceNotificationsViewModel(realmProvider: userSessionHandler, service: service)
        let notificationsCoordinator = NotificationsCoordinator(notificationsViewModel: serviceNotificationsViewModel)
        parentNavigatingCoordinator?.add(childCoordinator: notificationsCoordinator)
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
        // FIXME: Add ServiceRepresentable instead of LocalService here
        //dismiss(service: service)
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

extension ServicesCoordinator: NavigationCoordinatorDelegate {
    func didRemoveChild(coordinator: ChildCoordinator) {
        guard
            coordinator.viewController === presentedServiceController,
            let dismissedLocalService = presentedServiceController?.viewModel.currentLocalService else
        {
            presentedServiceController = nil
            return
        }
        presentedServiceController = nil
        servicesViewController.viewModel.updateSnippet(to: dismissedLocalService)
    }
}
