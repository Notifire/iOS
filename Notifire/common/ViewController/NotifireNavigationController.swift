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

    // MARK: NavigationReselectable
    weak var navigatingCoordinator: NavigatingCoordinator?

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
        let targetsKey = "targets"
        guard
            let interactivePopGestureRecognizer = interactivePopGestureRecognizer,
            let targets = interactivePopGestureRecognizer.value(forKey: targetsKey)
        else {
            return
        }

        fullWidthBackGestureRecognizer.setValue(targets, forKey: targetsKey)
        fullWidthBackGestureRecognizer.delegate = self
        view.addGestureRecognizer(fullWidthBackGestureRecognizer)
    }
}

// MARK: - NotifireNavigationController+Reselectable
protocol NavigationReselectable: Reselectable {
    var navigatingCoordinator: NavigatingCoordinator? { get set }
}

extension NavigationReselectable where Self: UINavigationController {
    func reselect(animated: Bool) -> Bool {
        guard viewControllers.count > 1 else { return false }
        navigatingCoordinator?.popToRootCoordinator(animated: animated)
        return true
    }
}

extension NotifireNavigationController: NavigationReselectable {}

// MARK: - NotifireNavigationController+UIGestureRecognizerDelegate
extension NotifireNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isSystemSwipeToBackEnabled = interactivePopGestureRecognizer?.isEnabled == true
        let isThereStackedViewControllers = viewControllers.count > 1
        var isValidPan = false
        // Avoids unnecessary pans / swipes that aim to the Right direction initially
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            isValidPan = panGestureRecognizer.velocity(in: view).x > 0
        }
        return isSystemSwipeToBackEnabled && isThereStackedViewControllers && isValidPan
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Respect the FullScreenBackGesturePanAltering classes
        guard let panAltering = topViewController as? FullScreenBackGesturePanAltering else { return false }
        let shouldCancelPanGesture = panAltering.prioritizedGestureRecognizers.contains(otherGestureRecognizer)
        return shouldCancelPanGesture
    }
}
