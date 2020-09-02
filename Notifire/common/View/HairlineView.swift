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
        backgroundColor = .separatorColor
        let height = HairlineView.minimalWidth
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    static var minimalWidth: CGFloat {
        return (1.0 / UIScreen.main.scale)
    }
}
