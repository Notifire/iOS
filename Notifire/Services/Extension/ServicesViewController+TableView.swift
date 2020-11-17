//
//  ServicesViewController+TableView.swift
//  Notifire
//
//  Created by David Bielik on 16/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit
import SkeletonView

// MARK: - UITableViewDataSource
extension ServicesViewController: SkeletonTableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel.services.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ServiceTableViewCell.reuseIdentifier, for: indexPath) as? ServiceTableViewCell else {
                return UITableViewCell()
            }
            let service = viewModel.services[indexPath.row]
            cell.configure(from: service)
            return cell
        } else {
            guard let cell = tableView.dequeue(reusableCell: PaginationLoadingTableViewCell.self, for: indexPath) else {
                return UITableViewCell()
            }
            cell.loadingIndicator.alpha = viewModel.isFetching ? 1 : 0
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Size.Cell.heightExtended
        } else {
            if viewModel.isFetching {
                return Size.Cell.heightExtended + 20
            } else {
                return 0
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        } else {
            let shouldShowFooter =
                viewModel.synchronizationManager.paginationHandler.isFullyPaginated ||
                viewModel.synchronizationManager.isOfflineModeActive
            return shouldShowFooter ? Size.footerHeight : 0
        }
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        } else {
            return tableView.dequeue(headerFooter: ServicesTableViewFooterView.self)
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == viewModel.services.count - 4 else { return }
        viewModel.fetchNextPageOfUserServices()
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return ServiceTableViewCell.reuseIdentifier
    }
}

// MARK: - UITableViewDelegate
extension ServicesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let service = viewModel.services[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(service: service)
    }
}
