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
import SDWebImage

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
    let deviceTokenManager: DeviceTokenManager
    let userSession: UserSession
    let notifireProtectedApiManager: NotifireProtectedAPIManager
    let imageCache: SDImageCache
    private let realmProvider: RealmProvider
    var realm: Realm {
        return realmProvider.realm
    }

    weak var sessionDelegate: UserSessionHandlerDelegate?

    // MARK: NotificationObserving
    var observers = [NSObjectProtocol]()

    // MARK: - Initialization
    init?(session: UserSession) {
        userSession = session
        notifireProtectedApiManager = NotifireAPIFactory.createProtectedAPIManager(session: session)
        self.deviceTokenManager = DeviceTokenManager(userSession: session, apiManager: notifireProtectedApiManager)
        guard let realmProvider = RealmProvider(userSession: session) else { return nil }
        self.realmProvider = realmProvider
        // Image Cache
        guard let imageCache = UserSessionManager.createImageCache(from: session) else { return nil }
        self.imageCache = imageCache
        SDWebImageManager.defaultImageCache = imageCache
        startObservingNotifications()
    }

    deinit {
        stopObservingNotifications()
    }

    // MARK: - Public
    /// Informs the notifire API that the user has logged out and starts the chain of callbacks to logout the user properly.
    /// - Parameters:
    ///     - reason: the event that triggered this logout
    public func exitUserSession(reason: UserSessionRemovalReason) {
        // Logout via the Notifire API = stops sending notifications to this deviceToken
        deviceTokenManager.unregisterDeviceFromNotifireApi()
        deviceTokenManager.unregisterFromPushNotifications()
        // Inform the delegate about the removal
        sessionDelegate?.shouldRemoveUser(session: userSession, reason: reason)
    }

    public func updateUserSession(refreshToken: String, accessToken: String) {
        userSession.refreshToken = refreshToken
        userSession.accessToken = accessToken
        // Save the new refresh token to the keychain
        UserSessionManager.saveSessionInParts(session: userSession, email: false, refreshToken: true, providerData: false, deviceToken: false)
    }
}

extension UserSessionHandler: NotificationObserving {

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
