//
//  NotificationsFilterViewController+TableView.swift
//  Notifire
//
//  Created by David Bielik on 13/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

// MARK: - UITableViewDelegate
extension NotificationsFilterViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var reloadSection = true
        lastIndexPathForSelectedRow = indexPath
        let section = viewModel.section(at: indexPath.section)
        let selectedRow = viewModel.row(at: indexPath)
        switch section {
        case .readState:
            if selectedRow == .showAll {
                viewModel.notificationsFilterData.readUnreadState = .all
            } else if selectedRow == .read {
                viewModel.notificationsFilterData.readUnreadState = .read
            } else if selectedRow == .unread {
                viewModel.notificationsFilterData.readUnreadState = .unread
            }
        case .levels:
            let notificationLevel: NotificationLevel
            if selectedRow == .info {
                notificationLevel = .info
            } else if selectedRow == .warning {
                notificationLevel = .warning
            } else {
                notificationLevel = .error
            }
            if viewModel.notificationsFilterData.levels.count == 1 {
                // Careful, we need to preserve at least one level.
                if viewModel.notificationsFilterData.levels[notificationLevel] ?? false {
                    // Don't deselect the current row as it is the only selected one
                    reloadSection = false
                } else {
                    // Select another one normally
                    viewModel.notificationsFilterData.levels[notificationLevel] = true
                }
            } else {
                // Select normally
                if viewModel.notificationsFilterData.levels[notificationLevel] != nil {
                    viewModel.notificationsFilterData.levels[notificationLevel] = nil
                } else {
                    viewModel.notificationsFilterData.levels[notificationLevel] = true
                }
            }
        case .data:
            if selectedRow == .timeframe {
                reloadSection = false
                onTimeframeSelectionPressed?()
            } else if selectedRow == .url {
                viewModel.notificationsFilterData.containsURL = !viewModel.notificationsFilterData.containsURL
            } else if selectedRow == .additionalText {
                viewModel.notificationsFilterData.containsAdditionalText = !viewModel.notificationsFilterData.containsAdditionalText
            }
        case .sortingOrder:
            if selectedRow == .newestFirst {
                viewModel.notificationsFilterData.sorting = .descending
            } else if selectedRow == .oldestFirst {
                viewModel.notificationsFilterData.sorting = .ascending
            }
        case .reset:
            reloadSection = false
            viewModel.resetFilterData()
            UIView.transition(with: tableView, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.tableView.reloadData()
            }, completion: nil)
        }
        if reloadSection {
            UIView.setAnimationsEnabled(false)
            tableView.reloadSections([section.rawValue], with: .none)
            UIView.setAnimationsEnabled(true)
        }
    }
}

// MARK: - RowSelect Handling
extension NotificationsFilterViewController {

}
