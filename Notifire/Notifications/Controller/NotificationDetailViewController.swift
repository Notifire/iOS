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
        table.allowsSelection = false
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
        setTitle()
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

    private func setTitle() {
        let date = viewModel.notification.date.string(with: .complete)
        var dateComponents = date.components(separatedBy: ",")
        guard dateComponents.count == 2 else { return }
        let hhmm = dateComponents.removeFirst()
        let yymmdd = dateComponents.removeFirst()
        let dateText = NSMutableAttributedString(string: hhmm, attributes: [.font: UIFont.boldSystemFont(ofSize: 17),
                                                                            .foregroundColor: UIColor.compatibleLabel])
        dateText.append(NSAttributedString(string: ","))
        dateText.append(NSAttributedString(string: yymmdd, attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                        .foregroundColor: UIColor.compatibleLabel.withAlphaComponent(0.85)]))
        let dateLabel = UILabel()
        dateLabel.attributedText = dateText
        navigationItem.titleView = dateLabel
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
            urlCell.onURLTap = { url in
                URLOpener.open(url: url)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
}
