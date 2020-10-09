//
//  NotifireBackgroundLayer.swift
//  Notifire
//
//  Created by David Bielik on 05/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireBackgroundLayer: CAGradientLayer {

    var gradientDirection: GradientDirection = .fromTop {
        didSet {
            setup()
        }
    }

    // MARK: - Lifecycle
    override init() {
        super.init()
        setup()
    }

    override init(layer: Any) {
        super.init(layer: layer)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Private
    private func setup() {
        // gradient setup
        resetGradientColors()
        switch gradientDirection {
        case .fromTop:
            locations = [0, 0.96]
        case .fromBottom:
            locations = [0.96, 0]
        }

        opacity = 1
    }

    /// Used for trait collection color appearance changes
    func resetGradientColors() {
        colors = [UIColor.primary.cgColor, UIColor.compatibleBackgroundAccent.cgColor]
        setNeedsDisplay()
    }
}
