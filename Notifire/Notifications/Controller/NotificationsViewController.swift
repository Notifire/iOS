//
//  NotificationsViewController.swift
//  Notifire
//
//  Created by David Bielik on 30/01/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol NotificationsViewControllerDelegate: class {
    /// Called when the notification should be presented in detail. e.g. push NotificationDetailVC
    func didSelect(notification: LocalNotifireNotification)
    func getNotificationDetailVC(notification: LocalNotifireNotification) -> NotificationDetailViewController
}

class UnreadNotificationsLabel: UILabel {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        clipsToBounds = true
        numberOfLines = 0
        textAlignment = .center
        backgroundColor = .primary
        textColor = .white
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}

class NotificationsViewController: UIViewController, NavigationBarDisplaying, EmptyStatePresentable, TableViewReselectable {

    // MARK: - Properties
    let viewModel: NotificationsViewModel

    weak var delegate: NotificationsViewControllerDelegate?

    /// Used to properly calculate the contentOffset and contentSize after adding new elements to the
    /// table view.
    var heightDictionary: [String: CGFloat] = [:]

    // MARK: Callback
    /// Called when the user taps the filter rightBarButtonItem.
    var onFilterActionTapped: (() -> Void)?

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
        setupNavBar()
        view.backgroundColor = .compatibleSystemBackground

        prepareViewModel()
        layout()
        updateViewStateAppearance(state: viewModel.viewState)
        addNavigationBarSeparator()
    }

    // MARK: - Private
    private func setupNavBar() {
        if !viewModel.collection.isEmpty {
            updateRightBarButtonItem()
        }
        hideNavigationBarBackButtonText(newBackBarText: "Notifications")
        hideNavigationBar()

        title = viewModel.title()
    }

    private func updateRightBarButtonItem() {
        let filterImage: UIImage
        if #available(iOS 13, *) {
            let weight = viewModel.notificationsFilterData.isDefaultFilterData ? UIImage.SymbolWeight.regular : .bold
            let symbolConfiguration = UIImage.SymbolConfiguration(weight: weight)
            filterImage = UIImage(systemName: "slider.horizontal.3", withConfiguration: symbolConfiguration) ?? UIImage()
        } else {
            filterImage = #imageLiteral(resourceName: "slider.horizontal.3").resized(to: Size.Navigator.symbolSize)
        }
        let barButtonItem = ActionButton.createActionBarButtonItem(image: filterImage, target: self, action: #selector(didPressFilterButton))
        barButtonItem.tintColor = viewModel.notificationsFilterData.isDefaultFilterData ? .compatibleLabel : .primary
        navigationItem.rightBarButtonItem = barButtonItem
    }

    private func layout() {
        view.add(subview: tableView)
        tableView.embedInVerticalSafeArea(in: view)
    }

    private func prepareViewModel() {
        let configurationType = type(of: viewModel).configurationType
        tableView.register(configurationType.cellType, forCellReuseIdentifier: configurationType.reuseIdentifier)
        // ViewState
        viewModel.onViewStateChange = { [weak self] state in
            self?.updateViewStateAppearance(state: state)
        }

        viewModel.onCollectionUpdate = { [weak self] change in
            guard let tableView = self?.tableView else { return }
            switch change {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // If we're doing a manual delete e.g. when the user has filtering for
                // unread only notifications, make sure to use begin/end updates
                // or
                // If the tableView isn't covering the entire screen
                if !deletions.isEmpty || (tableView.contentSize.height < tableView.bounds.height) {
                    let shouldReloadRows = deletions.isEmpty
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .top)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .top)
                    if shouldReloadRows {
                        tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                             with: .fade)
                    }
                    tableView.endUpdates()
                } else {
                    tableView.reloadDataWithoutMoving()
                    tableView.flashScrollIndicators()
                }
            case .error: break
            }
        }

        // Filters
        viewModel.onNotificationsFilterDataChange = { [weak self] in
            self?.updateRightBarButtonItem()
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

    // MARK: Event Handling
    @objc private func didPressFilterButton() {
        onFilterActionTapped?()
    }

    func showNotificationDetailVC(notification: LocalNotifireNotification) {
        viewModel.markAsRead(notification: notification)
        delegate?.didSelect(notification: notification)
    }
}
