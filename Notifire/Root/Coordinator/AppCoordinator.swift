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

    // MARK: - Properties
    // MARK: UI
    let window: UIWindow
    let rootViewController: RootViewController

    // MARK: Handlers
    let deeplinkHandler = DeeplinkHandler()

    // MARK: Coordinator
    var sessionCoordinator: SessionCoordinator? {
        guard let unwrappedState = appState, case .sessionAvailable(let sessionCoordinator) = unwrappedState else {
            return nil
        }
        return sessionCoordinator
    }

    // MARK: AppState
    var appState: RootViewModel.AppState? {
        get { return rootViewController.viewModel.appState }
        set { rootViewController.viewModel.appState = newValue }
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

        revealAppContent()

        // Handle notification tap
        rootViewController.viewModel.notificationsHandler.onNotificationTap = { [weak self] notificationID in
            guard let sessionCoordinator = self?.sessionCoordinator else { return }
            sessionCoordinator.userSessionHandler.realm.refresh()
            if let notification = sessionCoordinator.userSessionHandler.realm.object(ofType: LocalNotifireNotification.self, forPrimaryKey: notificationID) {
                if sessionCoordinator.tabBarViewController.viewModel.currentTab == .some(.services), let servicesNavigationCoordinator = sessionCoordinator.activeCoordinator as? NavigationCoordinator<ServicesCoordinator> {
                    // Current tab = services
                    let servicesCoordinator = servicesNavigationCoordinator.rootChildCoordinator
                    if !servicesCoordinator.servicesViewController.isViewLoaded {
                        // App Launch
                        servicesCoordinator.servicesViewController.onViewDidAppear = {
                            servicesCoordinator.showServiceAnd(notification: notification, animated: false)
                            servicesCoordinator.servicesViewController.onViewDidAppear = nil
                        }
                    } else {
                        // App already launched
                        sessionCoordinator.tabBarViewController.viewModel.updateTab(to: .services, animated: false)
                        servicesCoordinator.showServiceAnd(notification: notification, animated: true)
                    }
                } else {
                    // Switch to services
                    sessionCoordinator.tabBarViewController.viewModel.updateTab(to: .services, animated: false)
                    if let servicesNavigationCoordinator = sessionCoordinator.activeCoordinator as? NavigationCoordinator<ServicesCoordinator> {
                        let servicesCoordinator = servicesNavigationCoordinator.rootChildCoordinator
                        servicesCoordinator.showServiceAnd(notification: notification, animated: true)
                    }
                }
            }
        }
    }

    // MARK: Private
    /// Create a `NoSessionContainerViewController`
    private func createNoSessionVC() -> NoSessionContainerViewController {
        let noSessionContainerViewController = NoSessionContainerViewController()
        let noSessionCoordinator = NoSessionCoordinator(noSessionContainerViewController: noSessionContainerViewController)
        noSessionCoordinator.delegate = self
        noSessionCoordinator.start()
        appState = .noSession(noSessionCoordinator)
        return noSessionContainerViewController
    }

    private func createSessionVC(sessionHandler: UserSessionHandler) -> TabBarViewController {
        sessionHandler.sessionDelegate = self
        let promptManager = rootViewController.viewModel.userAttentionPromptManager
        let tabBarViewModel = TabBarViewModel(sessionHandler: sessionHandler, promptManager: promptManager)
        let tabBarViewController = TabBarViewController(viewModel: tabBarViewModel)
        let sessionCoordinator = SessionCoordinator(tabBarViewController: tabBarViewController, sessionHandler: sessionHandler)
        sessionCoordinator.start()
        appState = .sessionAvailable(sessionCoordinator)
        return tabBarViewController
    }

    // MARK: Internal
    /// Reveals the application content (the first visible VC)
    /// - Important: Should only be called once in the `start()` method.
    func revealAppContent() {
        // Application reveal logic
        let revealingViewController: UIViewController & AppRevealing
        var completion: (() -> Void)?

        if let sessionHandler = UserSessionManager.getUserSessionHandler() {
            revealingViewController = createSessionVC(sessionHandler: sessionHandler)
            completion = {
                // Check for app version updates after revealing the app
                self.rootViewController.viewModel.checkAppVersion()

                // TODO: Move the registering for push notifications into a new popup VC
                sessionHandler.deviceTokenManager.registerForPushNotifications()
            }
        } else {
            revealingViewController = createNoSessionVC()
            completion = { [unowned self] in
                // Check for app version updates after revealing the app
                self.rootViewController.viewModel.checkAppVersion()
            }
        }
        rootViewController.add(childViewController: revealingViewController)
        revealingViewController.revealContent(completion: completion) // start the initial revealing animation
    }

    @discardableResult
    /// Switch the application to the state where a user is logged in.
    func switchTo(userSession: UserSession) -> Bool {
        // Make sure that we have no session active at the moment.
        guard
            let state = appState,
            case .noSession(let noSessionCoordinator) = state,
            let sessionHandler = UserSessionHandler(session: userSession)
        else { return false }
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

    /// Switch the application to a state where no user is logged in.
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
