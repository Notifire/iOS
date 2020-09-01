//
//  NotifireUserSessionHandler.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class NotifireUserSessionHandler: RealmProviding {

    private static let registerDeviceFailureRetryTime: TimeInterval = 15
    let deviceTokenManager = DeviceTokenManager()
    let userSession: NotifireUserSession
    let notifireProtectedApiManager: NotifireProtectedAPIManager
    private let realmProvider: RealmProvider
    var realm: Realm {
        return realmProvider.realm
    }

    init?(session: NotifireUserSession) {
        userSession = session
        notifireProtectedApiManager = NotifireAPIManagerFactory.createProtectedAPIManager(session: session)
        guard let realmProvider = RealmProvider(userSession: session) else { return nil }
        self.realmProvider = realmProvider
    }

    // MARK: - Public
    /// registers the device token with the Notifire API
    func registerDevice(with deviceToken: String) {
        notifireProtectedApiManager.register(deviceToken: deviceToken) { [weak self] result in
            switch result {
            case .error:
                DispatchQueue.main.asyncAfter(deadline: .now() + NotifireUserSessionHandler.registerDeviceFailureRetryTime) { [weak self] in
                    self?.registerDevice(with: deviceToken)
                }
            case .success:
                self?.userSession.deviceToken = deviceToken
                self?.deviceTokenManager.isAlreadyRegistered = true
            }
        }
    }

    /// informs the notifire API that the user has logged out
    func logout() {
        guard let currentDeviceToken = userSession.deviceToken else { return }
        notifireProtectedApiManager.logout(deviceToken: currentDeviceToken, completion: { _ in })
        deviceTokenManager.isAlreadyRegistered = false
    }
}
