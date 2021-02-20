//
//  ServicesViewController.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import SkeletonView

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

    // MARK: EmptyStatePresentable
    typealias EmptyStateView = ServicesEmptyStateView
    var emptyStateView: EmptyStateView?

    // MARK: TableViewReselectable
    var tableView: UITableView {
        return servicesTableView
    }

    // MARK: Callback
    /// Called at the end of viewDidAppear.
    var onViewDidAppear: (() -> Void)?

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
        onViewDidAppear?()
    }

    var newInsertedIndexPaths: [IndexPath: Bool] = [:]

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
                for insertion in changes.insertions {
                    self.newInsertedIndexPaths[insertion] = true
                }
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

        viewModel.onServiceDeletion = { [weak self] id in
            self?.delegate?.didDeleteService(with: id)
        }

        setViewModelOnError()
    }

    private func layout() {
        view.add(subview: tableView)
        tableView.embedInVerticalSafeArea(in: view)
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
