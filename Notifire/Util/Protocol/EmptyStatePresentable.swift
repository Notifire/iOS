//
//  EmptyStatePresentable.swift
//  Notifire
//
//  Created by David Bielik on 13/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol EmptyStatePresentable: class {
    associatedtype EmptyStateView: UIView
    var emptyStateView: EmptyStateView? { get set }
    var tableView: UITableView { get }
    func addEmptyState() -> EmptyStateView?
    func removeEmptyState()
}

extension EmptyStatePresentable where Self: UIViewController {
    @discardableResult
    func addEmptyState() -> EmptyStateView? {
        guard emptyStateView == nil else { return nil }
        let empty = EmptyStateView()
        emptyStateView = empty
        view.insertSubview(empty, aboveSubview: tableView)
        empty.embed(in: tableView)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        return emptyStateView
    }
    
    func removeEmptyState() {
        emptyStateView?.removeFromSuperview()
        emptyStateView = nil
    }
}
