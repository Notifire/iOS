//
//  DeviceTokenManager.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import UserNotifications

/// Takes care of registering for notifications and user prompts
class DeviceTokenManager {

    enum RegistrationState {
        case initial
        /// After successfully obtaining a deviceToken from APNS
        case registeredRemoteNotifications
        /// After successfully registering the device with Notifire API
        case registeredDevice
        case obtainedAuthorization
    }

    // MARK: - Properties
    var isAlreadyRegistered = false

    // MARK: - Methods
    func registerForPushNotifications() {
        guard !isAlreadyRegistered else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .carPlay, .sound]) { _, _ in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func unregisterFromPushNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
}
