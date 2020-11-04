//
//  ServicesCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
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

/// A `ChildCoordinator` that allows pushing/popping from a parent navigationCoordinator.
protocol NavigatingChildCoordinator: ChildCoordinator {
    var parentNavigatingCoordinator: NavigatingCoordinator? { get set }
}

class ServicesCoordinator: NavigationCoordinator<GenericCoordinator<ServicesViewController>> {

    // MARK: - Properties
    var servicesViewController: ServicesViewController {
        return rootChildCoordinator.rootViewController
    }

    let userSessionHandler: UserSessionHandler

    private var presentedServiceController: ServiceViewController?

    private var protectedApiManager: NotifireProtectedAPIManager {
        return servicesViewController.viewModel.protectedApiManager
    }

    // MARK: - Initialization
    init(servicesNavigationController: UINavigationController, sessionHandler: UserSessionHandler) {
        self.userSessionHandler = sessionHandler
        let servicesViewModel = ServicesViewModel(sessionHandler: sessionHandler)
        let rootVC = ServicesViewController(viewModel: servicesViewModel)
        super.init(rootChildCoordinator: GenericCoordinator(viewController: rootVC), navigationController: servicesNavigationController)
    }

    override func start() {
        super.start()
        delegate = self
        servicesViewController.delegate = self
    }

    func showServiceCreation() {
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
        let serviceCoordinator = ServiceCoordinator(serviceViewController: serviceViewController)
        add(childCoordinator: serviceCoordinator, push: true)
    }

    func dismiss(service: LocalService) {
        guard let serviceViewController = presentedServiceController, navigationController.topViewController == serviceViewController else { return }
        navigationController.popViewController(animated: true)
    }

    func dismissServiceCreation(service: Service? = nil) {
        navigationController.dismiss(animated: true, completion: nil)
    }

    func showNotifications(service: LocalService) {
        let serviceNotificationsViewModel = ServiceNotificationsViewModel(realmProvider: userSessionHandler, service: service)
        let notificationsCoordinator = NotificationsCoordinator(notificationsViewModel: serviceNotificationsViewModel)
        notificationsCoordinator.start()
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

extension ServicesCoordinator: NavigationCoordinatorDelegate {
    func willAddChild(coordinator: ChildCoordinator) {

    }

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
