//
//  AppDelegate.swift
//  Notifire
//
//  Created by David Bielik on 30/01/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Variables
    var window: UIWindow?

    /// implicitly unwrapped because it is set in the `didFinishLaunchingWithOptions` method
    var appCoordinator: AppCoordinator!

    // MARK: - AppDelegate
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let applicationWindow = UIWindow(frame: UIScreen.main.bounds)
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
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let deviceToken = tokenParts.joined()
        print(deviceToken)
        guard let state = appCoordinator?.appState, case .sessionAvailable(let sessionCoordinator) = state else { return }
        sessionCoordinator.userSessionHandler.registerDevice(with: deviceToken)
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
