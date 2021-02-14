//
//  NotificationsFilterViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

class NotificationsFilterTableViewDataSource: GenericTableViewDataSource<NotificationsFilterViewModel> {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        // Add checkmark accessory if needed
        let useCheckmark: Bool?
        let model = tableViewViewModel.notificationsFilterData
        let row = tableViewViewModel.row(at: indexPath)
        switch row {
        // Read
        case .showAll:
            useCheckmark = model.readUnreadState == .all
        case .read:
            useCheckmark = model.readUnreadState == .read
        case .unread:
            useCheckmark = model.readUnreadState == .unread
        case .info:
            useCheckmark = model.levels[.info] ?? false
        case .warning:
            useCheckmark = model.levels[.warning] ?? false
        case .error:
            useCheckmark = model.levels[.error] ?? false
        case .url:
            useCheckmark = model.containsURL
        case .additionalText:
            useCheckmark = model.containsAdditionalText
        case .newestFirst:
            useCheckmark = model.sorting == .descending
        case .oldestFirst:
            useCheckmark = model.sorting == .ascending
        default:
            useCheckmark = nil
        }
        if let useCheckmark = useCheckmark {
            cell.accessoryType = useCheckmark ? .checkmark : .none
        }
        return cell
    }
}

class NotificationsFilterViewController: VMViewController<NotificationsFilterViewModel>, NavigationBarDisplaying {

    // MARK: - Properties
    private lazy var dataSource = NotificationsFilterTableViewDataSource(tableViewViewModel: viewModel)

    /// The last indexPath that the user has selected.
    /// Set to nil every time the viewDidAppear is called.
    var lastIndexPathForSelectedRow: IndexPath?

    // MARK: Callback
    /// Called when the user finished filtering notifications.
    /// The parameter contains the `NotificationsFilterData` that the user chose. Otherwise `nil`.
    var onFinishedFiltering: ((NotificationsFilterData?) -> Void)?
    /// Called when the user selects the Timeframe selection row.
    var onTimeframeSelectionPressed: (() -> Void)?

    // MARK: UI
    lazy var doneBarButton = UIBarButtonItem(title: "Apply", style: .done, target: self, action: #selector(self.didPressDoneButton))

    lazy var tableView = UITableView.initGrouped(
        registerCells: [
            UITableViewReusableCell.self,
            UITableViewImageTextCell.self,
            UITableViewLevelCell.self,
            UITableViewCenteredPositiveCell.self,
            DateDisclosureTableViewCell.self
        ],
        dataSource: dataSource,
        delegate: self
    )

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // View
        view.backgroundColor = .compatibleSystemGroupedBackground

        // NavBar
        setupNavBar()

        // ViewModel
        setupViewModel()

        // Layout
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Deselect the row
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }

        // Reload rows that might have changed. E.g. date timeframe row
        if let lastSelectedIndexPath = lastIndexPathForSelectedRow {
            // Do this async to avoid the UITableView off-screen layout warning
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadRows(at: [lastSelectedIndexPath], with: .none)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        lastIndexPathForSelectedRow = nil
    }

    // MARK: - Private
    private func setupNavBar() {
        // Buttons
        doneBarButton.tintColor = .primary
        doneBarButton.isEnabled = false
        navigationItem.rightBarButtonItem = doneBarButton

        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.didPressCancelButton))
        cancelButton.tintColor = .primary
        navigationItem.leftBarButtonItem = cancelButton

        // Title
        title = "Filter notifications"

        hideNavigationBarBackButtonText()
    }

    private func setupViewModel() {
        viewModel.onNotificationsFilterDataChange = { [weak self] isDefaultFilter in
            self?.doneBarButton.isEnabled = !isDefaultFilter
        }
    }

    private func layout() {
        view.add(subview: tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    private func updateDateTimeframeRow() {
        tableView.reloadSections(IndexSet([ViewModel.Section.data.rawValue]), with: .none)
    }

    // MARK: Event Handlers
    @objc private func didPressDoneButton() {
        // Return new filters
        onFinishedFiltering?(viewModel.notificationsFilterData)
    }

    @objc private func didPressCancelButton() {
        // Don't return new filters
        onFinishedFiltering?(nil)
    }
}
