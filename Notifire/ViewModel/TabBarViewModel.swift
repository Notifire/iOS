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
    enum NewNotificationsAlertState {
        case shown(numberOfUnreadNotifications: Int)
        case hidden
    }
    // MARK: Model
    var currentTab: Tab? = nil {
        didSet {
            guard let tab = currentTab else { return }
            guard oldValue != tab else {
                onTabReselect?(tab)
                return
            }
            onTabChange?(tab)
        }
    }
    
    var tabs: [Tab] {
        return Tab.allCases
    }
    
    var notificationsAlertState: NewNotificationsAlertState = .hidden {
        didSet {
            onNotificationsAlertStateChange?(notificationsAlertState)
        }
    }
    
    let userSession: NotifireUserSession
    
    // MARK: Callbacks
    var onTabChange: ((Tab) -> Void)?
    var onTabReselect: ((Tab) -> Void)?
    var onNotificationsAlertStateChange: ((NewNotificationsAlertState) -> Void)?
    
    // MARK: - Initialization
    init(sessionHandler: NotifireUserSessionHandler) {
        self.userSession = sessionHandler.userSession
        super.init(realmProvider: sessionHandler)
    }
    
    // MARK: - Inherited
    override func resultsFilterPredicate() -> NSPredicate? {
        return LocalNotifireNotification.isReadPredicate
    }
    
    // MARK: - Internal
    func updateTab(to tab: Tab) {
        currentTab = tab
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
