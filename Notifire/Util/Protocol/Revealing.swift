//
//  Revealing.swift
//  Notifire
//
//  Created by David Bielik on 12/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

struct AppRevealSettings {
    static let delay: TimeInterval = 1
    static let smallScaleUpDuration: TimeInterval = 0.26
    static let scaleDownDuration: TimeInterval = 0.48
    static let finalDuration: TimeInterval = 0.38
}

protocol AppRevealing {
    func revealContent(completion: (() -> Void)?)
    func customCompletion()
}

extension AppRevealing where Self : UIViewController {
    func customCompletion() {}
    
    func revealContent(completion: (() -> Void)? = nil) {
        let splashView = SplashView()
        view.transform = CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
        view.add(subview: splashView)
        splashView.embed(in: view)
        let smallScaleUpAnimator = UIViewPropertyAnimator(duration: AppRevealSettings.smallScaleUpDuration, controlPoint1: CGPoint(x: 0.07, y: 0.81), controlPoint2: CGPoint(x: 0.83, y: 0.96)) {
            splashView.iconImageView.transform = CGAffineTransform.identity.scaledBy(x: 1.06, y: 1.06)
        }
        smallScaleUpAnimator.addCompletion { _ in
            let scaleDownAnimator = UIViewPropertyAnimator(duration: AppRevealSettings.scaleDownDuration, dampingRatio: 0.9) {
                splashView.iconImageView.transform = CGAffineTransform.identity.scaledBy(x: 0.6, y: 0.6)
            }
            scaleDownAnimator.addCompletion { _ in
                UIView.animateKeyframes(withDuration: AppRevealSettings.finalDuration, delay: 0, options: [.calculationModePaced], animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1, animations: {
                        splashView.iconImageView.transform = CGAffineTransform.identity.scaledBy(x: 14, y: 14)
                    })
                    UIView.addKeyframe(withRelativeStartTime: 0.36, relativeDuration: 0.64, animations: {
                        splashView.alpha = 0
                        self.view.transform = .identity
                    })
                }, completion: { finished in
                    guard finished else { return }
                    splashView.removeFromSuperview()
                    completion?()
                })
            }
            scaleDownAnimator.startAnimation()
        }
        smallScaleUpAnimator.startAnimation(afterDelay: AppRevealSettings.delay)
    }
}
