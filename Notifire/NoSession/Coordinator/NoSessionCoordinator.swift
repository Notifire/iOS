//
//  NoSessionCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import SafariServices

class NoSessionCoordinator: Coordinator {

    // MARK: - Properties
    let noSessionContainerViewController: NoSessionContainerViewController
    let loginRegisterSplitterVC: LoginRegisterSplitterViewController

    var presentedCoordinator: ChildCoordinator?
    weak var delegate: UserSessionCreationDelegate?

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
        let registerCoordinator = RegisterCoordinator()
        registerCoordinator.parentCoordinator = self
        registerCoordinator.start()
        presentedCoordinator = registerCoordinator
        noSessionContainerViewController.presentCoverVertical(viewController: registerCoordinator.viewController)
    }

    // MARK: Login
    func startLoginFlow() {
        guard presentedCoordinator == nil else { return }
        let loginVM = LoginViewModel(apiManager: loginRegisterSplitterVC.viewModel.notifireApiManager)
        let loginVC = LoginViewController(viewModel: loginVM)
        loginVC.delegate = self
        let loginCoordinator = LoginCoordinator(loginViewController: loginVC)
        let loginNavigationCoordinator = NavigationCoordinator(rootChildCoordinator: loginCoordinator, navigationController: LoginNavigationController())
        loginNavigationCoordinator.start()
        presentedCoordinator = loginNavigationCoordinator
        noSessionContainerViewController.presentCoverVertical(viewController: loginNavigationCoordinator.viewController)
    }

    func finishRegisterOrLoginFlow() {
        guard let presentedVC = presentedCoordinator?.viewController else { return }
        presentedCoordinator = nil
        noSessionContainerViewController.dismissVertical(viewController: presentedVC)
    }

    // MARK: Privacy Policy
    func presentPrivacyPolicy() {
        let safariViewController = SFSafariViewController(url: Config.privacyPolicyURL)
        safariViewController.modalPresentationStyle = .formSheet
        safariViewController.dismissButtonStyle = .close
        safariViewController.preferredControlTintColor = .primary
        loginRegisterSplitterVC.present(safariViewController, animated: true, completion: nil)
    }
}

extension NoSessionCoordinator: LoginRegisterSplitterViewControllerDelegate, LoginViewControllerDelegate {

    func shouldStartLoginFlow() {
        startLoginFlow()
    }

    func shouldStartManualRegisterFlow() {
        startRegisterFlow()
    }

    func shouldPresentPrivacyPolicy() {
        presentPrivacyPolicy()
    }

    func shouldDismissLogin() {
        finishRegisterOrLoginFlow()
    }

    func didCreate(session: UserSession) {
        delegate?.didCreate(session: session)
    }

    func shouldStartRegisterFlow() {
        startRegisterFlow()
    }
}
