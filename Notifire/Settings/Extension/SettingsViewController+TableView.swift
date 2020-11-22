//
//  SettingsViewController+TableView.swift
//  Notifire
//
//  Created by David Bielik on 14/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsIn(section: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configuration = viewModel.cellConfiguration(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: configuration).reuseIdentifier, for: indexPath)
        configuration.configure(cell: cell)
        if let preferencesCell = cell as? SettingsSwitchTableViewCell {
            preferencesCell.onCellHeightChange = { [weak self] in
                self?.tableView.beginUpdates()
                self?.tableView.endUpdates()
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionHeaderText(at: section)
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel.row(at: indexPath)
        switch row {
        case .changeEmail:
            delegate?.didSelectChangeEmailButton()
        case .changePassword:
            delegate?.didSelectChangePasswordButton()
        case .frequentlyAskedQuestions:
            delegate?.didSelectFAQButton()
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

    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if viewModel.section(at: section) == .generalLast {
            return viewModel.copyright
        } else {
            return nil
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
