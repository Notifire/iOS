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
    private var userInteractivePopObserver: NSKeyValueObservation?
    private var userInteractivePopInProgress: Bool = false
    private var userWasInteractingWithVCOnNavBarReload: Bool = false

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
        prepareViewModel()
        layout()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()

        if userInteractivePopObserver == nil {
            userInteractivePopObserver = navigationController?.interactivePopGestureRecognizer?.observe(\.state, options: .new, changeHandler: { [weak self] (recognizer, _) in
                guard let `self` = self else { return }
                switch recognizer.state {
                case .began, .changed, .possible:
                    self.userInteractivePopInProgress = true
                default:
                    guard self.userInteractivePopInProgress, self.userWasInteractingWithVCOnNavBarReload else {
                        self.userInteractivePopInProgress = false
                        return
                    }
                    self.userInteractivePopInProgress = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                        self?.updateBackBarButtonItem()
                    }
                }
            })
        }

        // Initial number of unread notifications in backbarbuttonitem
        updateBackBarButtonItem()

        createAndSetPreferredContentSizeObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

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
        guard let navigationController = navigationController else { return }

        // Make sure that the user is not interacting right now, otherwise flag this event
        guard !userInteractivePopInProgress else {
            self.userWasInteractingWithVCOnNavBarReload = true
            return
        }
        self.userWasInteractingWithVCOnNavBarReload = false

        // Important
        // `popViewController` is used here as a hack to be able to change
        // the navigationBar's `topItem?.backBarButtonItem`
        navigationController.popViewController(animated: false)
        if let numberUnread = viewModel.unreadNotificationsObserver?.currentUnreadCount, numberUnread != 0 {
            let image = UIImage.labelledImage(with: "\(numberUnread)", font: UIFont.systemFont(ofSize: 12, weight: .medium)).withRenderingMode(.alwaysOriginal)
            let roundedBarButtonItem = UIBarButtonItem(image: image, style: UIBarButtonItem.Style.done, target: nil, action: nil)
            navigationController.navigationBar.topItem?.backBarButtonItem = roundedBarButtonItem
        } else {
            navigationController.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
        }
        navigationController.pushViewController(self, animated: false)
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
        tableView.embed(in: view)
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
            if #available(iOS 13, *) {
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
        guard let url = viewModel.notification.additionalURL else { return nil }
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
