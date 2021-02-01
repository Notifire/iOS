//
//  ServiceViewController.swift
//  Notifire
//
//  Created by David Bielik on 20/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit
import Photos

protocol SectionDefining {
    func numberOfRows() -> Int
    func heightForRow() -> Int
    var asIndexPath: IndexPath { get }
}

enum ServiceSection {
    case notificationLevels
    case serviceAPIKey
    case deleteNotifications
    case deleteService
}

protocol ServiceViewControllerDelegate: class {
    func shouldShowNotifications(for service: LocalService)
    func shouldPresentEditServiceView(for service: LocalService)
    func shouldDismissServiceViewController()
}

class ServiceViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, NavigationBarDisplaying, NotifireAlertPresenting, ErrorStatePresentable {

    // MARK: - Properties
    let viewModel: ServiceViewModel
    weak var delegate: ServiceViewControllerDelegate?

    // MARK: ErrorStatePresentable
    var emptyStateView: ErrorEmptyStateView?

    // MARK: Views
    let parentScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.showsVerticalScrollIndicator = false
        scroll.contentInsetAdjustmentBehavior = .always
        scroll.delaysContentTouches = false
        return scroll
    }()

    let titleLabel: UILabel = {
        let label = UILabel(style: .heavyTitle)
        label.alpha = 0
        return label
    }()

    let serviceHeaderView = ServiceHeaderView()

    lazy var notificationsHeaderView: ServiceNotificationsHeaderView = {
        let view = ServiceNotificationsHeaderView()
        view.notificationsButton.onProperTap = { [unowned self] _ in
            guard let localService = self.viewModel.currentLocalService else { return }
            self.delegate?.shouldShowNotifications(for: localService)
        }
        return view
    }()

    lazy var tableView: DynamicTableView = {
        let table = DynamicTableView(frame: .zero, style: .grouped)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .compatibleBackgroundAccent
        table.mask = tableViewMaskView
        table.estimatedRowHeight = Size.Cell.height
        table.register(cells: [NotificationLevelTableViewCell.self, ServiceTableViewCell.self, ServiceAPIKeyTableViewCell.self])
        return table
    }()

    let tableViewMaskView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .blue
        return view
    }()

    var childScrollView: UIScrollView {
        return tableView
    }

    func levelCell(level: NotificationLevel, serviceLevelKeyPath: ReferenceWritableKeyPath<LocalService, Bool>) -> NotificationLevelTableViewCell {
        let cell = NotificationLevelTableViewCell()
        cell.model = NotificationLevelModel(level: level, enabled: viewModel.currentLocalService?[keyPath: serviceLevelKeyPath] ?? false)
        cell.onLevelChange = { [unowned self] enabled in
            self.viewModel.updateService {
                self.viewModel.currentLocalService?[keyPath: serviceLevelKeyPath] = enabled
            }
        }
        return cell
    }

    lazy var infoCell = levelCell(level: .info, serviceLevelKeyPath: \.info)
    lazy var warningCell = levelCell(level: .warning, serviceLevelKeyPath: \.warning)
    lazy var errorCell = levelCell(level: .error, serviceLevelKeyPath: \.error)

    var gradientLayer: NotifireBackgroundLayer?

    // MARK: - Initialization
    init(viewModel: ServiceViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatibleBackgroundAccent
        hideNavigationBarBackButtonText()
        setupTitleView()
        prepareViewModel()
        layout()
        addScrollViewGradientLayer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateGradient()
        let y = parentScrollView.contentOffset.y + parentScrollView.adjustedContentInset.top
        let headerViewTopY = y - notificationsHeaderView.frame.origin.y
        let maskViewY = headerViewTopY - notificationsHeaderView.bounds.height/2
        tableViewMaskView.frame = CGRect(origin: CGPoint(x: 0, y: maskViewY), size: CGSize(width: tableView.bounds.width, height: tableView.bounds.height-maskViewY))

        // fix for serviceHeaderView and notificationsHeaderView not having their correct frame on the first layout pass
        serviceHeaderView.setNeedsLayout()
        serviceHeaderView.layoutIfNeeded()
        notificationsHeaderView.setNeedsLayout()
        notificationsHeaderView.layoutIfNeeded()

        guard viewModel.isFirstAppearance else { return }
        viewModel.isFirstAppearance = false
        viewModel.start()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // set the delegate after getting presented to the screen
        parentScrollView.delegate = self
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        guard
            #available(iOS 13.0, *),
            traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection),
            let gradient = gradientLayer
        else { return }
        gradient.resetGradientColors()
    }

    // MARK: - Private
    private func setupTitleView() {
        let titleLabelContainerView = UIView()
        titleLabelContainerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabelContainerView.add(subview: titleLabel)
        titleLabel.topAnchor.constraint(equalTo: titleLabelContainerView.topAnchor).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: titleLabelContainerView.bottomAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: titleLabelContainerView.centerXAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: titleLabelContainerView.widthAnchor, multiplier: 0.6).isActive = true
        titleLabelContainerView.layoutIfNeeded()
        titleLabelContainerView.sizeToFit()
        titleLabelContainerView.translatesAutoresizingMaskIntoConstraints = true
        navigationItem.titleView = titleLabelContainerView
    }

    private func prepareViewModel() {
        viewModel.onViewStateChange = { [weak self] old, new in
            self?.updateAppearance(old: old, new: new)
        }
        viewModel.onServiceUpdate = { [weak self] localService in
            self?.updateServiceUI(service: localService)
        }
        viewModel.onServiceShouldClose = { [weak self] in
            self?.delegate?.shouldDismissServiceViewController()
        }
    }

    private func layout() {
        view.add(subview: parentScrollView)
        parentScrollView.embed(in: view)

        let content = UIView()
        parentScrollView.add(subview: content)
        content.topAnchor.constraint(equalTo: parentScrollView.topAnchor).isActive = true
        content.leadingAnchor.constraint(equalTo: parentScrollView.leadingAnchor).isActive = true
        content.trailingAnchor.constraint(equalTo: parentScrollView.trailingAnchor).isActive = true
        // priorities for tableview scrolling to function properly
        let contentBottomToScrollBottom = content.bottomAnchor.constraint(equalTo: parentScrollView.bottomAnchor)
        contentBottomToScrollBottom.priority = UILayoutPriority(rawValue: 250)
        contentBottomToScrollBottom.isActive = true
        let contentYCenterToScrollViewYCenter = content.centerYAnchor.constraint(equalTo: parentScrollView.centerYAnchor)
        contentYCenterToScrollViewYCenter.priority = UILayoutPriority(rawValue: 250)
        contentYCenterToScrollViewYCenter.isActive = true
        content.centerXAnchor.constraint(equalTo: parentScrollView.centerXAnchor).isActive = true

        content.add(subview: serviceHeaderView)
        serviceHeaderView.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
        serviceHeaderView.leadingAnchor.constraint(equalTo: content.leadingAnchor).isActive = true
        serviceHeaderView.trailingAnchor.constraint(equalTo: content.trailingAnchor).isActive = true

        content.add(subview: tableView)
        tableView.leadingAnchor.constraint(equalTo: content.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: content.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true

        content.add(subview: notificationsHeaderView)
        notificationsHeaderView.leadingAnchor.constraint(equalTo: content.leadingAnchor).isActive = true
        notificationsHeaderView.trailingAnchor.constraint(equalTo: content.trailingAnchor).isActive = true
        notificationsHeaderView.centerYAnchor.constraint(equalTo: serviceHeaderView.bottomAnchor).isActive = true
        notificationsHeaderView.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
    }

    private func addScrollViewGradientLayer() {
        guard gradientLayer == nil else { return }
        let gradient = NotifireBackgroundLayer()
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }

    private func updateAppearance(old: ServiceViewModel.ViewState, new: ServiceViewModel.ViewState) {
        switch viewModel.viewState {
        case .loading:
            parentScrollView.isUserInteractionEnabled = false
            parentScrollView.alpha = 0
            navigationItem.rightBarButtonItem = nil
        case .error(let error):
            switch error {
            case .apiError(let error):
                addErrorStateView(title: error.userFriendlyMessage) { [weak self] in
                    self?.viewModel.start()
                }
            case .serviceCreationError:
                addErrorStateView(title: "Unknown error encountered", onRetry: nil)
            }
        case .displaying(let localService):
            updateServiceUI(service: localService)
            UIView.animate(withDuration: 0.2, animations: {
                if self.emptyStateView != nil {
                    // Previous state was error, remove it
                    self.removeEmptyStateView()
                }
                self.parentScrollView.alpha = 1
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_more_horiz_black_24pt"), style: .plain, target: self, action: #selector(self.didTapMoreOptions))
            }, completion: { finished in
                guard finished else { return }
                self.parentScrollView.isUserInteractionEnabled = true
            })
        }
    }

    private func updateServiceUI(service: LocalService) {
        titleLabel.text = service.name
        serviceHeaderView.service = service
        infoCell.levelSwitch.setOn(service.info, animated: true)
        warningCell.levelSwitch.setOn(service.warning, animated: true)
        errorCell.levelSwitch.setOn(service.error, animated: true)
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
    }

    // MARK: Event Handlers
    @objc private func didTapMoreOptions() {
        let options = UIAlertController(title: "", message: "Service options", preferredStyle: .actionSheet)
        options.addAction(UIAlertAction(title: "Edit service", style: .default, handler: { [weak self] _ in
            guard let service = self?.viewModel.currentLocalService else { return }
            self?.delegate?.shouldPresentEditServiceView(for: service)
        }))
        options.addAction(UIAlertAction(title: "Set default image", style: .default, handler: { [weak self] _ in
            self?.viewModel.setDefaultImage()
        }))
        options.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            options.dismiss(animated: true, completion: nil)
        }))
        present(options, animated: true, completion: nil)
    }
}

extension ServiceViewController: ServiceAPIKeyCellDelegate {
    func shouldReloadServiceCell() {
        viewModel.isKeyVisible = !viewModel.isKeyVisible
        tableView.reloadRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
    }
}

extension ServiceViewController: ScrollViewReselectable {
    var scrollView: UIScrollView {
        return parentScrollView
    }

    var topContentOffset: CGPoint {
        return CGPoint(x: 0, y: -parentScrollView.adjustedContentInset.top)
    }
}
