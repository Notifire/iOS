//
//  UserSessionHandler.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift
import AuthenticationServices

protocol UserSessionHandlerDelegate: class {
    func shouldRemoveUser(session: UserSession, reason: UserSessionRemovalReason)
}

enum UserSessionRemovalReason {
    case userLoggedOut
    case ssoProviderRevokedAccess
    case refreshTokenInvalidated

    func reasonDescription(provider: AuthenticationProvider) -> String {
        switch self {
        case .userLoggedOut: return "You have logged out."
        case .ssoProviderRevokedAccess: return "Your login provider (\(provider.description)) has revoked access to your current session. Please log in again."
        case .refreshTokenInvalidated: return "Please log in again."
        }
    }
}

/// Class responsible for handling the current session events.
class UserSessionHandler: RealmProviding {

    // MARK: - Properties
    private static let registerDeviceFailureRetryTime: TimeInterval = 15
    let deviceTokenManager = DeviceTokenManager()
    let userSession: UserSession
    let notifireProtectedApiManager: NotifireProtectedAPIManager
    private let realmProvider: RealmProvider
    var realm: Realm {
        return realmProvider.realm
    }

    weak var sessionDelegate: UserSessionHandlerDelegate?

    // MARK: Observing
    var observers = [NSObjectProtocol]()

    // MARK: - Initialization
    init?(session: UserSession) {
        userSession = session
        notifireProtectedApiManager = NotifireAPIFactory.createProtectedAPIManager(session: session)
        guard let realmProvider = RealmProvider(userSession: session) else { return nil }
        self.realmProvider = realmProvider
        setupObservers()
    }

    deinit {
        removeObservers()
    }

    // MARK: - Public
    /// registers the device token with the Notifire API
    // TODO: Move this func to DeviceTokenManager
    public func registerDevice(with deviceToken: String) {
        notifireProtectedApiManager.register(deviceToken: deviceToken) { [weak self] result in
            switch result {
            case .error:
                DispatchQueue.main.asyncAfter(deadline: .now() + UserSessionHandler.registerDeviceFailureRetryTime) { [weak self] in
                    self?.registerDevice(with: deviceToken)
                }
            case .success:
                self?.userSession.deviceToken = deviceToken
                self?.deviceTokenManager.isAlreadyRegistered = true
            }
        }
    }

    /// Informs the notifire API that the user has logged out and starts the chain of callbacks to logout the user properly.
    /// - Parameters:
    ///     - reason: the event that triggered this logout
    public func exitUserSession(reason: UserSessionRemovalReason) {
        // Logout via the Notifire API = stops sending notifications to this deviceToken
        if let currentDeviceToken = userSession.deviceToken {
            notifireProtectedApiManager.logout(deviceToken: currentDeviceToken, completion: { _ in })
        }
        deviceTokenManager.unregisterFromPushNotifications()
        // Make sure we will register again if needed on next user login
        deviceTokenManager.isAlreadyRegistered = false
        // Inform the delegate about the removal
        sessionDelegate?.shouldRemoveUser(session: userSession, reason: reason)
    }
}

extension UserSessionHandler: Observing {

    var notificationNames: [NSNotification.Name] {
        guard #available(iOS 13, *) else { return [] }
        return [ASAuthorizationAppleIDProvider.credentialRevokedNotification]
    }

    var notificationHandlers: [NSNotification.Name: ((Notification) -> Void)] {
        guard #available(iOS 13, *) else { return [:] }
        return [ASAuthorizationAppleIDProvider.credentialRevokedNotification: appleIDCredentialRevoked]
    }

    func appleIDCredentialRevoked(notification: Notification) {
        // Make sure that the user session is logged in via Apple
        guard
            #available(iOS 13.0, *),
            userSession.providerData.provider == .sso(.apple),
            let userID = userSession.providerData.userID
        else { return }
        // Get provider credentials
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: userID) { [weak self] (credentialState, error) in
            guard error == nil else { return }
            switch credentialState {
            case .revoked:
                self?.exitUserSession(reason: .ssoProviderRevokedAccess)
            case .authorized, .notFound, .transferred:
                // Don't do anything, not relevant for us
                break
            default:
                break
            }
        }
    }
}
