//
//  UIStackViewExtension.swift
//  Notifire
//
//  Created by David Bielik on 28/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

extension UIStackView {
    convenience init(arrangedSubviews: [UIView], spacing: CGFloat) {
        self.init(arrangedSubviews: arrangedSubviews)
        axis = .vertical
        alignment = .fill
        self.spacing = spacing
        translatesAutoresizingMaskIntoConstraints = false
    }
}
