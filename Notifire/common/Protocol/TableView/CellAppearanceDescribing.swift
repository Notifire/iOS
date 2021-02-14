//
//  CellAppearanceDescribing.swift
//  Notifire
//
//  Created by David Bielik on 13/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

protocol CellAppearanceDescribing {
    /// The required height for this cell.
    /// - Note: Return `nil` for cells that don't need a specific setting.
    static var height: CGFloat? { get }
    static var selectionStyle: UITableViewCell.SelectionStyle { get }
    static var accessoryType: UITableViewCell.AccessoryType { get }
}

extension CellAppearanceDescribing {
    static var height: CGFloat? {
        return nil
    }

    static var selectionStyle: UITableViewCell.SelectionStyle {
        return .none
    }

    static var accessoryType: UITableViewCell.AccessoryType {
        return .none
    }
}
