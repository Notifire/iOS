//
//  Revealing.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

struct AppRevealAnimation {
    static let delay: TimeInterval = 0.2
    static let scaleDownDuration: TimeInterval = 0.34
    static let finalDuration: TimeInterval = 0.22
}

protocol AppRevealing {
    func revealContent(completion: (() -> Void)?)
    /// Called when a custom reveal content animation is finished.
    /// - Returns: `true` if custom completion was provided, `false` otherwise. Default return value of this function is `false`
    func customRevealContentCompletion() -> Bool
}

extension AppRevealing where Self: UIViewController {

    func customRevealContentCompletion() -> Bool {
        for childVC in getNestedChildren() where childVC is AppRevealing {
            let handled = (childVC as? AppRevealing)?.customRevealContentCompletion() ?? false
            guard !handled else { return true }
        }
        return false
    }

    func revealContent(completion: (() -> Void)? = nil) {
        view.transform = CGAffineTransform.identity.scaledBy(x: 1.12, y: 1.12)

        // Create a new UIWindow for the app reveal in order to display the animation over any Deeplink induced VC / Alert VC
        let splashVC = UIViewController()
        splashVC.view.backgroundColor = .clear

        let splashWindow = UIWindow(frame: UIScreen.main.bounds)
        splashWindow.windowLevel = UIWindow.Level.alert + 2
        splashWindow.isHidden = false
        splashWindow.rootViewController = splashVC

        let splashView = SplashView()
        splashVC.view.add(subview: splashView)
        splashView.embed(in: splashVC.view)
        let scaleDownAnimator = UIViewPropertyAnimator(duration: AppRevealAnimation.scaleDownDuration, curve: .easeOut) {
            splashView.iconImageView.transform = CGAffineTransform.identity.scaledBy(x: 0.86, y: 0.86)
        }
        scaleDownAnimator.addCompletion { _ in
            let delay: TimeInterval = 0.1
            UIView.animateKeyframes(withDuration: AppRevealAnimation.finalDuration, delay: 0, options: [UIView.KeyframeAnimationOptions(animationOptions: .curveEaseIn)], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.8, animations: {
                    splashView.iconImageView.transform = CGAffineTransform.identity.scaledBy(x: 14, y: 14)
                })
                UIView.addKeyframe(withRelativeStartTime: delay, relativeDuration: 0.6, animations: {
                    splashView.alpha = 0
                })
            }, completion: { [unowned self] finished in
                guard finished else { return }
                splashWindow.dismiss()
                completion?()
                _ = self.customRevealContentCompletion()
            })
            UIView.animate(withDuration: AppRevealAnimation.finalDuration * (1 - delay) + 0.1, delay: AppRevealAnimation.finalDuration * delay, options: [.curveEaseOut], animations: {
                self.view.transform = .identity
            }, completion: nil)
        }
        scaleDownAnimator.startAnimation(afterDelay: AppRevealAnimation.delay)
    }
}
