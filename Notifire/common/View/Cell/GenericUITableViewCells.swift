//
//  GenericUITableViewCells.swift
//  Notifire
//
//  Created by David Bielik on 15/11/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

/// A `UITableViewCell` that conforms to the `Reusable & CellConfigurable` protocol.
class UITableViewReusableCell: ReusableBaseTableViewCell, CellConfigurable {
    // MARK: - Properties
    // MARK: CellConfigurable
    typealias DataType = String

    func configure(data: DataType) {
        textLabel?.text = data
    }
}

class UITableViewCenteredNegativeCell: UITableViewReusableCell {
    override func setup() {
        textLabel?.set(style: .negativeMedium)
    }
}

/// A `UITableViewCell` with style `.value1` that conforms to the `Reusable & CellConfigurable` protocol.
class UITableViewValue1Cell: ReusableBaseTableViewCell, CellConfigurable {

    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: CellConfigurable
    typealias DataType = (text: String, detailText: String?)

    func configure(data: DataType) {
        textLabel?.text = data.text
        detailTextLabel?.text = data.detailText
    }
}
