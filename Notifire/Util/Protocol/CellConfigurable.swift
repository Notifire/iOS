//
//  CellConfigurable.swift
//  Notifire
//
//  Created by David Bielik on 11/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol CellConfigurable {
    associatedtype DataType
    func configure(data: DataType)
}

protocol CellConfiguring {
    static var reuseIdentifier: String { get }
    static var cellType: UITableViewCell.Type { get }
    static var height: CGFloat { get }
    func configure(cell: UITableViewCell)
}

extension CellConfiguring {
    static var height: CGFloat {
        return UITableView.automaticDimension
    }
}

struct CellConfiguration<CellType: UITableViewCell & CellConfigurable, DataType>: CellConfiguring where CellType.DataType == DataType {
    static var reuseIdentifier: String { return String(describing: cellType) }
    static var cellType: UITableViewCell.Type { return CellType.self }

    let item: DataType

    init(item: DataType) {
        self.item = item
    }

    func configure(cell: UITableViewCell) {
        (cell as? CellType)?.configure(data: item)
    }
}
