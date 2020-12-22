//
//  TableViewReselectable.swift
//  Notifire
//
//  Created by David Bielik on 07/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

protocol TableViewReselectable: Reselectable {
    var tableView: UITableView { get }
}

extension TableViewReselectable {
    func reselect() -> ReselectHandled {
        tableView.setContentOffset(.zero, animated: true)
        return true
    }
}

extension TableViewReselectable where Self: EmptyStatePresentable {
    var viewToHideWithEmptyState: UIView {
        return tableView
    }
}
