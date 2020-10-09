//
//  UITableView+Reusable.swift
//  Notifire
//
//  Created by David Bielik on 16/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension UITableView {
    /// Registers the cell for reuse
    func register(reusableCell cellType: ReusableCell.Type) {
        register(cellType, forCellReuseIdentifier: cellType.reuseIdentifier)
    }

    func register(reusableHeaderFooter headerFooterType: ReusableHeaderFooter.Type) {
        register(headerFooterType, forHeaderFooterViewReuseIdentifier: headerFooterType.reuseIdentifier)
    }

    /// Registers all reusables for reuse
    func register(cells cellTypes: [ReusableCell.Type]) {
        for cellType in cellTypes {
            register(reusableCell: cellType)
        }
    }

    func register(headerFooters types: [ReusableHeaderFooter.Type]) {
        for headerFooterType in types {
            register(reusableHeaderFooter: headerFooterType)
        }
    }

    /// Dequeue a reusable cell
    /// - note: sugar for `dequeueReusableCell(withIdentifier:for:)`
    func dequeue<T: ReusableCell>(reusableCell: T.Type, for indexPath: IndexPath) -> T? {
        return dequeueReusableCell(withIdentifier: reusableCell.reuseIdentifier, for: indexPath) as? T
    }

    /// Dequeue a reusable HeaderFooterView
    func dequeue<T: ReusableHeaderFooter>(headerFooter type: T.Type) -> T? {
        return dequeueReusableHeaderFooterView(withIdentifier: type.reuseIdentifier) as? T
    }
}
