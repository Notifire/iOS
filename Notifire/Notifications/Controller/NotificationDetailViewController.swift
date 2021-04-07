//
//  NotificationDetailViewController.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotificationDetailViewController: VMViewController<NotificationDetailViewModel>, PreferredContentSizeAutochanging, NavigationBarDisplaying, NotifireAlertPresenting {

    // MARK: - Properties
    /// Used to update the back bar button image. Set during viewDidLoad.
    weak var previousNavigationItem: UINavigationItem?

    // MARK: Views
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .compatibleSystemBackground
        table.removeLastSeparatorAndDontShowEmptyCells()
        table.contentInsetAdjustmentBehavior = .always
        table.alwaysBounceVertical = false
        return table
    }()

    let navigationBarSeparator: HairlineView = {
        let separator = HairlineView()
        // Don't show the separator initially
        separator.alpha = 0
        return separator
    }()

    // MARK: SeparatorAnimation
    lazy var separatorAnimator: ScrollViewSeparatorAnimator = {
        let animator = ScrollViewSeparatorAnimator()
        animator.separator = navigationBarSeparator
        return animator
    }()

    // MARK: PreferredContentSizeAutochanging
    var preferredContentSizeObserver: NSKeyValueObservation?
    var contentSizeView: UIScrollView { return tableView }

    // MARK: - View Lifecycle
    deinit {
        invalidatePreferredContentSizeObserver()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .compatibleSystemBackground
        title = "Notification"

        // Add gestureRecognizer to view to deselect textview selections
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)

        prepareViewModel()
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()

        // Initial number of unread notifications in backbarbuttonitem
        updateBackBarButtonItem()

        createAndSetPreferredContentSizeObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        viewModel.bumpNumberOfReadNotificationsInSettings()

        guard viewModel.notification.safeReference == nil else { return }
        // Pop this VC if the notification has been deleted
        viewModel.delegate?.onNotificationDeletion()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        invalidatePreferredContentSizeObserver()
    }

    // MARK: - Private
    private func updateBackBarButtonItem() {
        guard let numberUnread = viewModel.unreadNotificationsObserver?.currentUnreadCount else { return }
        if numberUnread > 0 {
            // Show labelled image
            previousNavigationItem?.backBarButtonItem = UIBarButtonItem(
                image: UIImage.labelledImage(with: "\(numberUnread)", font: UIFont.systemFont(ofSize: 12, weight: .medium)).withRenderingMode(.alwaysOriginal),
                style: .done,
                target: nil,
                action: nil
            )
        } else {
            // Hide labelled image
            previousNavigationItem?.backBarButtonItem = nil
        }
    }

    private func prepareViewModel() {
        // Register cells
        viewModel.items.forEach { tableView.register(type(of: $0).cellType, forCellReuseIdentifier: type(of: $0).reuseIdentifier)}

        viewModel.unreadNotificationsObserver?.onNumberNotificationsChange = { [weak self] _ in
            self?.updateBackBarButtonItem()
        }
    }

    private func layout() {
        view.add(subview: tableView)
        tableView.embedInVerticalSafeArea(in: view)
        tableView.embedSides(in: view)

        view.add(subview: navigationBarSeparator)
        navigationBarSeparator.bottomAnchor.constraint(equalTo: tableView.topAnchor).isActive = true
        navigationBarSeparator.embedSides(in: view)
    }

    // MARK: Event Handlers
    @objc private func didTapView() {
        view.endEditing(true)
    }
}

extension NotificationDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: item).reuseIdentifier, for: indexPath)
        item.configure(cell: cell)
        var newLayoutMargins = UIEdgeInsets(everySide: Size.Cell.narrowSideMargin)
        newLayoutMargins.left = Size.Cell.wideSideMargin
        cell.contentView.layoutMargins = newLayoutMargins
        cell.separatorInset.left = newLayoutMargins.left
        cell.backgroundColor = .compatibleSystemBackground
        if let urlCell = cell as? NotificationDetailURLCell {
            // Default tap
            urlCell.onURLTap = { url in
                URLOpener.open(url: url)
            }

            // Context Interaction
            if
                #available(iOS 13, *),
                let url = viewModel.notification.additionalURL,
                let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                components.scheme == "http" || components.scheme == "https" || components.scheme == nil
            {
                // Add ContextMenuInteraction if the URL can be opened via safari
                let urlInteraction = UIContextMenuInteraction(delegate: self)
                urlCell.urlLabel.addInteraction(urlInteraction)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
}

extension NotificationDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.items[indexPath.row]
        if item is NotificationDetailHeaderConfiguration, let cell = tableView.cellForRow(at: indexPath) as? NotificationDetailHeaderCell {
            cell.dateStyle.swapStyle()
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Animate the separator if needed
        separatorAnimator.handleScrollViewDidScroll(scrollView)
    }
}

@available(iOS 13, *)
extension NotificationDetailViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: createURLPreviewProvider,
            actionProvider: { _ in
                // Copy URL
                let copyURLAction = UIAction(
                    title: "Copy URL",
                    image: UIImage(systemName: "doc.on.doc")) { [weak self] _ in
                    guard let urlString = self?.viewModel.notification.urlString else { return }
                    UIPasteboard.general.string = urlString
                }
                return UIMenu(title: "", image: nil, children: [copyURLAction])
            }
        )
    }

    func createURLPreviewProvider() -> UIViewController? {
        let viewController = PrivacyPolicyViewController()
        guard let url = viewModel.notification.additionalURL?.safeToOpenWithSafari else { return nil }
        viewController.request = URLRequest(url: url)
        return viewController
    }

    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        animator.addCompletion { [weak self] in
            guard let url = self?.viewModel.notification.additionalURL else { return }
            URLOpener.open(url: url)
        }
    }
}
