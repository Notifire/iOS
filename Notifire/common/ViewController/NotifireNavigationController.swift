//
//  NotifireNavigationController.swift
//  Notifire
//
//  Created by David Bielik on 10/12/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class NotifireNavigationController: UINavigationController {

    // MARK: - Properties
    var navigationBarTintColor: UIColor = .compatibleLabel

    private lazy var fullWidthBackGestureRecognizer = UIPanGestureRecognizer()

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.titleTextAttributes = TextAttributes.navigationTitle
        view.backgroundColor = .compatibleSystemBackground
        navigationBar.barTintColor = .compatibleSystemBackground
        navigationBar.tintColor = navigationBarTintColor

        setupFullWidthBackGesture()
    }

    // MARK: - Private
    private func setupFullWidthBackGesture() {
        // credits: https://stackoverflow.com/a/60598558/4249857
        // The trick here is to wire up our full-width `fullWidthBackGestureRecognizer` to execute the same handler as
        // the system `interactivePopGestureRecognizer`. That's done by assigning the same "targets" (effectively
        // object and selector) of the system one to our gesture recognizer.
        guard
            let interactivePopGestureRecognizer = interactivePopGestureRecognizer,
            let targets = interactivePopGestureRecognizer.value(forKey: "targets")
        else {
            return
        }

        fullWidthBackGestureRecognizer.setValue(targets, forKey: "targets")
        fullWidthBackGestureRecognizer.delegate = self
        view.addGestureRecognizer(fullWidthBackGestureRecognizer)
    }
}

extension NotifireNavigationController: Reselectable {
    func reselect(animated: Bool) -> Bool {
        guard viewControllers.count > 1 else { return false }
        popToRootViewController(animated: animated)
        return true
    }
}

extension NotifireNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isSystemSwipeToBackEnabled = interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = viewControllers.count > 1
        return isSystemSwipeToBackEnabled && isThereStackedViewControllers
    }
}
