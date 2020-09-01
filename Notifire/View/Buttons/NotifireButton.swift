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
    struct TapAnimation {
        static let durationDown: TimeInterval = 0.04
        static let durationUp: TimeInterval = 0.06

        static let downscale: CGFloat = 0.96
        static let overlayColor = UIColor.black
        static let overlayMaxAlpha: CGFloat = 0.2
    }

    let grayOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = TapAnimation.overlayColor
        view.isUserInteractionEnabled = false
        view.alpha = 0
        return view
    }()

    // MARK: - Inherited
    // constant height for all custom buttons
    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: Size.componentHeight)
    }

    override var isEnabled: Bool {
        didSet {
            let newAlpha: CGFloat = isEnabled ? 1 : 0.7
            alpha = newAlpha
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
        layer.borderColor = UIColor.notifireMainColor.withAlphaComponent(0.8).cgColor
        backgroundColor = .notifireMainColor
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
            self.transform = CGAffineTransform(scaleX: TapAnimation.downscale, y: TapAnimation.downscale)
            self.grayOverlayView.alpha = TapAnimation.overlayMaxAlpha
        }, completion: completion)
    }

    private func animateTouchUp(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: TapAnimation.durationUp, delay: 0.0, options: [.curveEaseOut], animations: {
            self.transform = CGAffineTransform.identity
            self.grayOverlayView.alpha = 0
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

// MARK: - Loadable
extension NotifireButton: Loadable {
    func onLoadingStart() {
        isEnabled = false
        titleLabel?.alpha = 0
    }

    func onLoadingFinished() {
        isEnabled = true
        titleLabel?.alpha = 1
    }

    var spinnerStyle: UIActivityIndicatorView.Style {
        return .white
    }

    var spinnerPosition: LoadableSpinnerPosition {
        return .center
    }
}
