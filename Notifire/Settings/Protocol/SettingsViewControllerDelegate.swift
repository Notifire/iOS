//
//  SettingsViewControllerDelegate.swift
//  Notifire
//
//  Created by David Bielik on 14/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import Foundation

/// Conform to this protocol if you wish to receive `SettingsViewController` delegate method calls.
protocol SettingsViewControllerDelegate: class {
    /// Called when the user presses the change email button in settings.
    func didSelectChangeEmailButton()
    /// Called when the user presses the change password button in settings.
    func didSelectChangePasswordButton()
    /// Called when the user presses the logout button in settings.
    func didSelectLogoutButton()
    /// Called when the user presses the logout button in settings.
    func didSelectFAQButton()
    /// Called when the user presses the FAQ button in settings.
    func didSelectTOSButton()
    /// Called when the user presses the contact button in settings.
    func didSelectContactButton()
}
