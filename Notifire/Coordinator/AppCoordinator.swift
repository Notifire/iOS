//
//  AppCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 11/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator {

    enum AppState {
        case sessionAvailable(SessionCoordinator)
        case noSession(NoSessionCoordinator)
    }

    // MARK: - Properties
    let rootViewController: RootViewController
    let deeplinkHandler = DeeplinkHandler()
    let notificationsHandler = NotifireNotificationsHandler()
    private let sessionManager: NotifireUserSessionManager
    var appState: AppState? {
        didSet {
            guard let unwrappedState = appState else { return}
            switch unwrappedState {
            case .noSession:
                notificationsHandler.activeRealmProvider = nil
            case .sessionAvailable(let sessionCoordinator):
                notificationsHandler.activeRealmProvider = sessionCoordinator.userSessionHandler
            }
        }
    }

    var sessionCoordinator: SessionCoordinator? {
        guard let unwrappedState = appState, case .sessionAvailable(let sessionCoordinator) = unwrappedState else {
            return nil
        }
        return sessionCoordinator
    }

    // MARK: - Initialization
    init(rootViewController: RootViewController, sessionManager: NotifireUserSessionManager = NotifireUserSessionManager()) {
        self.rootViewController = rootViewController
        self.sessionManager = sessionManager
    }

    // MARK: - Private
    @discardableResult
    private func createNoSessionVC() -> NoSessionContainerViewController {
        let noSessionContainerViewController = NoSessionContainerViewController()
        let noSessionCoordinator = NoSessionCoordinator(noSessionContainerViewController: noSessionContainerViewController)
        noSessionCoordinator.delegate = self
        noSessionCoordinator.start()
        appState = .noSession(noSessionCoordinator)
        return noSessionContainerViewController
    }

    @discardableResult
    private func createSessionVC(sessionHandler: NotifireUserSessionHandler) -> TabBarViewController {
        let tabBarViewModel = TabBarViewModel(sessionHandler: sessionHandler)
        let tabBarViewController = TabBarViewController(viewModel: tabBarViewModel)
        let sessionCoordinator = SessionCoordinator(tabBarViewController: tabBarViewController, sessionHandler: sessionHandler)
        sessionCoordinator.delegate = self
        sessionCoordinator.start()
        appState = .sessionAvailable(sessionCoordinator)
        return tabBarViewController
    }

    // MARK: - Internal
    func start() {
        notificationsHandler.setAsDelegate() // don't move the call from here (didFinishLaunching...)
        deeplinkHandler.appCoordinator = self
        let revealingViewController: UIViewController & AppRevealing
        var completion: (() -> Void)?
        if let session = sessionManager.previousSession() {
            // previous session found
            guard let sessionHandler = NotifireUserSessionHandler(session: session) else {
                // remove the session if the realm configuration file doesn't open
                sessionManager.removeSession(userSession: session)
                revealingViewController = createNoSessionVC()
                return
            }
            revealingViewController = createSessionVC(sessionHandler: sessionHandler)
            completion = {
                sessionHandler.deviceTokenManager.registerForPushNotifications()
            }
        } else {
            // no previous session has been found, present the NoSessionCoordinator
            revealingViewController = createNoSessionVC()
        }
        rootViewController.add(childViewController: revealingViewController)
        revealingViewController.revealContent(completion: completion) // start the initial revealing animation
    }

    @discardableResult
    func switchTo(userSession: NotifireUserSession) -> Bool {
        guard let state = appState, case .noSession(let noSessionCoordinator) = state, let sessionHandler = NotifireUserSessionHandler(session: userSession) else { return false }
        let sessionVC = createSessionVC(sessionHandler: sessionHandler)
        let completion: (() -> Void) = {
            sessionHandler.deviceTokenManager.registerForPushNotifications()
        }
        if deeplinkHandler.currentDeeplink != nil {
            deeplinkHandler.finishDeeplink {
                self.rootViewController.cycleFrom(oldVC: noSessionCoordinator.noSessionContainerViewController, to: sessionVC, completion: completion)
            }
        } else {
            rootViewController.cycleFrom(oldVC: noSessionCoordinator.noSessionContainerViewController, to: sessionVC, completion: completion)
        }
        return true
    }

    func switchToLogin() {
        guard let state = appState, case .sessionAvailable(let sessionCoordinator) = state else { return }
        let noSessionVc = createNoSessionVC()
        if deeplinkHandler.currentDeeplink != nil {
            deeplinkHandler.finishDeeplink {
                self.rootViewController.cycleFrom(oldVC: sessionCoordinator.tabBarViewController, to: noSessionVc)
            }
        } else {
            rootViewController.cycleFrom(oldVC: sessionCoordinator.tabBarViewController, to: noSessionVc)
        }
    }
}

extension AppCoordinator: ConfirmEmailViewControllerDelegate {
    func didFinishEmailConfirmation() {
        deeplinkHandler.finishDeeplink()
    }
}

extension AppCoordinator: NotifireUserSessionCreationDelegate {
    /// called when the user logs in, either by confirming his email or by manually entering his id/pw
    func didCreate(session: NotifireUserSession) {
        // don't interrupt any logged in session even when an account gets confirmed
        guard let state = appState, case .noSession = state else {
            // just dismiss the vc
            deeplinkHandler.finishDeeplink()
            return
        }
        guard switchTo(userSession: session) else { return }
        sessionManager.saveSession(userSession: session)
    }
}

extension AppCoordinator: NotifireUserSessionDeletionDelegate {
    /// called when the session is explicitly deleted (user logs out) or when the session expires (the refresh token changes)
    func didDelete(session: NotifireUserSession, onPurpose: Bool) {
        guard let state = appState, case .sessionAvailable(let coordinator) = state else { return }
        let onCompletion: (() -> Void) = { [unowned self] in
            self.sessionManager.removeSession(userSession: session)
            self.switchToLogin()
            UIApplication.shared.applicationIconBadgeNumber = 0
            DeviceTokenManager().unregisterFromPushNotifications()
            coordinator.userSessionHandler.logout()
        }
        guard onPurpose else {
            // forced logout
            let alertController = UIAlertController(title: "Login required.", message: "Please login again!", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { _ in
                onCompletion()
            }))
            coordinator.activeCoordinator?.viewController.present(alertController, animated: true, completion: nil)
            return
        }
        // logout
        onCompletion()
    }
}
