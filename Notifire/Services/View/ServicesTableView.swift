//
//  ServicesTableView.swift
//  Notifire
//
//  Created by David Bielik on 19/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

class ServicesTableView: UITableView {

    /// Whether this tableView is currently scrolling or not.
    public var isScrolling: Bool = false

    // MARK: - Initialization
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        rowHeight = Size.Cell.heightExtended
        estimatedRowHeight = Size.Cell.heightExtended
        removeLastSeparatorAndDontShowEmptyCells()
        backgroundColor = .compatibleBackgroundAccent
        contentInsetAdjustmentBehavior = .never
        isSkeletonable = true
        register(reusableHeaderFooter: ServicesTableViewFooterView.self)
        register(cells: [ServiceTableViewCell.self, PaginationLoadingTableViewCell.self])
    }
}
