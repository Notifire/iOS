//
//  RootViewModel.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class RootViewModel: ViewModelRepresenting {

    // MARK: - App State
    /// Describes the application's state. Each state contains the current coordinator responsbile for the view hierarchy.
    enum AppState {
        /// The user has logged in thus a session is available.
        case sessionAvailable(SessionCoordinator)
        /// The user is not logged in.
        case noSession(NoSessionCoordinator)
    }

    // MARK: - Properties
    let appVersionManager = AppVersionManager()
    let notificationsHandler = NotifireNotificationsHandler()
    var versionNotificationObserver: NotificationObserver?

    var userAttentionPromptManager = UserAttentionPromptManager()
    weak var activePrompt: UserAttentionPrompt?

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

    /// The current `UserSessionHandler`. Not nil if some user is logged in.
    var currentSessionHandler: UserSessionHandler? {
        guard case .sessionAvailable(let coordinator) = appState else { return nil }
        return coordinator.userSessionHandler
    }

    // MARK: Callback
    /// Called when a new version of the app is available.
    var onNewVersionAvailable: ((AppVersionData) -> Void)?

    // MARK: - Public
    // MARK: Session
    /// Save the new user session via the manager object.
    public func save(new session: UserSession) {
        UserSessionManager.saveSession(userSession: session)
    }

    /// Remove the session passed in the parameter.
    public func remove(old session: UserSession) {
        UserSessionManager.removeSession(userSession: session)
        // Reset the number of notifications in the app icon badge
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    // MARK: App Version
    public func checkAppVersion() {
        if versionNotificationObserver == nil {
            versionNotificationObserver = NotificationObserver(notificationName: .didReceiveAppVersionCheck, notificationHandler: { [weak self] notification in
                guard let `self` = self else { return }
                guard
                    let appVersionDataDict = notification.userInfo,
                    let appVersionData = AppVersionData.decodeDictionary(to: AppVersionData.self, from: appVersionDataDict)
                else {
                    Logger.log(.error, "\(self) couldn't decode didReceiveAppVersionCheck userInfo")
                    return
                }

                let updateAction = self.appVersionManager.decideIfUserShouldUpdate(versionData: appVersionData, userSession: self.currentSessionHandler?.userSession)
                Logger.log(.info, "\(self) appUpdateAction=<\(updateAction)> (latest=\(appVersionData.appVersionResponse.latestVersion), current=\(Config.appVersion))")

                guard updateAction.shouldPromptUpdate else { return }

                // let the prompt manager notify the delegate
                let prompt = UserAttentionPrompt(name: "AppVersionAlert") { [weak self] in
                    self?.onNewVersionAvailable?(appVersionData)
                }
                self.activePrompt = prompt
                self.userAttentionPromptManager.add(userAttentionPrompt: prompt)
            })
        }

        //try? appVersionManager.fetchAppVersionData()
    }
}
