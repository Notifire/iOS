//
//  Reusable.swift
//  Notifire
//
//  Created by David Bielik on 16/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

protocol Reusable {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String { return String(describing: self) }
}

typealias ReusableCell = UITableViewCell & Reusable
typealias ReusableBaseTableViewCell = BaseTableViewCell & Reusable
typealias ReusableHeaderFooter = UITableViewHeaderFooterView & Reusable
