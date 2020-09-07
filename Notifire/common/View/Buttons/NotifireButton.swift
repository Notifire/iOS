//
//  NotifireButton.swift
//  Notifire
//
//  Created by David Bielik on 27/08/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireButton: BaseButton {

    // MARK: - Properties
    // MARK: Animation
    struct TapAnimation {
        static let durationDown: TimeInterval = 0.06
        static let durationUp: TimeInterval = 0.08

        static let downscale: CGFloat = 0.96
        static let overlayColor = UIColor.compatibleLabel
        static let overlayMaxAlpha: CGFloat = 0.25
    }

    // MARK: Options
    /// Boolean value indicating if the touchDown / Up animation should include the scale transform.
    var shouldAnimateScale = true
    /// Boolean value indicating if the touchDown / Up animation should include the gray overlay (dis) appearing.
    var shouldAnimateGrayOverlay = true

    var animationDurationDown = TapAnimation.durationDown
    var animationDurationUp = TapAnimation.durationUp

    let grayOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = TapAnimation.overlayColor
        view.isUserInteractionEnabled = false
        view.alpha = 0
        return view
    }()

    public var borderColor: UIColor = .primary

    // MARK: - Inherited
    // constant height for all custom buttons
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Size.componentHeight)
    }

    override var isEnabled: Bool {
        didSet {
            let newAlpha: CGFloat = isEnabled ? 1 : 0.5
            // Use layer.opacity instead of alpha here to include the alpha of the layer.borderColor :)
            alpha = newAlpha
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                layer.borderColor = borderColor.cgColor
            }
        }
    }

    override open func addTargets() {
        super.addTargets()
        addTarget(self, action: #selector(touchUpOutside), for: .touchUpOutside)
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchDragExit), for: .touchDragExit)
    }

    override open func setup() {
        layer.cornerRadius = Theme.defaultCornerRadius
        layer.borderWidth = Theme.defaultBorderWidth
        layer.borderColor = borderColor.cgColor
        backgroundColor = .primary

        clipsToBounds = true

        layout()
    }

    // MARK: - Private
    private func layout() {
        add(subview: grayOverlayView)
        grayOverlayView.embed(in: self)
    }

    private func animateTouchDown(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: TapAnimation.durationDown, delay: 0.0, options: [.curveEaseIn], animations: {
            if self.shouldAnimateScale {
                self.transform = CGAffineTransform(scaleX: TapAnimation.downscale, y: TapAnimation.downscale)
            }
            if self.shouldAnimateGrayOverlay {
                self.grayOverlayView.alpha = TapAnimation.overlayMaxAlpha
            }
        }, completion: completion)
    }

    private func animateTouchUp(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: TapAnimation.durationUp, delay: 0.0, options: [.curveEaseOut], animations: {
            if self.shouldAnimateScale {
                self.transform = CGAffineTransform.identity
            }
            if self.shouldAnimateGrayOverlay {
                self.grayOverlayView.alpha = 0
            }
        }, completion: completion)
    }

    // MARK: Event Handlers
    override func touchUpInside() {
        animateTouchUp(completion: { finished in
            guard finished else { return }
            super.touchUpInside()
        })
    }

    @objc func touchUpOutside() {
        animateTouchUp()
    }

    @objc func touchDown() {
        animateTouchDown()
    }

    @objc private func touchDragExit() {
        animateTouchUp()
    }
}
