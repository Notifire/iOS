//
//  DeviceTokenManager.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import UserNotifications

/// Takes care of registering for notifications and observing the notification permissions status.
class DeviceTokenManager {

    enum NotificationPermissionsState: Equatable {
        case initial
        /// After successfully obtaining a deviceToken from APNS
        case registeredRemoteNotifications(deviceToken: String)
        /// After successfully registering the device with Notifire API
        case registeredDevice
        /// After the user notification authorization status is obtained
        /// `nil` associated value is used when the application becomes inactive.
        case obtainedUserNotificationAuthorization(status: UNAuthorizationStatus?)
    }

    // MARK: - Properties
    let stateModel = StateModel(defaultValue: NotificationPermissionsState.initial)
    let protectedApiManager: NotifireProtectedAPIManager
    let userSession: UserSession
    var applicationActiveObserver: NotificationObserver?

    /// `true` if the state is in the right state and the user has allowed notifications
    var isAuthorizedForPushNotifications: Bool {
        guard
            case .obtainedUserNotificationAuthorization(let status) = stateModel.state,
            status == .authorized
        else { return false }
        return true
    }

    var canGetUserNotificationAuthorizationStatus: Bool {
        switch stateModel.state {
        case .initial, .registeredRemoteNotifications: return false
        case .registeredDevice, .obtainedUserNotificationAuthorization: return true
        }
    }

    var isDeniedPermissionForPushNotifications: Bool {
        switch stateModel.state {
        case .obtainedUserNotificationAuthorization(status: .denied): return true
        default: return false
        }
    }

    // MARK: Static
    private static let registerDeviceFailureRetryTime: TimeInterval = 15

    // MARK: - Initialization
    init(userSession: UserSession, apiManager: NotifireProtectedAPIManager) {
        self.protectedApiManager = apiManager
        self.userSession = userSession
        setup()
    }

    // MARK: - Private
    private func setup() {
        // Gotta watch for notification authorization status changes in case the user changes them in Settings.app
        self.applicationActiveObserver = NotificationObserver(
            notificationNames: [UIApplication.willResignActiveNotification, UIApplication.didBecomeActiveNotification],
            notificationHandlers: [
                UIApplication.willResignActiveNotification: { [weak self] _ in
                    if case .obtainedUserNotificationAuthorization = self?.stateModel.state {
                        self?.stateModel.state = .obtainedUserNotificationAuthorization(status: nil)
                    }
                },
                UIApplication.didBecomeActiveNotification: { [weak self] _ in
                    self?.getCurrentUserNotificationAuthorizationStatus()
                }
            ]
        )

        // Watch for state changes to continue the chain
        stateModel.onStateChange = { [weak self] old, new in
            // Notify listeners
            NotificationCenter.default.post(name: .didChangeNotificationPermissionsState, object: self, userInfo: nil)
        }

        // Register for push notifications
        registerForPushNotifications()
    }

    // MARK: - Methods
    // MARK: registeredRemoteNotifications
    func registerForPushNotifications() {
        guard stateModel.state == .initial else { return }

        UIApplication.shared.registerForRemoteNotifications()
    }

    /// Called on UIAppDelegate.didRegisterForRemoteNotificationsWithDeviceToken
    func onDidRegisterForRemoteNotificationsWithDeviceToken(deviceTokenData: Data) {
        let tokenParts = deviceTokenData.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let deviceToken = tokenParts.joined()
        stateModel.state = .registeredRemoteNotifications(deviceToken: deviceToken)
        registerDeviceWithNotifireApi()
    }

    /// Called on UIAppDelegate.didFailToRegisterForRemoteNotificationsWithError
    func onDidFailToRegisterForRemoteNotificationsWithError(error: Error) {
        Logger.log(.fault, "\(self) didFailToRegisterForRemoteNotifications error=<\(error.localizedDescription)>")

        // Retry a bit later
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.registerDeviceFailureRetryTime) { [weak self] in
            self?.registerForPushNotifications()
        }
    }

    func unregisterFromPushNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    // MARK: registeredDevice
    /// register the device token with the Notifire API
    func registerDeviceWithNotifireApi() {
        guard case .registeredRemoteNotifications(let deviceToken) = stateModel.state else { return }
        protectedApiManager.register(deviceToken: deviceToken) { [weak self] result in
            guard let `self` = self, case .registeredRemoteNotifications = self.stateModel.state else { return }
            switch result {
            case .error:
                Logger.log(.debug, "\(self) failed to register deviceToken=\(deviceToken)")
                // Retry later
                DispatchQueue.main.asyncAfter(deadline: .now() + Self.registerDeviceFailureRetryTime) { [weak self] in
                    self?.registerDeviceWithNotifireApi()
                }
            case .success:
                Logger.log(.debug, "\(self) registered deviceToken=\(deviceToken)")
                self.userSession.deviceToken = deviceToken
                self.stateModel.state = .registeredDevice
                self.getCurrentUserNotificationAuthorizationStatus()
            }
        }
    }

    func unregisterDeviceFromNotifireApi() {
        guard let deviceToken = userSession.deviceToken else { return }
        // Request the API once.
        protectedApiManager.logout(deviceToken: deviceToken) { _ in }
    }

    // MARK: obtainedAuthorization
    func getCurrentUserNotificationAuthorizationStatus() {
        guard canGetUserNotificationAuthorizationStatus else { return }

        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { [weak self] in
                self?.stateModel.state = .obtainedUserNotificationAuthorization(status: settings.authorizationStatus)
            }
        }
    }

    func requestUserNotificationAuthorization() {
        guard !isAuthorizedForPushNotifications else { return }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound]) { [weak self] _, error in
            guard let `self` = self else { return }
            if let error = error {
                Logger.log(.error, "\(self) requestAuthorization failed with error=<\(error.localizedDescription)>")
            }
            self.getCurrentUserNotificationAuthorizationStatus()
        }
    }
}

// MARK: - Notification
extension Notification.Name {
    /// Posted whenver DeviceTokenManager updates the StateModel.state
    static let didChangeNotificationPermissionsState = Notification.Name("didChangeNotificationPermissionsState")
}
