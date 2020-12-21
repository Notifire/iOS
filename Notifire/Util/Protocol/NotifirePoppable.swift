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

protocol NotifireAlertPresenting {

    var poppablePresentingViewController: UIViewController { get }

    func present(alert: NotifireAlertViewController, animated: Bool, completion: (() -> Void)?)
}

// swiftlint:disable type_name
class NotifireAlertAnimatedTransitioningHandler: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard presented is NotifirePoppable else { return nil }
        return NotifirePopAnimationController()
    }
}
// swiftlint:enable type_name

extension NotifireAlertPresenting {
    func present(alert: NotifireAlertViewController, animated: Bool, completion: (() -> Void)?) {
        let transitionHandler = NotifireAlertAnimatedTransitioningHandler()
        alert.transitioningDelegate = transitionHandler
        alert.modalPresentationStyle = .overFullScreen
        poppablePresentingViewController.view.endEditing(true)
        poppablePresentingViewController.present(alert, animated: animated, completion: completion)
    }
}

extension NotifireAlertPresenting where Self: UIViewController {
    var poppablePresentingViewController: UIViewController {
        return self
    }
}
