//
//  NotificationsRequirementViewModel.swift
//  Notifire
//
//  Created by David Bielik on 22/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

class NotificationsRequirementViewModel: ViewModelRepresenting {

    enum ViewState: Equatable {
        case showingNotificationRequirement
        case showingDeviceTokenPermissionState(DeviceTokenManager.NotificationPermissionsState)
    }

    // MARK: - Properties
    let deviceTokenManager: DeviceTokenManager
    let stateModel = StateModel(defaultValue: ViewState.showingNotificationRequirement)

    var notificationPermissionsObserver: NotificationObserver?

    // MARK: Callback
    var onSuccess: (() -> Void)?

    // MARK: - Initialization
    init(deviceTokenManager: DeviceTokenManager) {
        self.deviceTokenManager = deviceTokenManager
    }

    // MARK: - Methods
    func start() {
        notificationPermissionsObserver = NotificationObserver(notificationName: .didChangeNotificationPermissionsState, notificationHandler: { [weak self] _ in
            guard
                let `self` = self,
                case .showingDeviceTokenPermissionState = self.stateModel.state
            else { return }
            let newState: ViewState = .showingDeviceTokenPermissionState(self.deviceTokenManager.stateModel.state)
            self.stateModel.state = newState

            // Success if the settings remain the same after +1 seconds
            if newState == .showingDeviceTokenPermissionState(.obtainedUserNotificationAuthorization(status: .authorized)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    guard newState == self?.stateModel.state else { return }
                    self?.onSuccess?()
                }
            }
        })
    }

    /// Request user's permissions (opens the system allow/don'tallow notification alert)
    func requestUserPermissions() {
        guard case .showingNotificationRequirement = stateModel.state else { return }
        deviceTokenManager.requestUserNotificationAuthorization()
        stateModel.state = .showingDeviceTokenPermissionState(deviceTokenManager.stateModel.state)
    }
}
