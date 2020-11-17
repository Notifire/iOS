//
//  SettingsViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class SettingsViewController: VMViewController<SettingsViewModel>, NavigationBarDisplaying, TableViewReselectable {

    // MARK: - Properties
    weak var delegate: SettingsViewControllerDelegate?

    // MARK: Views
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .compatibleBackgroundAccent
        var contentInsets = UIEdgeInsets.init(everySide: 0)
        contentInsets.bottom = Size.Cell.height
        tableView.contentInset = contentInsets
        tableView.register(cells: [UITableViewCenteredNegativeCell.self, UITableViewValue1Cell.self, SettingsSwitchTableViewCell.self])
        return tableView
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        title = viewModel.title
        view.backgroundColor = .compatibleSystemBackground

        // Navigation
        hideNavigationBarBackButtonText()

        // Layout
        layout()
        addNavigationBarSeparator()
    }

    // MARK: - Private
    private func layout() {
        view.add(subview: tableView)
        tableView.embedInVerticalSafeArea(in: view)
    }

    func promptLogout() {
        let logoutAlert = UIAlertController(title: "Logout from Notifire?", message: "Are you sure? You won't receive any notifications after logging out.", preferredStyle: .alert)
        logoutAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { _ in
            logoutAlert.dismiss(animated: true, completion: nil)
        }))
        logoutAlert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
            self.delegate?.didSelectLogoutButton()
        }))
        present(logoutAlert, animated: true, completion: nil)
    }
}
