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
    func configure(appearance: CellAppearanceDescribing.Type)
}

extension CellConfigurable where Self: UITableViewCell {
    func configure(appearance: CellAppearanceDescribing.Type) {
        accessoryType = appearance.accessoryType
        selectionStyle = appearance.selectionStyle
    }
}

protocol CellConfiguring: Reusable {
    static var cellType: UITableViewCell.Type { get }
    func configure(cell: UITableViewCell)
}

enum CellConfigurationContent {
    /// Available immediatelly. Used when the cell content is static.
    case `static`(CellConfiguring)
    /// ViewModels have to provide the CellConfiguration dynamically.
    case `dynamic`
}

struct CellConfiguration<CellType: UITableViewCell & CellConfigurable, Appearance: CellAppearanceDescribing>: CellConfiguring {
    static var reuseIdentifier: String { return String(describing: cellType) }
    static var cellType: UITableViewCell.Type { return CellType.self }

    let item: CellType.DataType
    let appearance: CellAppearanceDescribing.Type = Appearance.self

    init(item: CellType.DataType) {
        self.item = item
    }

    func configure(cell: UITableViewCell) {
        guard let configurableCell = cell as? CellType else {
            Logger.log(.fault, "\(self) unable to configure cell (\(cell)), expected \(CellType.self)")
            return
        }
        // Data
        configurableCell.configure(data: item)
        // Appearance
        configurableCell.configure(appearance: appearance)
    }
}
