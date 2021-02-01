//
//  ServicesCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class ServicesCoordinator: NavigatingChildCoordinator, PresentingCoordinator {

    // MARK: - Properties
    let servicesViewController: ServicesViewController
    let userSessionHandler: UserSessionHandler

    private var protectedApiManager: NotifireProtectedAPIManager {
        return servicesViewController.viewModel.protectedApiManager
    }

    // MARK: ChildCoordinator
    var viewController: UIViewController {
        return servicesViewController
    }

    // MARK: NavigatingChildCoordinator
    weak var parentNavigatingCoordinator: NavigatingCoordinator?

    // MARK: PresentingCoordinator
    var presentedCoordinator: ChildCoordinator?
    var presentationDismissHandler: UIAdaptivePresentationDismissHandler?

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
        let serviceCreationCoordinator = ServiceCreationCoordinator(protectedApiManager: protectedApiManager)
        serviceCreationCoordinator.serviceCreationDelegate = self
        present(childCoordinator: serviceCreationCoordinator, animated: true, modalPresentationStyle: .fullScreen)
    }

    func show(service: ServiceRepresentable) {
        let serviceViewModel = ServiceViewModel(service: service, sessionHandler: userSessionHandler, servicesVM: servicesViewController.viewModel)
        let serviceViewController = ServiceViewController(viewModel: serviceViewModel)
        let serviceCoordinator = ServiceCoordinator(serviceViewController: serviceViewController)
        parentNavigatingCoordinator?.push(childCoordinator: serviceCoordinator)
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

    func didDeleteService(with id: Int) {
        guard
            parentNavigatingCoordinator?.childCoordinators.contains(where: { ($0.viewController as? ServiceViewController)?.viewModel.currentServiceID == id }) != nil
        else { return }
        parentNavigatingCoordinator?.popToRootCoordinator()
    }
}

// MARK: - ServiceCreationDelegate
extension ServicesCoordinator: ServiceCreationCoordinatorDelegate {
    func didCancelServiceCreation() {
        dismissPresentedCoordinator(animated: true)
    }

    func didFinishServiceCreation() {
        dismissPresentedCoordinator(animated: true)
    }
}
