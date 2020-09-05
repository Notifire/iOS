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
    let loginRegisterSplitterVC: LoginRegisterSplitterViewController

    var presentedCoordinator: ChildCoordinator?
    weak var delegate: NotifireUserSessionCreationDelegate?

    // MARK: - Initialization
    init(noSessionContainerViewController: NoSessionContainerViewController) {
        let loginRegisterSplitterVM = LoginRegisterSplitterViewModel()
        loginRegisterSplitterVC = LoginRegisterSplitterViewController(viewModel: loginRegisterSplitterVM)
        self.noSessionContainerViewController = noSessionContainerViewController
    }

    // MARK: - Coordination
    func start() {
        loginRegisterSplitterVC.delegate = self
        noSessionContainerViewController.add(childViewController: loginRegisterSplitterVC)
    }

    // MARK: Register
    func startRegisterFlow() {
        guard presentedCoordinator == nil else { return }
        let newRegisterCoordinator = RegisterCoordinator(apiManager: loginRegisterSplitterVC.viewModel.notifireApiManager)
        newRegisterCoordinator.parentCoordinator = self
        newRegisterCoordinator.start()
        presentedCoordinator = newRegisterCoordinator
        noSessionContainerViewController.presentCoverVertical(viewController: newRegisterCoordinator.viewController)
    }

    // MARK: Login
    func startLoginFlow() {
        guard presentedCoordinator == nil else { return }
        let loginVM = LoginViewModel(notifireApiManager: loginRegisterSplitterVC.viewModel.notifireApiManager)
        let loginVC = LoginViewController(viewModel: loginVM)
        loginVC.delegate = self
        let loginCoordinator = LoginCoordinator(rootChildViewController: loginVC)
        loginCoordinator.parentCoordinator = self
        loginCoordinator.start()
        presentedCoordinator = loginCoordinator
        noSessionContainerViewController.presentCoverVertical(viewController: loginCoordinator.viewController)
    }

    func finishRegisterOrLoginFlow() {
        guard let presentedVC = presentedCoordinator?.viewController else { return }
        presentedCoordinator = nil
        noSessionContainerViewController.dismissVertical(viewController: presentedVC)
    }
}

extension NoSessionCoordinator: LoginRegisterSplitterViewControllerDelegate, LoginViewControllerDelegate {

    func shouldStartLoginFlow() {
        startLoginFlow()
    }

    func shouldStartManualRegisterFlow() {
        startRegisterFlow()
    }

    func shouldDismissLogin() {
        finishRegisterOrLoginFlow()
    }

    func didCreate(session: NotifireUserSession) {
        delegate?.didCreate(session: session)
    }

    func shouldStartRegisterFlow() {
        startRegisterFlow()
    }
}
