//
//  RootViewController.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class RootViewController: BaseViewController {

    func cycleFrom(oldVC: UIViewController, to newVC: UIViewController, completion: (() -> Void)? = nil) {
        oldVC.willMove(toParent: nil)
        addChild(newVC)

        let bounds = view.bounds
        let newVCInitialTransform = CGAffineTransform(translationX: 0, y: bounds.height * 0.08).scaledBy(x: 0.96, y: 0.96)
        let oldVCFinalTransform = CGAffineTransform(translationX: 0, y: bounds.height)
        newVC.view.transform = newVCInitialTransform
        newVC.view.alpha = 0.7

        view.insertSubview(newVC.view, belowSubview: oldVC.view)
        let animator = UIViewPropertyAnimator(duration: Animation.Duration.rootVCTransition, dampingRatio: 1) {
            oldVC.view.transform = oldVCFinalTransform
            newVC.view.transform = .identity
            newVC.view.alpha = 1
        }
        animator.addCompletion { position in
            guard position == .end else { return }
            oldVC.view.removeFromSuperview()
            oldVC.removeFromParent()
            newVC.didMove(toParent: self)
            completion?()
        }
        animator.startAnimation()
    }
}
