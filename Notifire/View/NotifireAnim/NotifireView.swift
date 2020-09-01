//
//  NotifireView.swift
//  Notifire
//
//  Created by David Bielik on 01/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireView: ConstrainableView {

    // MARK: - Properties
    private var timer: Timer?

    override open class var layerClass: AnyClass { return NotifireLayer.self }

    var isAnimating = false {
        didSet {
            guard isAnimating != oldValue, let layer = layer as? NotifireLayer else { return }
            if isAnimating {
                layer.startFireAnimation()
            } else {
                layer.stopFireAnimation()
            }
        }
    }

    // MARK: - Inherited
    override func setupSubviews() {
        (layer as? NotifireLayer)?.fireLayersSettings = [
            FireLayerProperties(fillColor: .red, opacity: 1, translationY: 0, relativeScaleFactor: (1, 1)),
            FireLayerProperties(fillColor: .notifireMainColor, opacity: 1, translationY: 12, relativeScaleFactor: (0.74, 0.74)),
            FireLayerProperties(fillColor: .yellow, opacity: 1, translationY: 20, relativeScaleFactor: (0.5, 0.5))
        ]
    }

    deinit {
        // cleanup
        timer?.invalidate()
    }

    // MARK: - Private
    private func startDecreasingSpeedIfNeeded() {
        guard self.timer == nil else { return }
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true, block: { [weak self] timer in
            guard let `self` = self else { return }
            let speedDecreaseFactor: Float = 0.99
            let newSpeed = max(1, self.layer.speed * speedDecreaseFactor)
            self.layer.changeSpeed(to: newSpeed)
            if newSpeed == 1 {
                self.timer?.invalidate()
                self.timer = nil
            }
        })
    }

    // MARK: - Public
    func boostSpeed() {
        let speedBoost: Float = 1.2
        let newSpeed = min(4, self.layer.speed * speedBoost)
        layer.changeSpeed(to: newSpeed)
        startDecreasingSpeedIfNeeded()
    }
}
