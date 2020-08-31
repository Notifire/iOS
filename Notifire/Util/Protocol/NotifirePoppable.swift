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


protocol NotifirePoppablePresenting: UIViewControllerTransitioningDelegate {}

extension NotifirePoppablePresenting where Self : UIViewController {
    func present(alert: NotifireAlertViewController, animated: Bool, completion: (() -> Void)?) {
        alert.transitioningDelegate = self
        alert.modalPresentationStyle = .overFullScreen
        present(alert, animated: animated, completion: completion)
    }
}
