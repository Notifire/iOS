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

    private lazy var dataSource = SettingsTableViewDataSource(tableViewViewModel: viewModel)

    // MARK: Views
    lazy var tableView: UITableView = {
        let style: UITableView.Style
        if #available(iOS 13.0, *) {
            style = .insetGrouped
        } else {
            style = .grouped
        }
        let tableView = UITableView(frame: .zero, style: style)
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .compatibleBackgroundAccent
        var contentInsets = UIEdgeInsets.init(everySide: 0)
        contentInsets.bottom = Size.Cell.height
        tableView.contentInset = contentInsets
        tableView.register(cells: [
            UITableViewCenteredNegativeCell.self,
            UITableViewValue1Cell.self,
            SettingsSwitchTableViewCell.self,
            UITableViewReusableCell.self,
            UITableViewActionCell.self,
            UITableViewWarningCell.self
        ])
        return tableView
    }()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        title = viewModel.title
        view.backgroundColor = .compatibleSystemBackground

        // ViewModel
        viewModel.shouldReloadData = { [weak self] in
            self?.tableView.reloadData()
        }

        viewModel.shouldReloadAccountSection = { [weak self] in
            self?.tableView.reloadSections(IndexSet([0]), with: .none)
        }

        // Navigation
        hideNavigationBarBackButtonText()
        showNavigationBar()

        // Layout
        layout()
    }

    // MARK: - Private
    private func layout() {
        view.add(subview: tableView)
        tableView.embedInVerticalSafeArea(in: view)
    }

    func promptLogout() {
        let logoutAlert = UIAlertController(title: "Log out of Notifire?", message: "Are you sure you want to log out? You won't receive any notifications after logging out.", preferredStyle: .alert)
        logoutAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            logoutAlert.dismiss(animated: true, completion: nil)
        }))
        logoutAlert.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
            self.delegate?.didSelectLogoutButton()
        }))
        present(logoutAlert, animated: true, completion: nil)
    }
}
