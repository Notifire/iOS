//
//  NotifirePoppable.swift
//  Notifire
//
//  Created by David Bielik on 17/11/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

protocol NotifirePoppable {
    var viewToPop: UIView { get }
}

typealias NotifirePoppableViewController = UIViewController & NotifirePoppable

protocol NotifirePoppablePresenting: UIViewControllerTransitioningDelegate {

    var poppablePresentingViewController: UIViewController { get }

    func animationController(forPresented presented: UIViewController) -> UIViewControllerAnimatedTransitioning?
    func present(alert: NotifireAlertViewController, animated: Bool, completion: (() -> Void)?)
}

extension NotifirePoppablePresenting {
    func present(alert: NotifireAlertViewController, animated: Bool, completion: (() -> Void)?) {
        alert.transitioningDelegate = self
        alert.modalPresentationStyle = .overFullScreen
        poppablePresentingViewController.present(alert, animated: animated, completion: completion)
    }

    func animationController(forPresented presented: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard presented is NotifirePoppable else { return nil }
        return NotifirePopAnimationController()
    }
}

extension NotifirePoppablePresenting where Self: UIViewController {
    var poppablePresentingViewController: UIViewController {
        return self
    }
}
