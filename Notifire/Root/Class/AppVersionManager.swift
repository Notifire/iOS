//
//  AppVersionManager.swift
//  Notifire
//
//  Created by David Bielik on 07/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class AppVersionManager {

    /// Errors thrown while attempting to fetch new version
    enum AppVersionCheckError: Error {
        case alreadyFetching
    }

    enum AppVersionState {
        /// Default AppVersion status after instantiating the AppVersionManager or whenever the new version fetch fails.
        case initial
        /// Whenver the app version data are fetching from the remote API.
        case fetching
        /// Set when the data are retrieved
        case checked(appVersionData: AppVersionData)
    }

    enum AppVersionUpdateAction: String, Equatable {
        /// User is running the latest version of the app. Don't prompt update alert.
        case latestVersion
        /// User has hidden the alerts in user settings. Don't prompt update alert.
        case userHasHiddenAlerts

        /// A new update is available, show the optional alert.
        case updateAvailable
        /// A new update is required, show the unclosable alert.
        case updateRequired

        var shouldPromptUpdate: Bool {
            switch self {
            case .latestVersion, .userHasHiddenAlerts: return false
            case .updateAvailable, .updateRequired: return true
            }
        }
    }

    // MARK: - Properties
    var state: AppVersionState = .initial
    let apiManager: NotifireAPIManager

    // MARK: Private
    private let currentVersionString: String

    // MARK: - Initialization
    init(currentVersion: String = Config.appVersion) {
        // - Important:
        // Keep the URLSession.custom API handler to avoid pinning `/version` endpoint
        self.apiManager = NotifireAPIFactory.createAPIManager(apiHandler: URLSession.custom)
        self.currentVersionString = currentVersion
    }

    // MARK: Private
    /// `true` if AppVersionState = `.initial`
    var canFetchAppVersionData: Bool {
        guard case .initial = state else { return false }
        return true
    }

    /// Delay in seconds for another fetch attempt after the previous one resulted in an error
    static let delayAfterFetchAttempt: TimeInterval = 5
    /// A flag indicating whether this manager class retries the fetch app version data request.
    var shouldAutoRetryFetchAppVersionData = true

    // MARK: - Methods
    /// Fetches the AppVersionData from the remote API and notifies listeners (`Notification.Name.didReceiveAppVersionCheck`)
    func fetchAppVersionData() throws {
        guard canFetchAppVersionData else {
            Logger.log(.debug, "\(self) attempted to fetch version data when state=<\(state)>")
            throw AppVersionCheckError.alreadyFetching
        }

        // Set the new state
        state = .fetching

        // Fetch
        apiManager.checkAppVersion { [weak self] response in
            switch response {
            case .error:
                // Reset the state
                self?.state = .initial

                // try again a bit later if needed...
                guard self?.shouldAutoRetryFetchAppVersionData ?? false else { return }
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + Self.delayAfterFetchAttempt) { [weak self] in
                    try? self?.fetchAppVersionData()
                }
            case .success(let response):
                // Create the version data from the response
                let versionData = AppVersionData(appVersionResponse: response)
                // Set the state to checked
                self?.state = .checked(appVersionData: versionData)

                // Notify observers
                NotificationCenter.default.post(name: .didReceiveAppVersionCheck, object: nil, userInfo: versionData.asDictionary)
            }
        }
    }

    /// Returns `AppVersionUpdateAction` depending on the versionData from the remote server and user's settings.
    func decideIfUserShouldUpdate(versionData: AppVersionData, userSession: UserSession?) -> AppVersionUpdateAction {
        // Check if the update isn't forced by the server
        guard !versionData.appVersionResponse.forceUpdate else { return .updateRequired }

        // Check if the user has enabled alerts
        let userEnabledAlerts = userSession?.settings.appUpdateReminderEnabled ?? true
        guard userEnabledAlerts else { return .userHasHiddenAlerts }

        // Check the versions versions
        let comparisonResult = AppVersionData.compareVersionsIgnoringPatch(
            version1: versionData.appVersionResponse.latestVersion,
            version2: currentVersionString
        )

        // latest > current
        if comparisonResult == .orderedDescending {
            return .updateAvailable
        } else {
            return .latestVersion
        }
    }
}

// MARK: - Notification
extension Notification.Name {
    /// Posted whenver AppVersionManager receives a new version of the app.
    static let didReceiveAppVersionCheck = Notification.Name("didReceiveAppVersionCheck")
}
