//
//  NotificationsViewController.swift
//  Notifire
//
//  Created by David Bielik on 30/01/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol NotificationsViewControllerDelegate: class {
    func didSelect(notification: LocalNotifireNotification)
}

class NotificationsViewController: UIViewController, NavigationBarDisplaying, EmptyStatePresentable, TableViewReselectable {

    // MARK: - Properties
    let viewModel: NotificationsViewModel
    weak var delegate: NotificationsViewControllerDelegate?

    // MARK: Views
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.separatorInset = .zero
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = UITableView.automaticDimension
        table.estimatedSectionFooterHeight = 0
        table.estimatedSectionHeaderHeight = 0
        table.backgroundColor = .compatibleBackgroundAccent
        table.dontShowEmptyCells()
        return table
    }()

    // MARK: EmptyStatePresentable
    var emptyStateView: NotificationsEmptyStateView?
    typealias EmptyStateView = NotificationsEmptyStateView

    // MARK: - Initialization
    init(viewModel: NotificationsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title()
        view.backgroundColor = .compatibleSystemBackground
        hideNavigationBarBackButtonText()
        hideNavigationBar()
        prepareViewModel()
        layout()
        updateViewStateAppearance(state: viewModel.viewState)
        addNavigationBarSeparator()
    }

    // MARK: - Private
    private func layout() {
        view.add(subview: tableView)
        tableView.embedInVerticalSafeArea(in: view)
    }

    private func prepareViewModel() {
        let configurationType = type(of: viewModel).configurationType
        tableView.register(configurationType.cellType, forCellReuseIdentifier: configurationType.reuseIdentifier)
        viewModel.onViewStateChange = { [weak self] state in
            self?.updateViewStateAppearance(state: state)
        }

        viewModel.onCollectionUpdate = { [weak self] change in
            guard let tableView = self?.tableView else { return }
            switch change {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                guard tableView.contentSize.height >= tableView.bounds.height else {
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .top)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .bottom)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                         with: .fade)
                    tableView.endUpdates()
                    return
                }
                tableView.reloadDataWithoutMoving()
            case .error: break
            }
        }
    }

    private func updateViewStateAppearance(state: NotificationsViewModel.ViewState) {
        switch state {
        case .empty:
            let emptyState = addEmptyStateView()
            emptyState?.set(title: viewModel.emptyTitle(), text: viewModel.emptyText())
        case .notifications:
            removeEmptyStateView()
        }
    }
}

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(notification: viewModel.collection[indexPath.row])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = viewModel.collection[indexPath.row]
        let isRead = notification.isRead
        let changeReadAction = UIContextualAction(style: .normal, title: isRead ? "Unread" : "Read") { [weak self] (_, _, completion) in
            self?.viewModel.swapNotificationReadUnread(notification: notification)
            completion(true)
            (tableView.cellForRow(at: indexPath) as? NotificationPresenting)?.updateNotificationReadView(from: notification)
        }
        changeReadAction.backgroundColor = .primary
        changeReadAction.image = isRead ? #imageLiteral(resourceName: "baseline_email_black_48pt").withRenderingMode(.alwaysTemplate) :  #imageLiteral(resourceName: "baseline_drafts_black_48pt").withRenderingMode(.alwaysTemplate)
        let config = UISwipeActionsConfiguration(actions: [changeReadAction])
        return config
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.collection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configuration = viewModel.cellConfiguration(for: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: configuration).reuseIdentifier, for: indexPath)
        configuration.configure(cell: cell)
        return cell
    }
}
