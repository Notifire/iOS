//
//  ServicesViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import SkeletonView

class ServicesTableView: UITableView {

    /// Whether this tableView is currently scrolling or not.
    public var isScrolling: Bool = false

    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        rowHeight = Size.Cell.heightExtended
        estimatedRowHeight = Size.Cell.heightExtended
        removeLastSeparatorAndDontShowEmptyCells()
        backgroundColor = .compatibleBackgroundAccent
        contentInsetAdjustmentBehavior = .never
        isSkeletonable = true
        register(reusableHeaderFooter: ServicesTableViewFooterView.self)
        register(cells: [ServiceTableViewCell.self, PaginationLoadingTableViewCell.self])
    }
}

class ServicesViewController: VMViewController<ServicesViewModel>, NavigationBarDisplaying, EmptyStatePresentable, TableViewReselectable, APIErrorPresenting, APIErrorResponding {

    // MARK: - Properties
    weak var delegate: ServicesViewControllerDelegate?

    private var isInitialLoad: Bool = true

    // MARK: Views
    lazy var servicesTableView: ServicesTableView = {
        let tv = ServicesTableView()
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()

    var connectionStatusView: ServicesWebSocketConnectionStatusView?

    // MARK: EmptyStatePresentable
    typealias EmptyStateView = ServicesEmptyStateView
    var emptyStateView: EmptyStateView?

    // MARK: TableViewReselectable
    var tableView: UITableView {
        return servicesTableView
    }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Navigation
        title = "Services"
        hideNavigationBarBackButtonText()
        hideNavigationBar()

        // View
        view.backgroundColor = .compatibleSystemBackground

        prepareViewModel()
        layout()
        addNavigationBarSeparator()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard isInitialLoad else { return }
        isInitialLoad = false
        updateViewStateAppearance(state: .skeleton, oldState: .skeleton)
        viewModel.start()
    }

    // MARK: - Private
    private func prepareViewModel() {
        viewModel.onViewStateChange = { [weak self] state, oldState in
            self?.updateViewStateAppearance(state: state, oldState: oldState)
        }

        viewModel.onServicesChange = { [weak self] changes in
            guard let `self` = self else { return }

            switch changes {
            case .partial(let changes):
                let currentOffset = self.tableView.contentOffset
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: changes.deletions, with: .automatic)
                self.tableView.insertRows(at: changes.insertions, with: .automatic)
                for move in changes.moves {
                    self.tableView.moveRow(at: move.from, to: move.to)
                }
                self.tableView.reloadRows(at: changes.modifications, with: .automatic)
                if !self.servicesTableView.isScrolling {
                    self.tableView.setContentOffset(currentOffset, animated: false)
                    self.tableView.flashScrollIndicators()
                }
                self.tableView.endUpdates()
                if !changes.moves.isEmpty {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: changes.moves.map({ $0.to }), with: .automatic)
                    self.tableView.endUpdates()
                }
            case .full:
                self.tableView.reloadData()
            }
        }

        viewModel.onIsFetchingChange = { [weak self] fetching in
            guard self?.viewModel.viewState == .displayingServices else { return }
            self?.tableView.reloadSections(IndexSet([1]), with: .automatic)
        }

        viewModel.onConnectionViewStateChange = { [weak self] state in
            guard let `self` = self else { return }

            if self.connectionStatusView == nil {
                self.addConnectionStatusView()
            }

            switch state {
            case .connected:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    // Only remove the connected status view if we're still connected after 2s
                    guard self.viewModel.connectionViewState == .connected else { return }
                    self.connectionStatusView?.hideStatusViewAnimated()
                    self.connectionStatusView = nil
                })
            case .connecting, .offline:
                break
            }

            self.connectionStatusView?.updateStyle(from: state)
        }

        viewModel.onServiceDeletion = { [weak self] id in
            self?.delegate?.didDeleteService(with: id)
        }

        setViewModelOnError()
    }

    private func layout() {
        view.add(subview: tableView)
        tableView.embedInVerticalSafeArea(in: view)
    }

    private func addConnectionStatusView() {
        guard connectionStatusView == nil else { return }
        let connectionStatusView = ServicesWebSocketConnectionStatusView()
        self.connectionStatusView = connectionStatusView

        view.add(subview: connectionStatusView)
        connectionStatusView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        connectionStatusView.embedSides(in: view)
        connectionStatusView.showStatusViewAnimated()
    }

    private func updateViewStateAppearance(state: ServicesViewModel.ViewState, oldState: ServicesViewModel.ViewState) {
        switch (oldState, state) {
        case (_, .skeleton):
            changeVisibilityOfNavigationBarItems(visible: false)
            tableView.showAnimatedGradientSkeleton()
        case (_, .emptyState):
            changeVisibilityOfNavigationBarItems()
            tableView.hideSkeleton()
            if let emptyStateView = addEmptyStateView() {
                emptyStateView.serviceButton.addTarget(self, action: #selector(didSelectAddNewService), for: .touchUpInside)
            }
        case (.skeleton, .displayingServices):
            changeVisibilityOfNavigationBarItems()
            tableView.hideSkeleton()
        case (.emptyState, .displayingServices):
            changeVisibilityOfNavigationBarItems()
            tableView.hideSkeleton()
            removeEmptyStateView()
        default:
            break
        }
    }

    private func changeVisibilityOfNavigationBarItems(visible: Bool = true) {
        if visible {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didSelectAddNewService))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }

    // MARK: - Event Handlers
    @objc private func didSelectAddNewService() {
        delegate?.didSelectCreateService()
    }
}
