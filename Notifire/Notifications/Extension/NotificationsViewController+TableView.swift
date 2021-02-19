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
            tableView.deselectRow(at: indexPath, animated: true)
        }
        changeReadAction.backgroundColor = .primary
        if #available(iOS 13, *) {
            changeReadAction.image = isRead ? UIImage(systemName: "envelope.badge.fill") : UIImage(systemName: "envelope.open.fill")
        } else {
            changeReadAction.image = isRead ? #imageLiteral(resourceName: "baseline_email_black_48pt").withRenderingMode(.alwaysTemplate) :  #imageLiteral(resourceName: "baseline_drafts_black_48pt").withRenderingMode(.alwaysTemplate)
        }
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
            deleteNotificationAction.image = UIImage(systemName: "trash.fill")
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
        return heightDictionary[notification.notificationID] ?? Size.Cell.heightExtended
    }
}

// MARK: - Context Menu
@available(iOS 13, *)
extension NotificationsViewController {

    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.row
        let notification = viewModel.collection[index]
        let identifier = notification.notificationID as NSString
        let shouldUseReadAction = notification.isRead

        return UIContextMenuConfiguration(
            identifier: identifier,
            previewProvider: { [weak self] in
                return self?.delegate?.getNotificationDetailVC(notification: notification)
            }) { _ in
            var children = [UIMenuElement]()
            // Delete notification
            let deleteAttributes = UIMenuElement.Attributes.destructive
            let deleteAction = UIAction(
                title: "Delete",
                image: UIImage(systemName: "trash"),
                attributes: deleteAttributes) { _ in
                    self.viewModel.delete(notification: notification)
                }
            children.append(deleteAction)
            // Mark as read
            let readUnreadAction = UIAction(
                title: shouldUseReadAction ? "Mark as unread" : "Mark as read",
                image: shouldUseReadAction ? UIImage(systemName: "envelope.badge") : UIImage(systemName: "envelope.open")) { _ in
                self.viewModel.swapNotificationReadUnread(notification: notification)
                (tableView.cellForRow(at: indexPath) as? NotificationPresenting)?.updateNotificationReadView(from: notification)
                tableView.deselectRow(at: indexPath, animated: true)
            }
            children.append(readUnreadAction)
            // Copy body
            let copyBodyAction = UIAction(
                title: "Copy notification body",
                image: UIImage(systemName: "text.bubble")) { _ in
                UIPasteboard.general.string = notification.body
            }
            children.append(copyBodyAction)
            // Copy additional text
            if let additionalText = notification.text {
                let additionalTextCopyAction = UIAction(
                    title: "Copy additional text",
                    image: UIImage(systemName: "doc.plaintext")) { _ in
                    UIPasteboard.general.string = additionalText
                }
                children.append(additionalTextCopyAction)
            }
            if let url = notification.additionalURL {
                // Open url
                let openURLAction = UIAction(
                    title: "Open URL",
                    image: UIImage(systemName: "link")) { _ in
                    URLOpener.open(url: url)
                }
                children.append(openURLAction)
            }
            return UIMenu(title: "", image: nil, children: children)
        }
    }

    // Needed to keep this code in order to have the animation bug-free.
    // As of iOS 14.3 the dismiss animation leaves a white background cell behind and is not smooth at all.
    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let cell = getCellFrom(configuration: configuration) else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        return UITargetedPreview(view: cell, parameters: parameters)
    }

    @available(iOS 13, *)
    func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let cell = getCellFrom(configuration: configuration), let indexPath = tableView.indexPath(for: cell) else { return }
        let notification = viewModel.collection[indexPath.row]
        animator.addCompletion { [weak self] in
            self?.delegate?.didSelect(notification: notification)
        }
    }

    private func getCellFrom(configuration: UIContextMenuConfiguration) -> UITableViewCell? {
        guard
            let notificationID = configuration.identifier as? String,
            let cell = tableView.visibleCells.first(where: { ($0 as? NotificationBaseTableViewCell)?.currentNotificationID == notificationID })
        else {
            return nil
        }
        return cell
    }
}
