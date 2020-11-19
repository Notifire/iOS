//
//  HairlineView.swift
//  Notifire
//
//  Created by David Bielik on 19/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class HairlineView: ConstrainableView {
    override func setupSubviews() {
        backgroundColor = .customOpaqueSeparator
        let height = Self.minimalHeight
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    static var minimalHeight: CGFloat {
        return (1.0 / UIScreen.main.scale)
    }
}

class SeparatorView: HairlineView {
    override func setupSubviews() {
        super.setupSubviews()
        backgroundColor = .customSeparator
    }
}
