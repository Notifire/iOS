//
//  NotifireBackgroundLayer.swift
//  Notifire
//
//  Created by David Bielik on 05/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireBackgroundLayer: CAGradientLayer {
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
        locations = [0, 0.96]
        opacity = 1
    }

    /// Used for trait collection color appearance changes
    func resetGradientColors() {
        colors = [UIColor.primary.cgColor, UIColor.compatibleBackgroundAccent.cgColor]
        setNeedsDisplay()
    }

    func setFrameWithoutAnimation(_ newFrame: CGRect) {
        CATransaction.withDisabledActions {
            frame = newFrame
        }
    }
}

extension CATransaction {
    class func withDisabledActions<T>(_ body: () throws -> T) rethrows -> T {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        defer {
            CATransaction.commit()
        }
        return try body()
    }
}
