//
//  RootViewController.swift
//  Notifire
//
//  Created by David Bielik on 06/09/2018.
//  Copyright © 2018 David Bielik. All rights reserved.
//

import UIKit

class RootViewController: VMViewController<RootViewModel>, NotifireAlertPresenting {

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.onNewVersionAvailable = { [weak self] appVersionData in
            self?.handleNewAppVersion(data: appVersionData)
        }
    }

    /// Change the main child viewcontroller that's in focus with a cycle animation.
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

    // MARK: - Event Handlers
    func handleNewAppVersion(data: AppVersionData) {
        let latestVersion = data.appVersionResponse.latestVersion
        let forceUpdate = data.appVersionResponse.forceUpdate

        let alertVC = NotifireAlertViewController(alertTitle: nil, alertText: nil)
        // Create a custom dismissal to take the UserAttentionPrompt into account
        let dimissAlert: ((Bool) -> Void) = { [weak self] animated in
            alertVC.dismiss(animated: animated) { [weak self] in
                self?.viewModel.activePrompt?.finish()
            }
        }
        alertVC.add(action: NotifireAlertAction(title: "Update now", style: .positive, handler: { _ in
            // Dismiss the alert if the update is not forced
            defer { if !forceUpdate { dimissAlert(false) } }
            // Redirect to the App Store page
            // FIXME: App Store url
            guard let url = URL(string: "https://google.com") else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }))
        if forceUpdate {
            alertVC.alertTitle = "New version required!"
            alertVC.alertText = "Looks like you are using an old version of Notifire. In order to continue using it, please update to the latest version (\(latestVersion)) on the App Store."
        } else {
            alertVC.alertTitle = "New version available!"
            alertVC.alertText = "You can download a new version (\(latestVersion)) of Notifire on the App Store."
            // Only add this option if a user is logged in == session is not nil
            if let session = viewModel.currentSessionHandler?.userSession {
                alertVC.add(action: NotifireAlertAction(title: "Turn off these alerts", style: .neutral, handler: { _ in
                    session.settings.appUpdateReminderEnabled = false
                    dimissAlert(true)
                }))
            }
            alertVC.add(action: NotifireAlertAction(title: "Maybe later", style: .neutral, handler: { _ in
                dimissAlert(true)
            }))
        }
        present(alert: alertVC, animated: true, completion: nil)
    }
}
