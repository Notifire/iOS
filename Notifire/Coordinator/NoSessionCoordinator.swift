//
//  NoSessionCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation

class NoSessionCoordinator: Coordinator {
    
    // MARK: - Properties
    let noSessionContainerViewController: NoSessionContainerViewController
    let loginViewController: LoginViewController
    var registerCoordinator: RegisterCoordinator?
    weak var delegate: NotifireUserSessionCreationDelegate?
    
    // MARK: - Initialization
    init(noSessionContainerViewController: NoSessionContainerViewController) {
        let loginViewModel = LoginViewModel()
        let loginViewController = LoginViewController(viewModel: loginViewModel)
        self.loginViewController = loginViewController
        self.noSessionContainerViewController = noSessionContainerViewController
    }
    
    // MARK: Coordination
    func start() {
        loginViewController.delegate = self
        noSessionContainerViewController.add(childViewController: loginViewController)
    }
    
    func startRegisterFlow() {
        guard registerCoordinator == nil else { return }
        let presentedCoordinator: RegisterCoordinator
        if let currentRegisterCoordinator = registerCoordinator {
            presentedCoordinator = currentRegisterCoordinator
        } else {
            let newRegisterCoordinator = RegisterCoordinator(apiManager: loginViewController.viewModel.notifireApiManager)
            newRegisterCoordinator.parentCoordinator = self
            newRegisterCoordinator.start()
            self.registerCoordinator = newRegisterCoordinator
            presentedCoordinator = newRegisterCoordinator
        }
        noSessionContainerViewController.presentCoverVertical(viewController: presentedCoordinator.navigationController)
    }
    
    func finishRegisterFlow() {
        guard let registerNavigationVC = registerCoordinator?.navigationController else { return }
        registerCoordinator = nil
        noSessionContainerViewController.dismissVertical(viewController: registerNavigationVC)
    }
}

extension NoSessionCoordinator: LoginViewControllerDelegate {
    func didCreate(session: NotifireUserSession) {
        delegate?.didCreate(session: session)
    }
    
    func shouldStartRegisterFlow() {
        startRegisterFlow()
    }
}
