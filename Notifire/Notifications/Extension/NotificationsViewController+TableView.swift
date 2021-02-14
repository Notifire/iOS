//
//  NotificationsViewController+TableView.swift
//  Notifire
//
//  Created by David Bielik on 14/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

extension NotificationsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notification = viewModel.collection[indexPath.row]
        delegate?.didSelect(notification: notification)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = viewModel.collection[indexPath.row]
        let isRead = notification.isRead
        let changeReadAction = UIContextualAction(style: .normal, title: isRead ? "Unread" : "Read") { [weak self] (_, _, completion) in
            self?.viewModel.swapNotificationReadUnread(notification: notification)
            completion(true)
            (tableView.cellForRow(at: indexPath) as? NotificationPresenting)?.updateNotificationReadView(from: notification)
        }
        changeReadAction.backgroundColor = .primary
        changeReadAction.image = isRead ? #imageLiteral(resourceName: "baseline_email_black_48pt").withRenderingMode(.alwaysTemplate) :  #imageLiteral(resourceName: "baseline_drafts_black_48pt").withRenderingMode(.alwaysTemplate)
        let config = UISwipeActionsConfiguration(actions: [changeReadAction])
        return config
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let notification = viewModel.collection[indexPath.row]
        let deleteNotificationAction = UIContextualAction(
            style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.viewModel.delete(notification: notification)
            completion(true)
        }
        deleteNotificationAction.backgroundColor = .compatibleRed
        if #available(iOS 13, *) {
            deleteNotificationAction.image = UIImage(systemName: "trash")
        }
        let config = UISwipeActionsConfiguration(actions: [deleteNotificationAction])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.collection.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let configuration = viewModel.cellConfiguration(for: indexPath.row)
        let cell = tableView.dequeueReusableCell(withIdentifier: type(of: configuration).reuseIdentifier, for: indexPath)
        configuration.configure(cell: cell)
        cell.selectionStyle = .default
        return cell
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let notification = viewModel.collection[indexPath.row]
        heightDictionary[notification.notificationID] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let notification = viewModel.collection[indexPath.row]
        return heightDictionary[notification.notificationID] ?? UITableView.automaticDimension
    }
}
