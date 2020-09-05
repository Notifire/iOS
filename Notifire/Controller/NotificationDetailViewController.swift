//
//  NotificationDetailViewController.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotificationDetailViewController: UIViewController, NavigationBarDisplaying, NotifirePoppablePresenting {

    // MARK: - Properties
    let viewModel: NotificationDetailViewModel

    // MARK: Views
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.dataSource = self
        table.allowsSelection = false
        table.backgroundColor = .backgroundColor
        table.removeLastSeparatorAndDontShowEmptyCells()
        table.contentInsetAdjustmentBehavior = .always
        table.alwaysBounceVertical = false
        return table
    }()

    // MARK: - Initialization
    init(viewModel: NotificationDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.markNotificationAsRead()
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return animationController(forPresented: presented)
    }

    // MARK: - Private
    private func setTitle() {
        let date = viewModel.notification.date.string(with: .complete)
        var dateComponents = date.components(separatedBy: ",")
        guard dateComponents.count == 2 else { return }
        let hhmm = dateComponents.removeFirst()
        let yymmdd = dateComponents.removeFirst()
        let dateText = NSMutableAttributedString(string: hhmm, attributes: [.font: UIFont.boldSystemFont(ofSize: 17),
                                                                            .foregroundColor: UIColor.black])
        dateText.append(NSAttributedString(string: ","))
        dateText.append(NSAttributedString(string: yymmdd, attributes: [.font: UIFont.systemFont(ofSize: 15),
                                                                        .foregroundColor: UIColor.black.withAlphaComponent(0.85)]))
        let dateLabel = UILabel()
        dateLabel.attributedText = dateText
        navigationItem.titleView = dateLabel
    }

    private func prepareViewModel() {
        viewModel.items.forEach { tableView.register(type(of: $0).cellType, forCellReuseIdentifier: type(of: $0).reuseIdentifier)}
    }

    private func layout() {
        view.add(subview: tableView)
        tableView.embed(in: view)
    }

    private func setTapOn(urlCell: NotificationDetailURLCell) {
        urlCell.onURLTap = { url in
            let alert = NotifireAlertViewController(alertTitle: "Warning", alertText: "You are about to be redirected to an external URL. Are you sure you want to proceed?")
            alert.add(action: NotifireAlertAction(title: "Yes, take me there.", style: .positive, handler: { _ in
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                alert.dismiss(animated: false, completion: nil)
            }))
            alert.add(action: NotifireAlertAction(title: "No", style: .neutral, handler: { _ in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert: alert, animated: true, completion: nil)
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
        cell.backgroundColor = .backgroundColor
        if let urlCell = cell as? NotificationDetailURLCell {
            setTapOn(urlCell: urlCell)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
}
