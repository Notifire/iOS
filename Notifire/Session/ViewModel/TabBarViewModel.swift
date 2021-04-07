//
//  TabBarViewModel.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import Foundation
import RealmSwift

class TabBarViewModel: RealmCollectionViewModel<LocalNotifireNotification> {

    // MARK: - Properties
    /// Describes the number of unread notifications state (e.g. if the app is supposed to show it or not)
    enum NewNotificationsAlertState {
        case shown(numberOfUnreadNotifications: Int)
        case hidden
    }

    // MARK: Model
    private (set) var currentTab: Tab?

    var tabs: [Tab] {
        return Tab.allCases
    }

    var notificationsAlertState: NewNotificationsAlertState = .hidden {
        didSet {
            onNotificationsAlertStateChange?(notificationsAlertState)
        }
    }

    let userSessionHandler: UserSessionHandler
    let userPromptManager: UserAttentionPromptManager

    var notificationPermissionsObserver: NotificationObserver?
    weak var notificationPermissionPrompt: UserAttentionPrompt?

    // MARK: WebSocketConnection
    let webSocketConnectionViewModel = WebSocketConnectionViewModel()

    // MARK: Callbacks
    var onTabChange: ((Tab) -> Void)?
    /// Called when a `Tab` is reselected. `Bool` = animated.
    var onTabReselect: ((Tab, Bool) -> Void)?
    var onNotificationsAlertStateChange: ((NewNotificationsAlertState) -> Void)?
    var onShouldPresentNotificationRequirement: (() -> Void)?

    // MARK: - Initialization
    init(sessionHandler: UserSessionHandler, promptManager: UserAttentionPromptManager) {
        self.userSessionHandler = sessionHandler
        self.userPromptManager = promptManager
        super.init(realmProvider: sessionHandler)
        setup()
    }

    // MARK: - Private
    private func setup() {
        notificationPermissionsObserver = NotificationObserver(notificationName: .didChangeNotificationPermissionsState, notificationHandler: { [weak self] notification in
            guard
                let `self` = self,
                let tokenManager = notification.object as? DeviceTokenManager,
                tokenManager.stateModel.state == .obtainedUserNotificationAuthorization(status: .notDetermined)
            else { return }
            let prompt = UserAttentionPrompt(name: "NotificationPermissions") { [weak self] in
                self?.onShouldPresentNotificationRequirement?()
            }
            self.notificationPermissionPrompt = prompt
            self.userPromptManager.add(userAttentionPrompt: prompt, prioritizedPrompt: true)
        })
    }

    // MARK: - Inherited
    override func resultsFilterPredicate() -> NSPredicate? {
        return LocalNotifireNotification.isUnreadPredicate
    }

    // MARK: - Internal
    func updateTab(to newTab: Tab, animated: Bool = true) {
        let oldValue = currentTab
        currentTab = newTab
        guard oldValue != newTab else {
            onTabReselect?(newTab, animated)
            return
        }
        onTabChange?(newTab)
    }

    override func onResults(change: RealmCollectionChange<Results<LocalNotifireNotification>>) {
        super.onResults(change: change)
        switch change {
        case .initial(let collection), .update(let collection, _, _, _):
            if collection.isEmpty {
                self.notificationsAlertState = .hidden
            } else {
                self.notificationsAlertState = .shown(numberOfUnreadNotifications: collection.count)
            }
        case .error: break
        }
    }
}
