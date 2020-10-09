//
//  AppCoordinator.swift
//  Notifire
//
//  Created by David Bielik on 11/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

/// The main `Coordinator` class for the Application.
/// This coordinator is responsible for switching between Logged in / out states of the app as well as handling deeplinks.
class AppCoordinator: Coordinator {

    // MARK: - App State
    /// Describes the application's state. Each state contains the current coordinator responsbile for the view hierarchy.
    enum AppState {
        /// The user has logged in thus a session is available.
        case sessionAvailable(SessionCoordinator)
        /// The user is not logged in.
        case noSession(NoSessionCoordinator)
    }

    // MARK: - Properties
    // MARK: UI
    let window: UIWindow
    let rootViewController: RootViewController

    // MARK: Handlers
    let deeplinkHandler = DeeplinkHandler()
    let notificationsHandler = NotifireNotificationsHandler()

    // MARK: State
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

    // MARK: Coordinator
    var sessionCoordinator: SessionCoordinator? {
        guard let unwrappedState = appState, case .sessionAvailable(let sessionCoordinator) = unwrappedState else {
            return nil
        }
        return sessionCoordinator
    }

    // MARK: - Initialization
    init(window: UIWindow) {
        self.window = window

        // Initialize the RootViewController
        let rootVM = RootViewModel()
        self.rootViewController = RootViewController(viewModel: rootVM)
        // Window
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()
    }

    // MARK: - Coordinator
    func start() {
        // Deeplink handler delegate
        deeplinkHandler.appCoordinator = self

        // Application reveal logic
        let revealingViewController: UIViewController & AppRevealing
        var completion: (() -> Void)?

        if let sessionHandler = rootViewController.viewModel.sessionManager.getUserSessionHandler() {
            revealingViewController = createSessionVC(sessionHandler: sessionHandler)
            completion = {
                // TODO: Move the registering for push notifications into a new popup VC
                sessionHandler.deviceTokenManager.registerForPushNotifications()
            }
        } else {
            revealingViewController = createNoSessionVC()
        }
        rootViewController.add(childViewController: revealingViewController)
        revealingViewController.revealContent(completion: completion) // start the initial revealing animation
    }

    // MARK: Private
    /// Create a `NoSessionContainerViewController`
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
    private func createSessionVC(sessionHandler: UserSessionHandler) -> TabBarViewController {
        sessionHandler.sessionDelegate = self
        let tabBarViewModel = TabBarViewModel(sessionHandler: sessionHandler)
        let tabBarViewController = TabBarViewController(viewModel: tabBarViewModel)
        let sessionCoordinator = SessionCoordinator(tabBarViewController: tabBarViewController, sessionHandler: sessionHandler)
        sessionCoordinator.start()
        appState = .sessionAvailable(sessionCoordinator)
        return tabBarViewController
    }

    // MARK: Internal
    @discardableResult
    func switchTo(userSession: UserSession) -> Bool {
        // Make sure that we have no session active at the moment.
        guard let state = appState, case .noSession(let noSessionCoordinator) = state, let sessionHandler = UserSessionHandler(session: userSession) else { return false }
        // Create new session with a logged in user.
        let sessionVC = createSessionVC(sessionHandler: sessionHandler)
        let completion: (() -> Void) = {
            // TODO: Move the registering for push notifications into a new popup VC
            sessionHandler.deviceTokenManager.registerForPushNotifications()
        }

        // Handle the case where a deeplink is open
        if deeplinkHandler.currentDeeplink != nil {
            deeplinkHandler.finishDeeplink {
                self.rootViewController.cycleFrom(oldVC: noSessionCoordinator.noSessionContainerViewController, to: sessionVC, completion: completion)
            }
        } else {
            rootViewController.cycleFrom(oldVC: noSessionCoordinator.noSessionContainerViewController, to: sessionVC, completion: completion)
        }
        return true
    }

    func switchToLoginFlow() {
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
