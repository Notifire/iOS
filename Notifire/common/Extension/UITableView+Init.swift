//
//  UITableView+Init.swift
//  Notifire
//
//  Created by David Bielik on 13/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

extension UITableView {

    static func initGrouped(registerCells: [ReusableCell.Type], dataSource: UITableViewDataSource?, delegate: UITableViewDelegate?) -> UITableView {
        let style: UITableView.Style
        var rowHeight: CGFloat = UITableView.automaticDimension
        if #available(iOS 13.0, *) {
            style = .insetGrouped
            rowHeight = Size.Cell.insetGroupedHeight
        } else {
            style = .grouped
        }
        let tableView = UITableView(frame: .zero, style: style)
        if let dataSource = dataSource {
            tableView.dataSource = dataSource
        }
        if let delegate = delegate {
            tableView.delegate = delegate
        }
        tableView.rowHeight = rowHeight
        tableView.register(cells: registerCells)
        return tableView
    }
}
