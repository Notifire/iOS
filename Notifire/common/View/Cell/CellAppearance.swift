//
//  CellAppearance.swift
//  Notifire
//
//  Created by David Bielik on 13/02/2021.
//  Copyright © 2021 David Bielik. All rights reserved.
//

import UIKit

// MARK: - DefaultCellAppearance
struct DefaultCellAppearance: CellAppearanceDescribing {}

// MARK: - DefaultTappableCellAppearance
struct DefaultTappableCellAppearance: CellAppearanceDescribing {
    static var selectionStyle: UITableViewCell.SelectionStyle {
        return .default
    }
}

// MARK: - DefaultAutomaticHeightCellAppearance
struct DefaultAutomaticHeightCellAppearance: CellAppearanceDescribing {
    static var height: CGFloat? {
        return UITableView.automaticDimension
    }
}

// MARK: - DisclosureCellAppearance
struct DisclosureCellAppearance: CellAppearanceDescribing {
    static var accessoryType: UITableViewCell.AccessoryType {
        return .disclosureIndicator
    }

    static var selectionStyle: UITableViewCell.SelectionStyle {
        return .default
    }
}
