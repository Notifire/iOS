//
//  Revealing.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

struct AppRevealAnimation {
    static let delay: TimeInterval = 0.5
    static let smallScaleUpDuration: TimeInterval = 0.26
    static let scaleDownDuration: TimeInterval = 0.40
    static let finalDuration: TimeInterval = 0.38
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
        let smallScaleUpAnimator = UIViewPropertyAnimator(duration: AppRevealAnimation.smallScaleUpDuration, controlPoint1: CGPoint(x: 0.07, y: 0.81), controlPoint2: CGPoint(x: 0.83, y: 0.96)) {
            splashView.iconImageView.transform = CGAffineTransform.identity.scaledBy(x: 1.08, y: 1.08)
        }
        smallScaleUpAnimator.addCompletion { _ in
            let scaleDownAnimator = UIViewPropertyAnimator(duration: AppRevealAnimation.scaleDownDuration, dampingRatio: 0.9) {
                splashView.iconImageView.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
            }
            scaleDownAnimator.addCompletion { _ in
                UIView.animateKeyframes(withDuration: AppRevealAnimation.finalDuration, delay: 0, options: [.calculationModePaced], animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                        splashView.iconImageView.transform = CGAffineTransform.identity.scaledBy(x: 14, y: 14)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.36, relativeDuration: 0.64, animations: {
                        splashView.alpha = 0
                        splashVC.view.transform = .identity
                    })
                }, completion: { [unowned self] finished in
                    guard finished else { return }
                    splashWindow.dismiss()
                    completion?()
                    _ = self.customRevealContentCompletion()
                })
            }
            scaleDownAnimator.startAnimation()
        }
        smallScaleUpAnimator.startAnimation(afterDelay: AppRevealAnimation.delay)
    }
}
