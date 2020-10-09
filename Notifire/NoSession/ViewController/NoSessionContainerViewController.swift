//
//  NoSessionContainerViewController.swift
//  Notifire
//
//  Created by David Bielik on 14/10/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NoSessionContainerViewController: UIViewController, AppRevealing {

    func presentCoverVertical(viewController: UIViewController) {
        viewController.willMove(toParent: self)
        viewController.beginAppearanceTransition(true, animated: true)
        addChild(viewController)

        let bounds = view.bounds
        let initialTransform = CGAffineTransform(translationX: 0, y: bounds.height)
        viewController.view.transform = initialTransform

        view.addSubview(viewController.view)
        let animator = UIViewPropertyAnimator(duration: Animation.Duration.loginVCCoverVerticalTransition, dampingRatio: 1) {
            viewController.view.transform = .identity
        }
        animator.addCompletion { position in
            guard position == .end else { return }
            viewController.didMove(toParent: self)
            viewController.endAppearanceTransition()
        }
        animator.startAnimation()
    }

    func dismissVertical(viewController: UIViewController) {
        viewController.willMove(toParent: nil)

        let bounds = view.bounds
        let finalTransform = CGAffineTransform(translationX: 0, y: bounds.height)

        let animator = UIViewPropertyAnimator(duration: Animation.Duration.loginVCCoverVerticalTransition, dampingRatio: 1) {
            viewController.view.transform = finalTransform
        }
        animator.addCompletion { position in
            guard position == .end else { return }
            viewController.view.removeFromSuperview()
            viewController.removeFromParent()
        }
        animator.startAnimation()
    }
}
