//
//  NotifireAnimatedView.swift
//  Notifire
//
//  Created by David Bielik on 31/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireAnimatedView: ConstrainableView {

    enum BoostIntensity {
        case normal
        case huge
    }

    // MARK: - Properties
    let notifireView = NotifireView()

    var isAnimating: Bool = false {
        didSet {
            guard isAnimating != oldValue else { return }
            notifireView.isAnimating = isAnimating
        }
    }

    // MARK: - Inherited
    override open class var layerClass: AnyClass { return NotifireBackgroundLayer.self }

    override func setupSubviews() {
        backgroundColor = .backgroundColor
        // notifire view
        // FIXME: remove alpha
        notifireView.alpha = 0
        addSubview(notifireView)
        notifireView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        notifireView.heightAnchor.constraint(equalTo: notifireView.widthAnchor, multiplier: 1.2).isActive = true
        notifireView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3).isActive = true
        notifireView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }

    // MARK: - Public
    public func boost(intensity: BoostIntensity = .normal) {
        notifireView.boostSpeed()
    }
}
