//
//  SettingsViewController+TableView.swift
//  Notifire
//
//  Created by David Bielik on 14/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel.row(at: indexPath)
        switch row {
        case .changeEmail:
            delegate?.didSelectChangeEmailButton()
        case .changePassword:
            delegate?.didSelectChangePasswordButton()
        case .privacyPolicy:
            delegate?.didSelectPrivacyPolicyButton()
        case .contact:
            delegate?.didSelectContactButton()
        case .logout:
            promptLogout()
        case .goToSettingsButton:
            URLOpener.goToNotificationSettings()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch viewModel.section(at: section) {
        case .generalLast, .userLogout, .notifications: return UITableView.automaticDimension
        case .user, .general, .notificationStatus: return CGFloat.leastNonzeroMagnitude
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UITableViewHeaderFooterView()
    }

    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if viewModel.section(at: section) == .generalLast, let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textAlignment = .center
        }
    }
}
