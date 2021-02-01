//
//  NotificationDetailViewController.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotificationDetailViewController: VMViewController<NotificationDetailViewModel>, NavigationBarDisplaying, NotifireAlertPresenting {

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

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Mark notification as 'Read' if the user has stayed in the view for at least 2 seconds.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.viewModel.markNotificationAsRead()
        }
    }

    // MARK: - Private
    private func updateBackBarButtonItem() {
        // Make sure that the user is not interacting right now, otherwise flag this event
        guard !userInteractivePopInProgress else {
            self.userWasInteractingWithVCOnNavBarReload = true
            return
        }
        self.userWasInteractingWithVCOnNavBarReload = false

        guard let navigationController = navigationController else { return }

        // Important
        // `popViewController` is used here as a hack to be able to change
        // the navigationBar's `topItem?.backBarButtonItem`
        navigationController.popViewController(animated: false)
        if let numberUnread = viewModel.notification.service?.unreadNotifications.count, numberUnread != 0 {
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
                                                                            .foregroundColor: UIColor.black])
        dateText.append(NSAttributedString(string: ","))
        dateText.append(NSAttributedString(string: yymmdd, attributes: [.font: UIFont.systemFont(ofSize: 14),
                                                                        .foregroundColor: UIColor.black.withAlphaComponent(0.85)]))
        let dateLabel = UILabel()
        dateLabel.attributedText = dateText
        navigationItem.titleView = dateLabel
    }

    private func prepareViewModel() {
        // Register cells
        viewModel.items.forEach { tableView.register(type(of: $0).cellType, forCellReuseIdentifier: type(of: $0).reuseIdentifier)}

        viewModel.serviceNotificationsObserver?.onNumberNotificationsChange = { [weak self] _ in
            self?.updateBackBarButtonItem()
        }
    }

    private func layout() {
        view.add(subview: tableView)
        tableView.embed(in: view)
    }

    private func setTapOn(urlCell: NotificationDetailURLCell) {
        urlCell.onURLTap = { [weak self] url in
            let alert = NotifireAlertViewController(alertTitle: "Warning", alertText: "You are about to be redirected to an external URL. Are you sure you want to proceed?")
            alert.add(action: NotifireAlertAction(title: "Yes, take me there.", style: .positive, handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                alert.dismiss(animated: false, completion: nil)
            }))
            alert.add(action: NotifireAlertAction(title: "No", style: .neutral, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            self?.present(alert: alert, animated: true, completion: nil)
        }
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
            setTapOn(urlCell: urlCell)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
}
