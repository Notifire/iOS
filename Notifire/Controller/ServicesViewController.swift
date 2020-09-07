//
//  ServicesViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol ServicesViewControllerDelegate: class {
    func didSelect(service: LocalService)
    func didSelectCreateService()
}

class ServicesViewController: UIViewController, NavigationBarDisplaying, EmptyStatePresentable, TableViewReselectable {

    // MARK: - Properties
    let viewModel: ServicesViewModel
    weak var delegate: ServicesViewControllerDelegate?

    // MARK: Views
    lazy var tableView: UITableView = {
        let tv = UITableView()
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.dontShowEmptyCells()
        tv.separatorInset = .zero
        tv.backgroundColor = .compatibleBackgroundAccent
        tv.register(ServiceTableViewCell.self, forCellReuseIdentifier: ServiceTableViewCell.reuseIdentifier)
        return tv
    }()

    // MARK: EmptyStatePresentable
    typealias EmptyStateView = ServicesEmptyStateView
    var emptyStateView: EmptyStateView?

    // MARK: - Initialization
    init(viewModel: ServicesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        hideNavigationBarBackButtonText()
        hideNavigationBar()
        view.backgroundColor = .compatibleSystemBackground
        title = "Services"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAddNewService))

        prepareViewModel()
        layout()
        addNavigationBarSeparator()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now() + AppRevealSettings.delay + AppRevealSettings.smallScaleUpDuration + AppRevealSettings.scaleDownDuration + AppRevealSettings.finalDuration) {
            self.viewModel.firstServicesFetch()
        }
    }

    // MARK: - Private
    private func prepareViewModel() {
        viewModel.onViewStateChange = { [weak self] state, oldState in
            self?.updateViewStateAppearance(state: state, oldState: oldState)
        }

        viewModel.onCollectionUpdate = { [weak self] change in
            guard let tableView = self?.tableView else { return }
            switch change {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .none)
                tableView.endUpdates()
            case .error: break
            }
        }
    }

    private func layout() {
        view.add(subview: tableView)
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .compatibleLabel
        refreshControl.addTarget(self, action: #selector(didChangeRefreshValue), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    private func updateViewStateAppearance(state: ServicesViewModel.ViewState, oldState: ServicesViewModel.ViewState) {
        switch (state, oldState) {
        case (.fetching, .initial), (.fetching, .emptyState):
            break
        case (.emptyState, _):
            if let emptyStateView = addEmptyState() {
                emptyStateView.serviceButton.addTarget(self, action: #selector(didSelectAddNewService), for: .touchUpInside)
            }
        case (.displayingServices, .emptyState):
            removeEmptyState()
        case (.displayingServices, .fetching):
            tableView.refreshControl?.endRefreshing()
        default: break
        }
    }

    // MARK: - Event Handlers
    @objc private func didChangeRefreshValue() {
        guard !tableView.isDragging else { return }
        viewModel.fetchUserServices()
    }

    @objc private func didSelectAddNewService() {
        delegate?.didSelectCreateService()
    }
}

class ServiceTableViewCell: BaseTableViewCell {
    // MARK: - Properties
    // MARK: Static
    static let reuseIdentifier = "ServiceTableViewCell"

    // MARK: Views
    let serviceImageView = RoundedImageView()
    let serviceNameLabel = UILabel(style: .semiboldCellTitle)
    let unreadNotificationsLabel = UILabel(style: .cellSubtitle)

    // MARK: Inherited
    override func setup() {
        contentView.layoutMargins = UIEdgeInsets(top: Size.Cell.extendedSideMargin/2, left: Size.Cell.extendedSideMargin, bottom: Size.Cell.extendedSideMargin/2, right: 0)
        accessoryType = .disclosureIndicator
        backgroundColor = .compatibleSystemBackground
        layout()
    }

    // MARK: Private
    private func layout() {
        contentView.add(subview: serviceImageView)
        serviceImageView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor).isActive = true
        serviceImageView.heightAnchor.constraint(equalToConstant: Size.Image.mediumService).isActive = true
        serviceImageView.widthAnchor.constraint(equalTo: serviceImageView.heightAnchor).isActive = true
        let imageTopConstraint = serviceImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor)
        imageTopConstraint.priority = UILayoutPriority(rawValue: 999)
        imageTopConstraint.isActive = true
        serviceImageView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor).isActive = true

        contentView.add(subview: serviceNameLabel)
        serviceNameLabel.leadingAnchor.constraint(equalTo: serviceImageView.trailingAnchor, constant: Size.Cell.extendedSideMargin/2).isActive = true
        serviceNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        contentView.add(subview: unreadNotificationsLabel)
        unreadNotificationsLabel.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor).isActive = true
        unreadNotificationsLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        unreadNotificationsLabel.leadingAnchor.constraint(equalTo: serviceNameLabel.trailingAnchor).isActive = true
        unreadNotificationsLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }

    func configure(from service: LocalService) {
        serviceImageView.image = service.image
        serviceNameLabel.text = service.name
        let unreadCount = service.notifications.filter(LocalNotifireNotification.isReadPredicate).count
        let unreadText = unreadCount == 0 ? "" : "\(unreadCount)"
        unreadNotificationsLabel.text = unreadText
    }
}

// MARK: - UITableViewDataSource
extension ServicesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.collection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ServiceTableViewCell.reuseIdentifier, for: indexPath) as? ServiceTableViewCell else {
            return UITableViewCell()
        }
        let service = viewModel.collection[indexPath.row]
        cell.configure(from: service)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ServicesViewController: UITableViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if tableView.refreshControl?.isRefreshing ?? false {
            viewModel.fetchUserServices()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let service = viewModel.collection[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(service: service)
    }
}
