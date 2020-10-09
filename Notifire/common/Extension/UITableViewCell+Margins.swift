//
//  UITableViewCell+Margins.swift
//  Notifire
//
//  Created by David Bielik on 16/09/2020.
//  Copyright © 2020 David Bielik. All rights reserved.
//

import UIKit

extension UITableViewCell {

    /// Sets the layoutMargins
    func setLayout(margins: UIEdgeInsets) {
        if #available(iOS 13, *) {} else {
            contentView.layoutMargins = margins
        }
    }
}
