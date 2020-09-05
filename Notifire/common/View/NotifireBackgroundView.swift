//
//  NotifireBackgroundView.swift
//  Notifire
//
//  Created by David Bielik on 31/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireBackgroundView: ConstrainableView {

    // MARK: - Inherited
    override open class var layerClass: AnyClass { return NotifireBackgroundLayer.self }

    override func setupSubviews() {
        backgroundColor = .backgroundColor
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                (layer as? NotifireBackgroundLayer)?.resetGradientColors()
                setNeedsDisplay()
            }
        }
    }
}
