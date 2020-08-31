//
//  BaseTableViewCell.swift
//  Notifire
//
//  Created by David Bielik on 10/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.layoutMargins = UIEdgeInsets(top: 0, left: Size.Cell.extendedSideMargin, bottom: 0, right: Size.Cell.extendedSideMargin)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }
    
    open func setup() {}
}
