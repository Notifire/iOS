//
//  NotificationsRequirementViewController.swift
//  Notifire
//
//  Created by David Bielik on 21/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

class NotificationsRequirementViewController: VMViewController<NotificationsRequirementViewModel> {

    // MARK: - Properties
    // MARK: UI
    lazy var headerLabel = UILabel(style: .title, text: "First things first...", alignment: .left)

    lazy var warningView: WarningView = {
        let view = WarningView()
        view.warningTitleText = "Enable notifications"
        view.warningText = "Notifications must be enabled for Notifire. Make sure to enable them in the following system alert."
        return view
    }()

    lazy var confirmButton: NotifireButton = {
        let button = NotifireButton()
        let insets = button.contentEdgeInsets
        button.contentEdgeInsets = UIEdgeInsets(top: insets.top, left: Size.standardMargin, bottom: insets.bottom, right: Size.standardMargin)
        button.setTitle("I understand", for: .normal)
        button.onProperTap = { [weak self] _ in
            self?.viewModel.requestUserPermissions()
        }
        return button
    }()

    lazy var goToSettingsButton: ActionButton = {
        let button = ActionButton.createActionButton(text: "Go to Settings") { _ in
            URLOpener.goToNotificationSettings()
        }
        button.alpha = 0
        return button
    }()

    lazy var statusView: PermissionStatusView = {
        let view = PermissionStatusView()
        view.statusText = .statusDependent({ status in
            switch status {
            case .allowed: return "Notifications enabled"
            case .notAllowed: return "Notifications disabled"
            case .waiting: return "Checking notification permissions..."
            }
        })
        view.alpha = 0
        return view
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .compatibleSystemBackground

        setupSubviews()

        viewModel.stateModel.onStateChange = { [weak self] old, new in
            self?.handleStateChange(old, new)
        }
        viewModel.start()
    }

    // MARK: - Private
    private func setupSubviews() {
        view.add(subview: headerLabel)
        headerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        headerLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: Size.componentWidthRelativeToScreenWidth).isActive = true
        headerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Size.Navigator.height * 2).isActive = true

        view.add(subview: warningView)
        warningView.centerXAnchor.constraint(equalTo: headerLabel.centerXAnchor).isActive = true
        warningView.widthAnchor.constraint(equalTo: headerLabel.widthAnchor).isActive = true
        warningView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: Size.componentSpacing * 3).isActive = true

        view.add(subview: statusView)
        statusView.embedSidesInMargins(in: warningView)
        statusView.topAnchor.constraint(equalTo: warningView.bottomAnchor, constant: Size.componentSpacing * 2).isActive = true

        view.add(subview: goToSettingsButton)
        goToSettingsButton.centerXAnchor.constraint(equalTo: statusView.centerXAnchor).isActive = true
        goToSettingsButton.topAnchor.constraint(equalTo: statusView.bottomAnchor, constant: Size.componentSpacing).isActive = true

        view.add(subview: confirmButton)
        confirmButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Size.componentSpacing).isActive = true
    }

    private func handleStateChange(_ old: ViewModel.ViewState, _ new: ViewModel.ViewState) {
        switch (old, new) {
        case (.showingNotificationRequirement, .showingDeviceTokenPermissionState):
            UIView.animate(withDuration: 0.3) {
                self.confirmButton.isHidden = true
                self.statusView.alpha = 1
            }
        case (.showingDeviceTokenPermissionState, .showingDeviceTokenPermissionState(let state)):
            switch state {
            case .obtainedUserNotificationAuthorization(.authorized):
                statusView.stateModel.state = .allowed
                goToSettingsButton.alpha = 0
            case .obtainedUserNotificationAuthorization(.denied):
                statusView.stateModel.state = .notAllowed
                goToSettingsButton.alpha = 1
            case .initial, .registeredDevice, .registeredRemoteNotifications, .obtainedUserNotificationAuthorization(status: _):
                statusView.stateModel.state = .waiting
            }
            statusView.updateText()
        default:
            break
        }
    }
}
