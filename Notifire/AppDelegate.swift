//
//  AppDelegate.swift
//  Notifire
//
//  Created by David Bielik on 30/01/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import Sentry

class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Variables
    lazy var window: UIWindow? = UIWindow(frame: UIScreen.main.bounds)

    /// implicitly unwrapped because it is set in the `didFinishLaunchingWithOptions` method
    var appCoordinator: AppCoordinator!

    // MARK: - AppDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Launch arguments
        LaunchArgumentsHandler().handleLaunchArgumentsIfNeeded()

        // Sentry
        SentrySDK.start { options in
            options.dsn = Config.sentryDsn
            options.debug = true
            options.environment = Config.bundleID
        }

        // Window
        let applicationWindow = UIWindow(frame: UIScreen.main.bounds)
        applicationWindow.tintColor = .primary
        // App Coordinator
        self.window = applicationWindow
        appCoordinator = AppCoordinator(window: applicationWindow)
        appCoordinator.start()
        return true
    }

    // MARK: - Deeplinks
    // Handles the deeplink action
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return appCoordinator?.deeplinkHandler.switchToAppropriateDeeplink(from: url) ?? false
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL {
            let shouldContinue = appCoordinator?.deeplinkHandler.switchToAppropriateDeeplink(from: url) ?? false
            if !shouldContinue {
                restorationHandler(nil)
            }
            return shouldContinue
        }
        return true
    }

    // MARK: - Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        guard let state = appCoordinator?.appState, case .sessionAvailable(let sessionCoordinator) = state else { return }
        let deviceTokenString = sessionCoordinator.userSessionHandler.createDeviceToken(from: deviceToken)
        sessionCoordinator.userSessionHandler.registerDevice(with: deviceTokenString)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

    }

    // Handles notification tap
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        switch application.applicationState {
        case .active, .inactive, .background:
            guard let sessionCoordinator = appCoordinator?.sessionCoordinator else { return }
            sessionCoordinator.tabBarViewController.viewModel.currentTab = .notifications
            let notificationHandler = NotifireNotificationsHandler()
            guard notificationHandler.getNotification(from: userInfo) != nil else {
                return
            }
        @unknown default: break
        }
    }
}
